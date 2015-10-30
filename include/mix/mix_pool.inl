
namespace mix
{

template<typename TRAITS>
Pool<TRAITS>::Pool (AllocatorI& _allocator, size_t _nodeCapacityInitial, size_t _nodeCapacityMax)
    : m_allocator (_allocator)
    , m_firstDeleted (nullptr)
    , m_nodeFirst (_allocator, _allocator.allocate (OBJECT_SIZE * _nodeCapacityInitial), _nodeCapacityInitial)
    , m_nodeCapacityMax (_nodeCapacityMax)
    , m_nodeCapacityCurr (_nodeCapacityInitial)
    , m_countInNode (0)
    , m_countOfObjects (0)
{
    assert (_nodeCapacityMax >= 1 && "_nodeCapacityMax must be at least 1.");

    m_nodeMemory = m_nodeFirst.m_memory;
    m_nodeLast = &m_nodeFirst;
}

template<typename TRAITS>
Pool<TRAITS>::~Pool()
{
    SyncWrite _sync (m_syncHandle);

    if (m_countOfObjects)
    {
        PoolNode* _node = &m_nodeFirst;
        while (_node)
        {
            PoolNode* _nextNode = _node->m_nextNode;

            char* _address = (char*)_node->m_memory;
            for (size_t i = 0; i < _node->m_capacity; ++i)
            {
                if (isAllocated (_address))
                {
                    Object* _obj = (Object*)(_address + POINTER_SIZE);
                    _obj->~Object();
                }

                _address += OBJECT_SIZE;
            }
            _node = _nextNode;
        }

        m_countOfObjects = 0;
    }

    PoolNode* _node = m_nodeFirst.m_nextNode;
    while (_node)
    {
        PoolNode* _nextNode = _node->m_nextNode;
        _node->~PoolNode();
        m_allocator.deallocate (_node);
        
        _node = _nextNode;
    }
}

template<typename TRAITS>
bool Pool<TRAITS>::allocateNewNode()
{
    size_t _size = m_countInNode;
    if (_size >= m_nodeCapacityMax)
        _size = m_nodeCapacityMax;
    else
    {
        _size *= 2;

        if (_size >= m_nodeCapacityMax)
            _size = m_nodeCapacityMax;
    }

    PoolNode* _node = PoolNode::create (m_allocator, OBJECT_SIZE, _size);
    if (!_node)
        return false;

    m_nodeLast->m_nextNode = _node;
    m_nodeLast = _node;
    m_nodeMemory = _node->m_memory;
    m_countInNode = 0;
    m_nodeCapacityCurr = _size;

    return true;
}

template<typename TRAITS>
typename Pool<TRAITS>::Object* Pool<TRAITS>::allocate()
{
    SyncWrite _sync (m_syncHandle);

    if (m_firstDeleted)
    {
        Object* _ret = m_firstDeleted;
        m_firstDeleted = * ((Object**)m_firstDeleted);
        m_countOfObjects++;
        return _ret;
    }

    if (m_countInNode >= m_nodeCapacityCurr)
        if (!allocateNewNode())
            return nullptr;

    char* _address = (char*)m_nodeMemory;
    _address += m_countInNode * OBJECT_SIZE;
    markAllocated (_address);
    
    m_countInNode++;
    m_countOfObjects++;
    
    return (Object*)(_address + HEADER_SIZE);
}

template<typename TRAITS>
bool Pool<TRAITS>::isOwnerOf (Object* _content) const
{
    SyncRead _sync (m_syncHandle);

    bool _found = false;

    char* memCur = reinterpret_cast<char*> (_content);

    const PoolNode* _node = &m_nodeFirst;
    while (_node && !_found)
    {
        char* memBeg = static_cast<char*> (_node->m_memory);
        char* memEnd = memBeg;

        if (_node == m_nodeLast)
            memEnd += OBJECT_SIZE * m_countInNode;
        else
            memEnd += OBJECT_SIZE * _node->m_capacity;

        _found = (memBeg <= memCur) && (memCur < memEnd);

        _node = _node->m_nextNode;
    }

    return _found;
}

template<typename TRAITS>
void Pool<TRAITS>::release (Object* _content)
{
    SyncWrite _sync (m_syncHandle);

    unmarkAllocated ((char*)_content - HEADER_SIZE);

    * ((Object**)_content) = m_firstDeleted;
    m_firstDeleted = _content;

    m_countOfObjects--;
}

template<typename TRAITS>
bool Pool<TRAITS>::releaseSafe (Object* _content)
{
    if (!isOwnerOf (_content))
        return false;

    release (_content);
    return true;
}

template<typename TRAITS>
template<typename... ARGS>
typename Pool<TRAITS>::Object* Pool<TRAITS>::newObject(ARGS... _args)
{
	return AllocatorHelper::invokeNew<Object> (m_allocator, allocate(), _args...);
    //return new (allocate()) Object (_args...);
}

template<typename TRAITS>
bool Pool<TRAITS>::delObject(Object* _content)
{
    if (!isOwnerOf (_content))
        return false;

    _content->~Object();

    release (_content);
    return true;
}

template<typename TRAITS>
size_t Pool<TRAITS>::getObjectCount() const
{
    SyncRead _sync (m_syncHandle);
    return m_countOfObjects;
}

template<typename TRAITS>
void Pool<TRAITS>::foreach (const std::function<bool (Object*)>& _func)
{
    SyncRead _sync (m_syncHandle);

    if (!m_countOfObjects)
        return;

    PoolNode* _node = &m_nodeFirst;
    while (_node)
    {
        PoolNode* _nextNode = _node->m_nextNode;

        char* _address = (char*)_node->m_memory;
        for (size_t i = 0; i < _node->m_capacity; ++i)
        {
            if (isAllocated (_address))
            {
                if (!_func ((Object*)(_address + POINTER_SIZE)))
                    return;
            }

            _address += OBJECT_SIZE;
        }
        _node = _nextNode;
    }
}

} // namespace mix

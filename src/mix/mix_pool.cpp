#include <mix/mix_pool.h>

namespace mix
{

PoolNode* PoolNode::create (AllocatorI& _allocator, size_t _itemSize, size_t _capacity)
{
    assert (_capacity >= 1 && "_capacity must be at least 1.");

    void* _memptr = _allocator.allocate (_itemSize * _capacity);
    if (nullptr == _memptr)
        return nullptr;

    memset (_memptr, 0, _itemSize * _capacity);
	
	void* _objptr = _allocator.allocate (sizeof (PoolNode));
    if (!_objptr)
        return nullptr;

    return new (_objptr) PoolNode (_allocator, _memptr, _capacity);
}

PoolNode::PoolNode (AllocatorI& _allocator, void* _memory, size_t _capacity)
    : m_allocator (_allocator)
    , m_memory (_memory)
    , m_capacity (_capacity)
    , m_nextNode (nullptr)
{
}

PoolNode::~PoolNode()
{
    m_allocator.deallocate (m_memory);
}

}

#if defined (MIX_TESTS)
#   include "mix_pool.tests.inl"
#endif

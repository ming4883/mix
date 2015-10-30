#ifndef MIX_POOL_H
#define MIX_POOL_H

#include <mix/mix_allocator.h>
#include <bx/Mutex.h>

#include <new>
#include <functional>
#include <cassert>

namespace mix
{

template<typename T>
struct PoolTraitsDefault
{
    typedef T ObjectType;
};

class PoolNode
{
public:
    AllocatorI& m_allocator;
    void* m_memory;
    size_t m_capacity;
    PoolNode* m_nextNode;

    PoolNode (AllocatorI& _allocator, void* _memory, size_t _capacity);
    ~PoolNode();

    AllocatorI& getAllocator() { return m_allocator; }

    static PoolNode* create (AllocatorI& _allocator, size_t _itemSize, size_t _capacity);
};

/*! An object pool based on
    http://www.codeproject.com/Articles/746630/O-Object-Pool-in-Cplusplus v-2014-04-21
*/
template<typename TRAITS>
class Pool
{
public:
    typedef typename TRAITS::ObjectType Object;
    typedef bx::Mutex Sync;
    typedef bx::MutexScope SyncWrite;
    typedef bx::MutexScope SyncRead;
    
    explicit Pool (AllocatorI& _allocator, size_t _nodeCapacityInitial = 32u, size_t _nodeCapacityMax = 1000000u);

    virtual ~Pool();

    AllocatorI& getAllocator()
    {
        return m_allocator;
    }

    bool isOwnerOf (Object* _content) const;

    template<typename... ARGS>
    Object* newObject (ARGS... _args);

    bool delObject (Object* _content);

    /*! Returns the number of living objects in this Pool.
     */
    size_t getObjectCount() const;

    /*! Invoke _func() for each object in this Pool. If _func() returns false, the iteration stops and exits.
     */
    void foreach (const std::function<bool (Object*)>& _func);

private:
    enum {
        POINTER_SIZE = sizeof (void*),
        HEADER_SIZE = POINTER_SIZE,
        OBJECT_SIZE = HEADER_SIZE + ((sizeof (Object) + POINTER_SIZE - 1) / POINTER_SIZE) * POINTER_SIZE,
        FLAG_ALLOCATED = 1 << 31,
    };

    mutable Sync m_syncHandle;
    AllocatorI& m_allocator;

    void* m_nodeMemory;
    Object* m_firstDeleted;
    PoolNode* m_nodeLast;
	PoolNode m_nodeFirst;
	
	const size_t m_nodeCapacityMax;
    size_t m_nodeCapacityCurr;
	size_t m_countInNode;
    size_t m_countOfObjects;
    
    bool allocateNewNode();

    Object* allocate();

    void release (Object* _content);

    bool releaseSafe (Object* _content);

    inline uint32_t& getFlags(void* _address) { return *((uint32_t*)_address); }

    inline void markAllocated (void* _address) { getFlags (_address) |= FLAG_ALLOCATED; }

    inline void unmarkAllocated (void* _address) { getFlags (_address) &= ~FLAG_ALLOCATED; }

    inline bool isAllocated (void* _address) { return (getFlags (_address) & FLAG_ALLOCATED) > 0; }
};

} // namespace mix

MIX_CLASS_IS_ALLOCATOR_OWNER (mix::PoolNode);

template<typename TRAITS>
MIX_TEMPLATE_IS_ALLOCATOR_OWNER (mix::Pool<TRAITS>);

#include "mix_pool.inl"

#endif // MIX_POOL_H

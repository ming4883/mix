#ifndef MIX_ALLOCATOR_H
#define MIX_ALLOCATOR_H

#include <bx/allocator.h>
#include <new>

#define MIX_CLASS_IS_ALLOCATOR_OWNER(_type) template<> struct mixIsAllocatorOwner<_type> { static const bool Value = true; };

#define MIX_TEMPLATE_IS_ALLOCATOR_OWNER(_type) struct mixIsAllocatorOwner<_type> { static const bool Value = true; };


template<typename T>
struct mixIsAllocatorOwner
{
    static const bool Value = false;
};


namespace mix
{

class BX_NO_VTABLE AllocatorI
{
public:
    virtual ~AllocatorI() = 0;
    
    virtual void* allocate (size_t _size) = 0;
    
    virtual void* reallocate (void* _ptr, size_t _size) = 0;

    virtual void deallocate (void* _ptr) = 0;

public:
    static AllocatorI& getDefault();
};

inline AllocatorI::~AllocatorI()
{
}

class AllocatorCrtUnaligned : public AllocatorI
{
public:
    AllocatorCrtUnaligned()
    {
    }
    
    ~AllocatorCrtUnaligned() override
    {
    }
    
    void* allocate (size_t _size) override
    {
        return BX_ALLOC (&m_crt, _size);
    }
    
    void* reallocate (void* _ptr, size_t _size) override
    {
        return BX_REALLOC (&m_crt, _ptr, _size);
    }

    void deallocate (void* _ptr) override
    {
        return BX_FREE (&m_crt, _ptr);
    }
    
protected:
    bx::CrtAllocator m_crt;
};

template<int ALIGNMENT>
class AllocatorCrt : public AllocatorI
{
public:
    AllocatorCrt()
    {
    }
    
    ~AllocatorCrt() override
    {
    }
    
    void* allocate (size_t _size) override
    {
        return BX_ALIGNED_ALLOC (&m_crt, _size, ALIGNMENT);
    }
    
    void* reallocate (void* _ptr, size_t _size) override
    {
        return BX_ALIGNED_REALLOC (&m_crt, _ptr, _size, ALIGNMENT);
    }

    void deallocate (void* _ptr) override
    {
        return BX_ALIGNED_FREE (&m_crt, _ptr, ALIGNMENT);
    }
    
protected:
    bx::CrtAllocator m_crt;
};

template<>
class AllocatorCrt<0> : public AllocatorCrtUnaligned
{
};

template<>
class AllocatorCrt<1> : public AllocatorCrtUnaligned
{
};

namespace AllocatorHelper
{
    template <typename T, bool B>
    struct New
    {
        template<typename... ARGS>
        static T* invoke (AllocatorI& _allocator, void* _mem, ARGS ..._args)
        {
            return new (_mem) T (_allocator, _args...);
        }
    };
    
    template<typename T>
    struct New<T, false>
    {
        template<typename... ARGS>
        static T* invoke (AllocatorI& _allocator, void* _mem, ARGS ..._args)
        {
            return new (_mem) T (_args...);
        }
    };
    
    template<typename T, typename... ARGS>
    static T* invokeNew (AllocatorI& _allocator, void* _mem, ARGS ..._args)
    {
        typedef New<T, mixIsAllocatorOwner<T>::Value> NewOp;
        return NewOp::invoke (_allocator, _mem, _args...);
    }


    template<typename T>
    static void invokeDel (AllocatorI& _allocator, T* _t)
    {
        _t->~T();
        _allocator.deallocate (_t); 
    }
}

}	// namespace mix

template<typename T, typename... ARGS>
T* mix_new (mix::AllocatorI& _allocator, ARGS ..._args)
{
    void* _mem = _allocator.allocate (sizeof (T));
    if (!_mem)
        return nullptr;
    
    return mix::AllocatorHelper::invokeNew<T> (_allocator, _mem, _args...);
}

template<typename T>
void mix_del (mix::AllocatorI& _allocator, T* _t)
{
    return mix::AllocatorHelper::invokeDel<T> (_allocator, _t);
}


#endif	// MIX_ALLOCATOR_H

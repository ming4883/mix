#ifndef MIX_BUFFER_H
#define MIX_BUFFER_H

#include <bx/bx.h>

namespace mix
{

class Buffer
{
public:
    Buffer (void);
    Buffer (uint32_t _contentSize);
    Buffer (const uint8_t* _contentPtr, uint32_t _contentSize);
    Buffer (const Buffer& _contents);
    Buffer (Buffer&& _contents);

    ~Buffer();

    Buffer& operator = (const Buffer& _contents);
    Buffer& operator = (Buffer&& _contents);

    uint8_t* ptr();
    const uint8_t* ptr() const;

    template<typename T>
    const T* ptrAs() const
    {
        return reinterpret_cast<const T*> (ptr());
    }

    template<typename T>
    T* ptrAs()
    {
        return reinterpret_cast<T*> (ptr());
    }

    uint32_t size() const;

    bool isEmpty() const;

    void resize (uint32_t _size);

private:
    void* m_handle;

    friend class BufferImpl;
};

} // namespace mix

#endif // MIX_STRING_H

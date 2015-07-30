#ifndef MIX_BUFFER_H
#define MIX_BUFFER_H

#include <bx/bx.h>

namespace mix
{

class Buffer
{
public:

    //! Default constructor, leave the Buffer empty.
    Buffer (void);

    /*! Construct with size and optional contents, the Buffer is allocated to _contentSize
        and copy the contents at _contentPtr if it is not nullptr.
     */
    Buffer (uint32_t _contentSize, const uint8_t* _contentPtr = nullptr);

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

    void fill (uint8_t _value);

private:
    void* m_handle;

    friend class BufferImpl;
};

} // namespace mix

#endif // MIX_STRING_H

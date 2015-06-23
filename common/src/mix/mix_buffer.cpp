#include <mix/mix_buffer.h>

#include <vector>

namespace mix
{

class BufferImpl
{
public:
    typedef std::vector<uint8_t> Type;

    template<typename... Args>
    static Type* create (Args... args)
    {
        return new Type (args...);
    }

    static Type* get (Buffer* _buffer)
    {
        return static_cast<Type*> (_buffer->m_handle);
    }

    static Type* get (const Buffer* _buffer)
    {
        return static_cast<Type*> (_buffer->m_handle);
    }

    static Type* clone (const Buffer& _buffer)
    {
        if (!_buffer.m_handle)
            return nullptr;

        return new Type (*get (&_buffer));
    }
};


Buffer::Buffer (void)
    : m_handle (nullptr)
{
}

Buffer::Buffer (uint32_t _contentSize)
    : m_handle (BufferImpl::create (_contentSize))
{
}

Buffer::Buffer (const uint8_t* _contentPtr, uint32_t _contentSize)
    : m_handle (BufferImpl::create (_contentPtr, _contentPtr + _contentSize))
{
}

Buffer::Buffer (const Buffer& _contents)
    : m_handle (BufferImpl::clone (_contents))
{
}

Buffer::Buffer (Buffer&& _contents)
    : m_handle (nullptr)
{
    m_handle = _contents.m_handle;
    _contents.m_handle = nullptr;
}

Buffer::~Buffer()
{
    if (m_handle)
        delete BufferImpl::get (this);
}

Buffer& Buffer::operator = (const Buffer& _contents)
{
    if (m_handle)
        delete BufferImpl::get (this);

    m_handle = BufferImpl::clone (_contents);
    return *this;
}

Buffer& Buffer::operator = (Buffer&& _contents)
{
    if (m_handle)
        delete BufferImpl::get (this);

    m_handle = _contents.m_handle;
    _contents.m_handle = nullptr;

    return *this;
}

uint8_t* Buffer::ptr()
{
    if (!m_handle)
        return nullptr;

    return &BufferImpl::get (this)->front();
}

const uint8_t* Buffer::ptr() const
{
    if (!m_handle)
        return nullptr;

    return &BufferImpl::get (this)->front();
}

uint32_t Buffer::size() const
{
    if (!m_handle)
        return 0u;

    return (uint32_t)BufferImpl::get (this)->size();
}

bool Buffer::isEmpty() const
{
    if (!m_handle)
        return true;

    return BufferImpl::get (this)->empty();
}

void Buffer::resize (uint32_t _size)
{
    if (!m_handle)
    {
        m_handle = BufferImpl::create (_size);
    }
    else
    {
        BufferImpl::get (this)->resize (_size);
    }
}

}

#if defined (MIX_TESTS)
#   include "mix_buffer.tests.inl"
#endif
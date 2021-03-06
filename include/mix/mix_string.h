#ifndef MIX_STRING_H
#define MIX_STRING_H

#include <mix/mix_buffer.h>
#include <bx/string.h>

namespace mix
{

//! A c-style string formatter with a managed internal buffer
class StringFormatter
{
public:
    StringFormatter (uint32_t _initialBufferSize = 256u);

    template<typename... Args>
    const char* format (const char* _fmt, Args... _args)
    {
        if (!_fmt)
            return nullptr;

        int _needed = -1;
        
        while (_needed == -1 || _needed >= (int)m_buffer.size())
        {
            if (_needed > -1)
                m_buffer.resize (_needed + 1);
            //::memset (buffer, 0, bufLen + 1);
            _needed = bx::snprintf (m_buffer.ptrAs<char>(), m_buffer.size(), _fmt, _args...);
        }
        
        //_buffer.ptrAs<char>()[_needed] = 0;
        return m_buffer.ptrAs<char>();
    }

private:
    Buffer m_buffer;

};

class Utf8Buffer : public Buffer
{
public:
    
    /*! Construct with a utf8 encoded string, the Buffer is allocated to _contentSize
        and copy the contents at _contentPtr if it is not nullptr.
     */
    Utf8Buffer (const char* _utf8str);

    const char* c_str() const 
    {
        return ptrAs<char>();
    }

};

} // namespace mix

#endif // MIX_STRING_H

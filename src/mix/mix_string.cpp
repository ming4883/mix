#include <mix/mix_string.h>

namespace mix
{

StringFormatter::StringFormatter (uint32_t _initialBufferSize)
    : m_buffer (_initialBufferSize)
{

}

Utf8Buffer::Utf8Buffer (const char* _utf8Str)
    : Buffer ((uint32_t)strlen (_utf8Str) + 1, (const uint8_t*)_utf8Str)
{
}

}

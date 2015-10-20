#include <mix/mix_log.h>

namespace mix
{
    void Log::init()
    {
    }

    void Log::shutdown()
    {
    }

    void Log::write (LogLevel::Enum _level, const char* _tag, const char* _str)
    {
        printf ("%s: %s\n", _tag, _str);
    }
}

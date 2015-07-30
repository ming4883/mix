#if defined (MIX_ANDROID)

#include <mix/mix_log.h>
#include <android/log.h>

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
        static int _mapping[] = {
            ANDROID_LOG_DEBUG,
            ANDROID_LOG_INFO,
            ANDROID_LOG_WARN,
            ANDROID_LOG_ERROR,
        };
        __android_log_print (_mapping[_level], _tag, "%s", _str);
    }
}

#endif // #if defined (MIX_ANDROID)

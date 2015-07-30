#if defined (MIX_WINDOWS_DESKTOP)

#include <mix/mix_log.h>
#include <Windows.h>

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
        ::OutputDebugStringA (_tag);
        ::OutputDebugStringA (": ");
        ::OutputDebugStringA (_str);
        ::OutputDebugStringA ("\n");
    }
}

#endif // #if defined (MIX_WINDOWS_DESKTOP)

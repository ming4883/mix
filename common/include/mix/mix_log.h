#ifndef MIX_LOG_H
#define MIX_LOG_H

#include <mix/mix_buffer.h>
#include <bx/string.h>
#include <bx/Mutex.h>

namespace mix
{

namespace LogLevel
{
    enum Enum
    {
        Debug,
        Info,
        Warn,
        Error,
    };

}   // namespace LogLevel

class Log
{
public:
    static void init();

    static void shutdown();

    static void write (LogLevel::Enum _level, const char* _tag, const char* _str);

    template<typename... Args>
    static void format (LogLevel::Enum _level, const char* _tag, const char* _fmt, Args... _args)
    {
        static bx::Mutex _mutex;
        static Buffer _buffer (256);

        if (!_fmt)
            return;

        bx::MutexScope ms (_mutex);

        int _needed = -1;
        
        while (_needed == -1 || _needed >= (int)_buffer.size())
        {
            if (_needed > -1)
                _buffer.resize (_needed + 1);
            //::memset (buffer, 0, bufLen + 1);
            _needed = bx::snprintf (_buffer.ptrAs<char>(), _buffer.size(), _fmt, _args...);
        }
        
        write (_level, _tag, _buffer.ptrAs<char>());
    }

    template<typename... Args>
    static void d (const char* _tag, const char* _fmt, Args... _args)
    {
        LogLevel::Enum _level = LogLevel::Debug;

        if (sizeof... (_args) == 0)
            write (_level, _tag, _fmt);
        else
            format (_level, _tag, _fmt, _args...);
    }

    template<typename... Args>
    static void i (const char* _tag, const char* _fmt, Args... _args)
    {
        LogLevel::Enum _level = LogLevel::Info;

        if (sizeof... (_args) == 0)
            write (_level, _tag, _fmt);
        else
            format (_level, _tag, _fmt, _args...);
    }

    template<typename... Args>
    static void w (const char* _tag, const char* _fmt, Args... _args)
    {
        LogLevel::Enum _level = LogLevel::Warn;

        if (sizeof... (_args) == 0)
            write (_level, _tag, _fmt);
        else
            format (_level, _tag, _fmt, _args...);
    }

    template<typename... Args>
    static void e (const char* _tag, const char* _fmt, Args... _args)
    {
        LogLevel::Enum _level = LogLevel::Error;

        if (sizeof... (_args) == 0)
            write (_level, _tag, _fmt);
        else
            format (_level, _tag, _fmt, _args...);
    }
};

} // namespace mix

#endif // MIX_LOG_H

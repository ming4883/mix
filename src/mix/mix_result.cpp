#include <mix/mix_result.h>

namespace mix
{
    Result Result::ok ()
    {
        return Result (true);
    }
    
    Result Result::fail (const char* _why)
    {
        return Result (false, _why);
    }

    Result::Result (void)
        : m_ok (false)
        , m_why ("")
    {
    }
    
    Result::Result (bool _ok, const char* _why)
        : m_ok (_ok)
        , m_why (_why)
    {
    }
    
    bool Result::isOK() const
    {
        return m_ok == true;
    }
    
    bool Result::isFail() const
    {
        return m_ok == false;
    }
    
    const char* Result::why() const
    {
        return m_why;
    }
}

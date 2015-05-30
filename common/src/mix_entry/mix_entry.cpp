#include <mix_entry/mix_entry.h>

namespace mix
{
	void TimeSource::reset()
	{
        m_offset = bx::getHPCounter();
		m_last = m_offset;
        m_now = m_offset;

        m_toMS = 1000.0 / bx::getHPFrequency();
	}

    void TimeSource::nextFrame()
    {
        m_last = m_now;
        m_now = bx::getHPCounter();
    }
	
	float TimeSource::totalTimeInMS() const
	{
        return (float)((m_now - m_offset) * m_toMS);
	}
	
	float TimeSource::frameTimeInMS() const
	{
		return (float)((m_now - m_last) * m_toMS);
	}
	
	float TimeSource::frameTimeSmoothedInMS() const
	{
		return frameTimeInMS();
	}
	
	Result Result::ok ()
	{
		return Result (true);
	}
	
	Result Result::fail (const char* _why)
	{
		return Result (false, _why);
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
	
    Application* Application::ms_inst = nullptr;

    Result Application::cleanup ()
    {
        if (!ms_inst)
        {
            return Result::fail ("Application instance not exists!");
        }

        delete ms_inst;
        ms_inst = nullptr;
        return Result::ok();
    }

    Application* Application::get()
    {
        return ms_inst;
    }
	
	Application::Application()
	{
        m_backbufferWidth = 0;
        m_backbufferHeight = 0;
		ms_inst = this;
	}

    Application::~Application()
    {
    }

    void Application::preInit()
    {
        m_timeSource.reset();
    }

    void Application::postInit()
    {
    }

    void Application::preUpdate()
    {
        m_timeSource.nextFrame();
    }

    void Application::postUpdate()
    {
    }

    void Application::preShutdown()
    {
    }

    void Application::postShutdown()
    {
    }

    void Application::setBackbufferSize (int w, int h)
    {
        m_backbufferWidth  = w;
        m_backbufferHeight = h;
    }
	
	int Application::getBackbufferWidth()
	{
		return m_backbufferWidth;
	}
	
	int Application::getBackbufferHeight()
	{
		return m_backbufferHeight;
	}
}

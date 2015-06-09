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

    void Application::setBackbufferSize (int _w, int _h)
    {
        m_backbufferWidth  = _w;
        m_backbufferHeight = _h;
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

#include <mix_entry/mix_application.h>

namespace mix
{
    EventTypeId ApplicationEvent::getEventTypeId()
    {
        return EventTypeId ("ApplicationEvent");
    }

    void ApplicationEvent::finalize (Event* _event)
    {
        if (_event->is<ApplicationEvent>())
        {
            delete _event;
        }
    }

    ApplicationEvent::ApplicationEvent (ApplicationEventType::Enum _type)
        : Event (getEventTypeId(), finalize)
        , type (_type)
    {
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

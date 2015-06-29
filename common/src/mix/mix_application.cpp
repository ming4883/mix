#include <mix/mix_application.h>

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
            delete static_cast<ApplicationEvent*> (_event);
        }
    }

    ApplicationEvent::ApplicationEvent (ApplicationEventType::Enum _type)
        : Event (getEventTypeId(), finalize)
        , type (_type)
    {
    }

    ApplicationEvent* ApplicationEvent::terminating()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::Terminating);
        return _this;
    }

    ApplicationEvent* ApplicationEvent::lowMemory()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::LowMemory);
        return _this;
    }

    ApplicationEvent* ApplicationEvent::willEnterBackground()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::WillEnterBackground);
        return _this;
    }

    ApplicationEvent* ApplicationEvent::didEnterBackground()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::DidEnterBackground);
        return _this;
    }

    ApplicationEvent* ApplicationEvent::willEnterForeground()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::WillEnterForeground);
        return _this;
    }

    ApplicationEvent* ApplicationEvent::didEnterForeground()
    {
        ApplicationEvent* _this = new ApplicationEvent (ApplicationEventType::DidEnterForeground);
        return _this;
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

        processQueuedEvents();
    }

    void Application::postUpdate()
    {
    }

    void Application::preShutdown()
    {
        processQueuedEvents();
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

    Result Application::pushEvent (Event* _event)
    {
        return m_eventQueue.push (_event);
    }

    void Application::processQueuedEvents()
    {
        while (!m_eventQueue.isEmpty())
        {
            const Event* _event = m_eventQueue.peek();
            handleEvent (_event);
            m_eventQueue.discard();
        }
    }
}

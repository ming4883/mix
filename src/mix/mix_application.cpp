#include <mix/mix_application.h>
#include <bgfx/bgfx.h>

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
        m_frontendDesc = FrontendDesc::descFullScreen;

        Buffer _path (256);
        mix::Log::i ("app", "pwd = %s", bx::pwd (_path.ptrAs<char>(), _path.size()));

        ms_inst = this;
    }

    Application::~Application()
    {
    }

    void Application::setMainFrontendDesc (const FrontendDesc& _desc)
    {
        m_frontendDesc = _desc;
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

    void Application::platformSetBackbufferSize (int _w, int _h)
    {
        m_frontendDesc.width  = _w;
        m_frontendDesc.height = _h;
    }

    const FrontendDesc& Application::getMainFrontendDesc()
    {
        return m_frontendDesc;
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

            const mix::FrontendEvent* _fnevt = _event->cast<mix::FrontendEvent>();
            if (nullptr != _fnevt && _fnevt->type == mix::FrontendEventType::Resized)
                bgfx::reset (_fnevt->params.size.w, _fnevt->params.size.h, BGFX_RESET_HIDPI);

            handleEvent (_event);
            m_eventQueue.discard();
        }
    }

}

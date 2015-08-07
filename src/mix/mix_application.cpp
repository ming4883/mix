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
        m_frontendDesc = FrontendDesc::descFullScreen;
        m_fileReader = nullptr;
        m_fileWriter = nullptr;

        Buffer _path (256);
        mix::Log::i ("app", "pwd = %s", bx::pwd (_path.ptrAs<char>(), _path.size()));

        ms_inst = this;
    }

    Application::~Application()
    {
        delete m_fileReader;
        delete m_fileWriter;
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

    Result Application::load (Buffer& _outBuffer, const char* _filepath)
    {
        if (nullptr == m_fileReader)
            return Result::fail ("File Reader is not supported on this platform");

        if (0 != bx::open (m_fileReader, _filepath))
            return Result::fail ("cannot open file");
        
        uint32_t _size = (uint32_t)bx::getSize (m_fileReader);
        uint32_t _read = 0;

        if (_size > 0)
        {
            Buffer _buf (_size, nullptr);
            _read = (uint32_t)bx::read (m_fileReader, _buf.ptr(), _size);
            _outBuffer = std::move (_buf);
        }

        bx::close (m_fileReader);
            
        if (_size != _read)
            return Result::fail ("inconsistent size in bx::read()");

        return Result::ok();
    }

    Result Application::loadAsset (Buffer& _outBuffer, const char* _assetname)
    {
        mix::StringFormatter _filepath;

        {
            Result _ret = load (_outBuffer, _filepath.format ("runtime/%s", _assetname));
            if (_ret.isOK())
                return _ret;
        }
        {
            Result _ret = load (_outBuffer, _filepath.format ("%s/runtime/%s", getAppId(), _assetname));
            if (_ret.isOK())
                return _ret;
        }
        
        return Result::fail ("asset not found");
    }

    void Application::platformSetBackbufferSize (int _w, int _h)
    {
        m_frontendDesc.width  = _w;
        m_frontendDesc.height = _h;
    }

    void Application::platformSetFileRW (bx::FileReaderI* _reader, bx::FileWriterI* _writer)
    {
        m_fileReader = _reader;
        m_fileWriter = _writer;
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
            handleEvent (_event);
            m_eventQueue.discard();
        }
    }
}

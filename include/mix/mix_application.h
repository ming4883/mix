#ifndef MIX_APPLICATION_H
#define MIX_APPLICATION_H

#include <bx/platform.h>
#include <bx/readerwriter.h>

#include <mix/mix_frontend.h>
#include <mix/mix_result.h>
#include <mix/mix_event.h>
#include <mix/mix_time.h>
#include <mix/mix_log.h>

namespace mix
{

namespace ApplicationEventType
{
    enum Enum
    {
        Terminating,
        LowMemory,
        WillEnterBackground,
        DidEnterBackground,
        WillEnterForeground,
        DidEnterForeground,
    };
} // namespace ApplicationEventType

class ApplicationEvent : public Event
{
public:
    static EventTypeId getEventTypeId();
    static void finalize (Event* _event);

public:
    ApplicationEventType::Enum type;
    
    ApplicationEvent (ApplicationEventType::Enum _type);

    static ApplicationEvent* terminating();
    static ApplicationEvent* lowMemory();
    static ApplicationEvent* willEnterBackground();
    static ApplicationEvent* didEnterBackground();
    static ApplicationEvent* willEnterForeground();
    static ApplicationEvent* didEnterForeground();
};

class Application
{

public:
    static Result cleanup();

    static Application* get();

public:
    //! Set the requested main FrontendDesc. Invoke this method during the constructor.
    void setMainFrontendDesc (const FrontendDesc& _desc);

    //! Return the application identifier e.g. "org.mix.example01"
    virtual const char* getAppId() const = 0;

    //! Invoked when application startup
    virtual Result init() = 0;
    
    //! Invoked when application shutdown
    virtual void shutdown() = 0;
    
    //! Invoked once per frame
    virtual void update() = 0;

    //! Invoked when there is an Event popped from the Application EventQueue
    virtual void handleEvent (const Event* _event) = 0;

    
public:
    Application();
    virtual ~Application();

    //! Return the width of the main Frontend
    const FrontendDesc& getMainFrontendDesc();

    //! Return the TimeSource
    const TimeSource& getTimeSource() const { return m_timeSource; }

    //! Push an Event to the Application for processing
    Result pushEvent (Event* _event);

    //! Load a file into the _outBuffer
    Result load (Buffer& _outBuffer, const char* _filepath);

    //! Load an asset into the _outBuffer
    Result loadAsset (Buffer& _outBuffer, const char* _assetname);

public:
    //! Perform common tasks before Application::init()
    void preInit();

    //! Perform common tasks after Application::init()
    void postInit();

    //! Perform common tasks before Application::update()
    void preUpdate();

    //! Perform common tasks after Application::update()
    void postUpdate();

    //! Perform common tasks before Application::shutdown()
    void preShutdown();

    //! Perform common tasks after Application::shutdown()
    void postShutdown();

    //! Process all events in EventQueue.
    void processQueuedEvents();

    //! Reserved for platform implementation
    void platformSetBackbufferSize (int _w, int _h);

    //! Reserved for platform implementation
    void platformSetFileRW (bx::FileReaderI* _reader, bx::FileWriterI* _writer);

private:
    static Application* ms_inst;

    TimeSource m_timeSource;
    EventQueue m_eventQueue;
    FrontendDesc m_frontendDesc;
    bx::FileReaderI* m_fileReader;
    bx::FileWriterI* m_fileWriter;
};

template<class APP = Application>
inline APP* theApp() { return static_cast<APP*> (Application::get()); }

} // namespace mix

#endif // MIX_ENTRY_H

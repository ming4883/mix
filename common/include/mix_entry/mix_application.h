#ifndef MIX_APPLICATION_H
#define MIX_APPLICATION_H

#include <bx/platform.h>

#include <mix_entry/mix_result.h>
#include <mix_entry/mix_event.h>
#include <mix_entry/mix_time.h>

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
};

class Application
{

public:
	static Result cleanup();

    static Application* get();

public:
	//! Invoked when application startup
	virtual Result init() = 0;
	
	//! Invoked when application shutdown
	virtual void shutdown() = 0;
	
	//! Invoked once per frame
	virtual void update() = 0;
	
public:
    Application();
    virtual ~Application();

    void setBackbufferSize (int _w, int _h);
	
	//! Return the width of the main surface
	int getBackbufferWidth();
	
	//! Return the height of the main surface
	int getBackbufferHeight();

    //! Return the TimeSource
    const TimeSource& getTimeSource() const { return m_timeSource; }

    //! Return the EventQueue for application wise evnet publishing
    EventQueue& getEventQueue() { return m_eventQueue; }

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

private:
    static Application* ms_inst;

    TimeSource m_timeSource;
    EventQueue m_eventQueue;
    int m_backbufferWidth, m_backbufferHeight;
};

template<class APP = Application>
inline APP* theApp() { return static_cast<APP*> (Application::get()); }
	
} // namespace mix

#endif // MIX_ENTRY_H

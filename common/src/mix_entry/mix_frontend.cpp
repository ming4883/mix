#include <mix_entry/mix_frontend.h>

namespace mix
{
    EventTypeId FrontendEvent::getEventTypeId()
    {
        return EventTypeId ("FrontendEvent");
    }

    void FrontendEvent::finalize (Event* _event)
    {
    }

    FrontendEvent::FrontendEvent (FrontentEventType::Enum _type)
        : Event (getEventTypeId(), finalize)
        , type (_type)
    {
        params[0] = 0.0f;
        params[1] = 0.0f;
        params[2] = 0.0f;
        params[3] = 0.0f;
    }
}

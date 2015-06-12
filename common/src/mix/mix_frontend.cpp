#include <mix/mix_frontend.h>
#include <mix/mix_array.h>

namespace mix
{
    EventTypeId FrontendEvent::getEventTypeId()
    {
        return EventTypeId ("FrontendEvent");
    }

    void FrontendEvent::finalize (Event* _event)
    {
        if (_event->is<FrontendEvent>())
        {
            delete static_cast<FrontendEvent*> (_event);
        }
    }

    FrontendEvent::FrontendEvent (FrontendEventType::Enum _type)
        : Event (getEventTypeId(), finalize)
        , type (_type)
    {
        params.location.x = 0.0f;
        params.location.y = 0.0f;
        params.size.w = 0;
        params.size.h = 0;
    }
}

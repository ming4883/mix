#ifndef MIX_FRONTEND_H
#define MIX_FRONTEND_H

#include <mix_entry/mix_event.h>

namespace mix
{

namespace FrontentEventType
{
    enum Enum
    {
        Resized,
        Closed,
        TouchDown,
        TouchMove,
        TouchUp,
    };
}

class FrontendEvent : public Event
{
public:
    static EventTypeId getEventTypeId();
    static void finalize (Event* _event);

public:
    FrontentEventType::Enum type;
    float params[4];

    FrontendEvent (FrontentEventType::Enum _type);
};

	
} // namespace mix

#endif // MIX_FRONTEND_H

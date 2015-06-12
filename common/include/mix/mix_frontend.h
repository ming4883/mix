#ifndef MIX_FRONTEND_H
#define MIX_FRONTEND_H

#include <mix/mix_event.h>
#include <bx/float4_t.h>

namespace mix
{

namespace FrontendEventType
{
    enum Enum
    {
        Resized,
        Closed,
        TouchDown,
        TouchMove,
        TouchUp,
    };
} // namespace FrontendEventType

class FrontendEvent : public Event
{
public:
    static EventTypeId getEventTypeId();
    static void finalize (Event* _event);

public:
    FrontendEventType::Enum type;
    
    union
    {
        struct
        {
            float x, y;
        } location;
        struct
        {
            int w, h;
        } size;
    } params;

    FrontendEvent (FrontendEventType::Enum _type);
};

	
} // namespace mix

#endif // MIX_FRONTEND_H

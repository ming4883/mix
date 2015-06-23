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


/*! Frontend related events.
 */
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

    //! Create a FrontendEvent with type = FrontendEventType::Resized
    static FrontendEvent* resized (int _w, int _h);
    
    //! Create a FrontendEvent with type = FrontendEventType::Closed
    static FrontendEvent* closed ();

    //! Create a FrontendEvent with type = FrontendEventType::TouchDown
    static FrontendEvent* touchDown (float _x, float _y);

    //! Create a FrontendEvent with type = FrontendEventType::TouchMove
    static FrontendEvent* touchMove (float _x, float _y);

    //! Create a FrontendEvent with type = FrontendEventType::TouchUp
    static FrontendEvent* touchUp (float _x, float _y);

};

	
} // namespace mix

#endif // MIX_FRONTEND_H

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
        TouchCancel,
    };
} // namespace FrontendEventType

namespace FrontendMouseId
{
    enum Enum
    {
        None    = 0u,
        Left    = 1u,
        Right   = 2u,
        Middle  = 4u,
    };
} // namespace FrontendMouseId


/*! Frontend related events.
 */
class FrontendEvent : public Event
{
public:
    static EventTypeId getEventTypeId();
    static void finalize (Event* _event);

public:
    FrontendEventType::Enum type;
    
    /*! Valid only if type is one of the touch relative events.
        On Windows desktop it will be bit-flags of FrontendMouseId::Enum;
        otherwise it will be the platform specific touch object / identifier (e.g. UITouch* on iOS).
        */
    size_t touchid;

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
    static FrontendEvent* touchDown (float _x, float _y, size_t touchid);

    //! Create a FrontendEvent with type = FrontendEventType::TouchMove
    static FrontendEvent* touchMove (float _x, float _y, size_t touchid);

    //! Create a FrontendEvent with type = FrontendEventType::TouchUp
    static FrontendEvent* touchUp (float _x, float _y, size_t touchid);

    //! Create a FrontendEvent with type = FrontendEventType::TouchCancel
    static FrontendEvent* touchCancel (float _x, float _y, size_t touchid);

};

	
} // namespace mix

#endif // MIX_FRONTEND_H
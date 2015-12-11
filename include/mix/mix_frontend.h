#ifndef MIX_FRONTEND_H
#define MIX_FRONTEND_H

#include <mix/mix_event.h>
#include <mix/mix_pool.h>
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
        SwipeLeft,
        SwipeRight,
        SwipeUp,
        SwipeDown,
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

class FrontendDesc
{
public:
    enum {
        PositionCentered = -4096,
        SizeFullScreen = 0,
        SizeAuto = -1,
    };

    int left;
    int top;
    int width;
    int height;
    int msaaLevel;
    bool fullscreen;

    FrontendDesc& setLeft(int _val) {left = _val; return *this;}
    FrontendDesc& setTop(int _val) {top = _val; return *this;}
    FrontendDesc& setWidth(int _val) {width = _val; return *this;}
    FrontendDesc& setHeight(int _val) {height = _val; return *this;}
    FrontendDesc& setMsaaLevel(int _val) {msaaLevel = _val; return *this;}
    FrontendDesc& setFullScreen(bool _val) {fullscreen = _val; return *this;}

    static FrontendDesc descAuto;
    static FrontendDesc descFullScreen;
};


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
            float x, y, z, w;
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
    static FrontendEvent* touchDown (size_t _touchid, float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::TouchMove
    static FrontendEvent* touchMove (size_t _touchid, float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::TouchUp
    static FrontendEvent* touchUp (size_t _touchid, float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::TouchCancel
    static FrontendEvent* touchCancel (size_t _touchid, float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::SwipLeft
    static FrontendEvent* swipeLeft (float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::SwipLeft
    static FrontendEvent* swipeRight (float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::SwipUp
    static FrontendEvent* swipeUp (float _x, float _y, float _z, float _w);

    //! Create a FrontendEvent with type = FrontendEventType::SwipDown
    static FrontendEvent* swipeDown (float _x, float _y, float _z, float _w);
};

	
} // namespace mix

#endif // MIX_FRONTEND_H

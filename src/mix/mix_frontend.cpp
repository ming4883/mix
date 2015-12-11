#include <mix/mix_frontend.h>
#include <mix/mix_array.h>

namespace mix
{
    typedef SharedPool<FrontendEvent, 16u, 256u> FrontendEventPool;

    FrontendDesc FrontendDesc::descAuto = FrontendDesc()
        .setLeft (FrontendDesc::PositionCentered)
        .setTop (FrontendDesc::PositionCentered)
        .setWidth (FrontendDesc::SizeAuto)
        .setHeight (FrontendDesc::SizeAuto)
        .setMsaaLevel (0)
        .setFullScreen (false);
    
    FrontendDesc FrontendDesc::descFullScreen = FrontendDesc()
        .setLeft (0)
        .setTop (0)
        .setWidth (FrontendDesc::SizeFullScreen)
        .setHeight (FrontendDesc::SizeFullScreen)
        .setMsaaLevel (0)
        .setFullScreen (true);

    EventTypeId FrontendEvent::getEventTypeId()
    {
        return EventTypeId ("FrontendEvent");
    }

    void FrontendEvent::finalize (Event* _event)
    {
        if (_event->is<FrontendEvent>())
        {
            FrontendEventPool::get().delObject (static_cast<FrontendEvent*> (_event));
        }
    }

    FrontendEvent::FrontendEvent (FrontendEventType::Enum _type)
        : Event (getEventTypeId(), finalize)
        , type (_type)
        , touchid (0u)
    {
        params.location.x = 0.0f;
        params.location.y = 0.0f;
        params.size.w = 0;
        params.size.h = 0;
    }

    FrontendEvent* FrontendEvent::resized (int _w, int _h)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::Resized);
        _this->params.size.w = _w;
        _this->params.size.h = _h;
        return _this;
    }
    
    FrontendEvent* FrontendEvent::closed ()
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::Closed);
        return _this;
    }

    FrontendEvent* FrontendEvent::touchDown (size_t _touchid, float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::TouchDown);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        _this->touchid = _touchid;
        return _this;
    }

    FrontendEvent* FrontendEvent::touchMove (size_t _touchid, float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::TouchMove);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        _this->touchid = _touchid;
        return _this;
    }

    FrontendEvent* FrontendEvent::touchUp (size_t _touchid, float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::TouchUp);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        _this->touchid = _touchid;
        return _this;
    }

    FrontendEvent* FrontendEvent::touchCancel (size_t _touchid, float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::TouchCancel);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        _this->touchid = _touchid;
        return _this;
    }

    FrontendEvent* FrontendEvent::swipeLeft (float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::SwipeLeft);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        return _this;
    }

    FrontendEvent* FrontendEvent::swipeRight (float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::SwipeRight);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        return _this;
    }

    FrontendEvent* FrontendEvent::swipeUp (float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::SwipeUp);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        return _this;
    }

    FrontendEvent* FrontendEvent::swipeDown (float _x, float _y, float _z, float _w)
    {
        FrontendEvent* _this = FrontendEventPool::get().newObject (FrontendEventType::SwipeDown);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        _this->params.location.z = _z;
        _this->params.location.w = _w;
        return _this;
    }
}

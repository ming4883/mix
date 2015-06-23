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

    FrontendEvent* FrontendEvent::resized (int _w, int _h)
    {
        FrontendEvent* _this = new FrontendEvent (FrontendEventType::Resized);
        _this->params.size.w = _w;
        _this->params.size.h = _h;
        return _this;
    }
    
    FrontendEvent* FrontendEvent::closed ()
    {
        FrontendEvent* _this = new FrontendEvent (FrontendEventType::Closed);
        return _this;
    }

    FrontendEvent* FrontendEvent::touchDown (float _x, float _y)
    {
        FrontendEvent* _this = new FrontendEvent (FrontendEventType::TouchDown);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        return _this;
    }

    FrontendEvent* FrontendEvent::touchMove (float _x, float _y)
    {
        FrontendEvent* _this = new FrontendEvent (FrontendEventType::TouchMove);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        return _this;
    }

    FrontendEvent* FrontendEvent::touchUp (float _x, float _y)
    {
        FrontendEvent* _this = new FrontendEvent (FrontendEventType::TouchUp);
        _this->params.location.x = _x;
        _this->params.location.y = _y;
        return _this;
    }
}

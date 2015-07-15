#include <mix/mix_application.h>
#include <mix/mix_frontend.h>
#include <bgfx.h>
#include <math.h>

namespace example
{
    class TheApplication : public mix::Application
    {
    public:
        TheApplication()
        {
        }

        ~TheApplication()
        {
        }
        
        mix::Result init() override
        {
            bgfx::setDebug (BGFX_DEBUG_TEXT|BGFX_DEBUG_STATS);
            
            return mix::Result::ok();
        }
        
        void shutdown() override
        {
            
        }
        
        void update() override
        {
            bgfx::setViewRect (0, 0, 0, getBackbufferWidth(), getBackbufferHeight());

            float t = floorf (fmodf(getTimeSource().totalTimeInMS() * 0.25f, 256.0f));
            
            bgfx::setViewClear (0
                , BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH
                , (int (t) << 24) | 0x003030ff
                , 1.0f
                , 0
                );

            bgfx::submit (0);
            bgfx::frame ();
        }

        void handleEvent (const mix::Event* _event)
        {
            {
                const mix::FrontendEvent* _typedevt = _event->cast<mix::FrontendEvent>();
                if (nullptr != _typedevt)
                {
                    if (_typedevt->type == mix::FrontendEventType::Resized)
                    {
                        mix::Log::i ("app", "Frontend Resized");
                        bgfx::reset (_typedevt->params.size.w, _typedevt->params.size.h, BGFX_RESET_NONE);
                    }

                    if (_typedevt->type == mix::FrontendEventType::Closed)
                         mix::Log::i ("app", "Frontend Closed");
                }
            }
            {
                const mix::ApplicationEvent* _typedevt = _event->cast<mix::ApplicationEvent>();
                if (nullptr != _typedevt)
                {
                    if (_typedevt->type == mix::ApplicationEventType::Terminating)
                        mix::Log::i ("app", "Application Terminating");

                    if (_typedevt->type == mix::ApplicationEventType::LowMemory)
                        mix::Log::i ("app", "Application LowMemory");

                    if (_typedevt->type == mix::ApplicationEventType::WillEnterBackground)
                        mix::Log::i ("app", "Application WillEnterBackground");

                    if (_typedevt->type == mix::ApplicationEventType::DidEnterBackground)
                        mix::Log::i ("app", "Application DidEnterBackground");

                    if (_typedevt->type == mix::ApplicationEventType::WillEnterForeground)
                        mix::Log::i ("app", "Application WillEnterForeground");

                    if (_typedevt->type == mix::ApplicationEventType::DidEnterForeground)
                        mix::Log::i ("app", "Application DidEnterForeground");
                }
            }
        }
    };

    TheApplication* theApp = new TheApplication();
    
} // namespace example

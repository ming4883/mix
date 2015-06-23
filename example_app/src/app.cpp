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
                        bgfx::reset (_typedevt->params.size.w, _typedevt->params.size.h, BGFX_RESET_NONE);
                    }
                }
            }
        }
	};

	TheApplication* theApp = new TheApplication();
	
} // namespace example



#include <mix_entry/mix_entry.h>
#include <bgfx.h>

namespace example
{
	class TheApplication : public mix::Application
	{
	public:
		int m_state;
		
		TheApplication()
			: m_state (0)
		{
		}

        ~TheApplication()
        {
            m_state = 0;
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
			
			bgfx::setViewClear (0
				, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH
				, (m_state << 24) | 0x003030ff
				, 1.0f
				, 0
				);

			bgfx::submit (0);
			bgfx::frame ();

			m_state = (m_state + 1) % 256;
		}
	};

	TheApplication* theApp = new TheApplication();
	
} // namespace example



#include <mix_entry/mix_entry.h>

#include <memory>

namespace mix
{
	void TimeSource::reset()
	{
		m_last = (int64_t)0;
	}
	
	float TimeSource::totalTimeInMS() const
	{
		return 0;
	}
	
	float TimeSource::frameTimeInMS() const
	{
		return 0;
	}
	
	float TimeSource::frameTimeSmoothedInMS() const
	{
		return 0;
	}
	
	Result Result::ok ()
	{
		return Result (true);
	}
	
	Result Result::fail (const char* _why)
	{
		return Result (false, _why);
	}
	
	Result::Result (bool _ok, const char* _why)
		: m_ok (_ok)
		, m_why (_why)
	{
	}
	
	bool Result::isOK() const
	{
		return m_ok == true;
	}
	
	bool Result::isFail() const
	{
		return m_ok == false;
	}
	
	const char* Result::why() const
	{
		return m_why;
	}
	
	
	std::unique_ptr<Application> theApp;
	int theMainSurfaceWidth;
	int theMainSurfaceHeight;
	
	Result Application::setInstance (Application* instance)
	{
		if (theApp)
		{
			return Result::fail ("Application instance already exists!");
		}
		
		theApp.reset (instance);
		
		return Result::ok();
	}
	
	Application::Application()
	{
		
	}
	
	int Application::mainSurfaceWidth()
	{
		return theMainSurfaceWidth;
	}
	
	int Application::mainSurfaceHeight()
	{
		return theMainSurfaceHeight;
	}
}

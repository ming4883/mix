#ifndef MIX_ENTRY_H
#define MIX_ENTRY_H

#include <bx/platform.h>
#include <bx/timer.h>

namespace mix
{

class TimeSource
{
public:
	void reset();
	float totalTimeInMS() const;
	float frameTimeInMS() const;
	float frameTimeSmoothedInMS() const;
	
private:
	int64_t m_last;
};

class Result
{
public:
	static Result ok ();
	static Result fail (const char* _why);
	
	Result (bool _ok, const char* _why = nullptr);
	
	bool isOK() const;
	bool isFail() const;
	
	const char* why() const;
	
private:
	bool m_ok;
	const char* m_why;
};

class Application
{
public:
	//! Invoked when application startup
	virtual Result init() = 0;
	
	//! Invoked when application shutdown
	virtual void shutdown() = 0;
	
	//! Invoked once per frame
	virtual void update() = 0;
	
	static Result setInstance (Application* instance);
	
public:
	TimeSource appTime;

	Application();
	
	//! Return the width of the main surface
	int mainSurfaceWidth();
	
	//! Return the height of the main surface
	int mainSurfaceHeight();
};
	
} // namespace mix

#endif // MIX_ENTRY_H

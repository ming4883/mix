#ifndef MIX_ENTRY_H
#define MIX_ENTRY_H

#include <bx/platform.h>
#include <bx/timer.h>
#include <memory>
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
	static Result cleanup();

    static Application* get();

public:
	//! Invoked when application startup
	virtual Result init() = 0;
	
	//! Invoked when application shutdown
	virtual void shutdown() = 0;
	
	//! Invoked once per frame
	virtual void update() = 0;
	
public:
	TimeSource appTime;

	Application();

    void setBackbufferSize (int w, int h);
	
	//! Return the width of the main surface
	int getBackbufferWidth();
	
	//! Return the height of the main surface
	int getBackbufferHeight();

private:
    static Application* ms_inst;

    int m_backbufferWidth, m_backbufferHeight;
};

template<class APP = Application>
inline APP* theApp() { return static_cast<APP*> (Application::get()); }
	
} // namespace mix

#endif // MIX_ENTRY_H

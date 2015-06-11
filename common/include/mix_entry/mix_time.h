#ifndef MIX_TIME_H
#define MIX_TIME_H

#include <bx/timer.h>

namespace mix
{

class TimeSource
{
public:
	void reset();
    void nextFrame();
	float totalTimeInMS() const;
	float frameTimeInMS() const;
	float frameTimeSmoothedInMS() const;
	
private:
    int64_t m_offset;
    int64_t m_last;
    int64_t m_now;
    double m_toMS;
};

} // namespace mix

#endif // MIX_TIME_H

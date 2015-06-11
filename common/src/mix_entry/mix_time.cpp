#include <mix_entry/mix_time.h>

namespace mix
{
	void TimeSource::reset()
	{
        m_offset = bx::getHPCounter();
		m_last = m_offset;
        m_now = m_offset;

        m_toMS = 1000.0 / bx::getHPFrequency();
	}

    void TimeSource::nextFrame()
    {
        m_last = m_now;
        m_now = bx::getHPCounter();
    }
	
	float TimeSource::totalTimeInMS() const
	{
        return (float)((m_now - m_offset) * m_toMS);
	}
	
	float TimeSource::frameTimeInMS() const
	{
		return (float)((m_now - m_last) * m_toMS);
	}
	
	float TimeSource::frameTimeSmoothedInMS() const
	{
		return frameTimeInMS();
	}
}

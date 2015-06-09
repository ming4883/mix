#ifndef MIX_EVENT_H
#define MIX_EVENT_H

#include <bx/platform.h>
#include <functional>

#include <mix_entry/mix_result.h>
#include <mix_entry/mix_hash_fnv.h>

namespace mix
{

class Event
{
public:
    typedef std::function<void (Event*)> Finalizer;

public:
    HashFNV32 type;

    Event (HashFNV32 _type, Finalizer _finalizer);

protected:
    Finalizer m_finalizer;
    Event* m_next;

};

class EventQueue
{
public:
    EventQueue();

    Result enqueue (Event* _event);

    Event* dequeue();

private:
    Event* m_head;
};
	
} // namespace mix

#endif // MIX_EVENT_H

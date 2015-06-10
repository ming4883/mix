#ifndef MIX_EVENT_H
#define MIX_EVENT_H

#include <bx/platform.h>
#include <bx/Mutex.h>

#include <functional>

#include <mix_entry/mix_result.h>
#include <mix_entry/mix_hash_fnv.h>

namespace mix
{

typedef HashFNV32 EventTypeId;
typedef std::function<void (class Event*)> EventFinalizer;

class Event
{
public:
    EventTypeId typeId;

    Event (EventTypeId _typeId, EventFinalizer _finalizer);

protected:
    EventFinalizer m_finalizer;
    Event* m_next;

};

class EventQueue
{
public:
    EventQueue();

    ~EventQueue();

    //! Push an Event to the end of the queue, the ownership of the Event is transferred to the queue.
    Result push (Event* _event);

    //! Return the Event in front of the queue. Return nullptr if the queue is empty.
    const Event* peek();

    //! Remove and destroy in front of the queue.
    Result discard();

    //! Returns true if there is no queued Event.
    bool isEmpty() const;

private:
    Event* m_head;

    mutable bx::Mutex m_mutex;
};
	
} // namespace mix

#endif // MIX_EVENT_H

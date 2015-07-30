#ifndef MIX_EVENT_H
#define MIX_EVENT_H

#include <bx/platform.h>
#include <bx/Mutex.h>

#include <functional>

#include <mix/mix_result.h>
#include <mix/mix_hash_fnv.h>

namespace mix
{

typedef HashFNV32 EventTypeId;
typedef std::function<void (class Event*)> EventFinalizer;

class Event
{
public:
    static void finalize (Event* _event);

    const EventTypeId typeId;

    Event (EventTypeId _typeId, EventFinalizer _finalizer);
    
    template<typename T>
    bool is() const
    {
        return typeId == T::getEventTypeId();
    }

    template<typename T>
    const T* cast() const
    {
        if (typeId != T::getEventTypeId())
            return nullptr;

        return static_cast<const T*> (this);
    }

protected:
    friend class EventQueue;

    EventFinalizer m_finalizer;
    Event* m_next;

    virtual ~Event();
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

    //! Remove all Event objects in the queue.
    Result discardAll();

    //! Returns true if there is no queued Event.
    bool isEmpty() const;

private:
    Event* m_head;
    Event* m_tail;

    mutable bx::Mutex m_mutex;
};
	
} // namespace mix

#endif // MIX_EVENT_H

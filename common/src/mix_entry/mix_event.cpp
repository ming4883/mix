#include <mix_entry/mix_event.h>

namespace mix
{

    Event::Event (EventTypeId _typeId, EventFinalizer _finalizer)
        : typeId (_typeId)
        , m_finalizer (_finalizer)
        , m_next (nullptr)
    {
    }

    EventQueue::EventQueue()
        : m_head (nullptr)
    {
        bx::MutexScope ms (m_mutex);
    }

    EventQueue::~EventQueue()
    {
        bx::MutexScope ms (m_mutex);
    }

    Result EventQueue::push (Event* _event)
    {
        bx::MutexScope ms (m_mutex);

        return Result::ok();
    }

    const Event* EventQueue::peek()
    {
        bx::MutexScope ms (m_mutex);

        return nullptr;
    }

    Result EventQueue::discard()
    {
        bx::MutexScope ms (m_mutex);

        return Result::ok();
    }

    bool EventQueue::isEmpty() const
    {
        bx::MutexScope ms (m_mutex);

        return m_head == nullptr;
    }

}

#include <mix_entry/mix_event.h>

#include <assert.h>

namespace mix
{
    Event::Event (EventTypeId _typeId, EventFinalizer _finalizer)
        : typeId (_typeId)
        , m_finalizer (_finalizer)
        , m_next (nullptr)
    {
    }

    Event::~Event()
    {
    }

    EventQueue::EventQueue()
        : m_head (nullptr)
        , m_tail (nullptr)
    {
        bx::MutexScope ms (m_mutex);
    }

    EventQueue::~EventQueue()
    {
        bx::MutexScope ms (m_mutex);
    }

    Result EventQueue::push (Event* _event)
    {
        if (nullptr == _event)
            return Result::fail ("_event is nullptr");

        bx::MutexScope ms (m_mutex);

        if (nullptr == m_head)
        {
            assert (m_head == m_tail);
            m_head = _event;
            m_tail = _event;
        }
        else
        {
            m_tail->m_next = _event;
            m_tail = _event;
        }

        return Result::ok();
    }

    const Event* EventQueue::peek()
    {
        bx::MutexScope ms (m_mutex);

        return m_head;
    }

    Result EventQueue::discard()
    {
        bx::MutexScope ms (m_mutex);

        if (nullptr == m_head)
            return Result::ok();

        Event* curr = m_head;

        if (m_head == m_tail)
        {
            m_head = nullptr;
            m_tail = nullptr;
        }
        else
        {
            Event* beforeTail = m_head;
            while (beforeTail->m_next != m_tail)
                beforeTail = beforeTail->m_next;
            
            m_tail = beforeTail;
        }

        if (curr->m_finalizer)
            curr->m_finalizer (curr);

        return Result::ok();
    }

    bool EventQueue::isEmpty() const
    {
        bx::MutexScope ms (m_mutex);

        return m_head == nullptr;
    }

}

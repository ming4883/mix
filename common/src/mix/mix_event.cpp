#include <mix/mix_event.h>

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

    void Event::finalize (Event* _event)
    {
        if (_event && _event->m_finalizer)
            _event->m_finalizer (_event);
    }

    EventQueue::EventQueue()
        : m_head (nullptr)
        , m_tail (nullptr)
    {
        bx::MutexScope ms (m_mutex);
    }

    EventQueue::~EventQueue()
    {
        discardAll();
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
            m_head = m_head->m_next;
        }

        Event::finalize (curr);

        return Result::ok();
    }

    Result EventQueue::discardAll()
    {
        bx::MutexScope ms (m_mutex);

        Event* curr = m_head;

        while (curr) {
            Event* next = curr->m_next;

            Event::finalize (curr);

            curr = next;
        }

        m_head = nullptr;
        m_tail = nullptr;

        return Result::ok();
    }

    bool EventQueue::isEmpty() const
    {
        bx::MutexScope ms (m_mutex);

        return m_head == nullptr;
    }

}

#if defined (MIX_TESTS)
#   include "mix_event.tests.inl"
#endif

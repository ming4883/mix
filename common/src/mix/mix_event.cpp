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
            m_head = m_head->m_next;
        }

        Event::finalize (curr);

        return Result::ok();
    }

    bool EventQueue::isEmpty() const
    {
        bx::MutexScope ms (m_mutex);

        return m_head == nullptr;
    }

}

#if defined (MIX_TESTS)

#include <mix/mix_tests.h>

class TestsOfEvent : public ::testing::Test
{
public:
    class TestEvent : public mix::Event
    {
    public:
        int name;

        static mix::EventTypeId getEventTypeId()
        {
            return mix::EventTypeId ("Test");
        }

        static void finalizer (Event* _event)
        {
            delete static_cast<TestEvent*> (_event);
        }

        TestEvent (int _name)
            : mix::Event (getEventTypeId(), finalizer)
            , name (_name)
        {
        }
    };

    TestsOfEvent()
    {
    }

    void SetUp() override
    {
    }

    void TearDown() override
    {
    }
};

TEST_F (TestsOfEvent, Event_Operations)
{
    TestEvent* e = new TestEvent(0);

    EXPECT_TRUE (e->is<TestEvent>());

    EXPECT_NE (nullptr, e->cast<TestEvent>());

    mix::Event::finalize (e);

}

TEST_F (TestsOfEvent, EventQueue_Operations)
{
    mix::EventQueue queue;

    EXPECT_TRUE (queue.isEmpty());

    queue.push (new TestEvent(1));
    EXPECT_FALSE (queue.isEmpty());

    queue.push (new TestEvent(2));
    EXPECT_FALSE (queue.isEmpty());

    EXPECT_TRUE (queue.peek()->is<TestEvent>());

    {
        const TestEvent* e = queue.peek()->cast<TestEvent>();
        EXPECT_EQ (1, e->name);
    }
    
    // discard 1
    EXPECT_TRUE (queue.discard().isOK());
    EXPECT_FALSE (queue.isEmpty());

    {
        const TestEvent* e = queue.peek()->cast<TestEvent>();
        EXPECT_EQ (2, e->name);
    }

    // discard 2
    EXPECT_TRUE (queue.discard().isOK());
    EXPECT_TRUE (queue.isEmpty());
}

#endif

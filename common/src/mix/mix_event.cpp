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

#include <mix/mix_tests.h>
#include <bx/thread.h>

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

    // Push 2 events
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

    // Push 2 events again
    queue.push (new TestEvent(1));
    queue.push (new TestEvent(2));
    EXPECT_FALSE (queue.isEmpty());

    queue.discardAll();
    EXPECT_TRUE (queue.isEmpty());
}

TEST_F (TestsOfEvent, EventQueue_Multithread)
{
    struct Local
    {
        enum { CNT = 1024 };

        static int32_t task (void* _userData)
        {
            mix::EventQueue* queue = static_cast<mix::EventQueue*> (_userData);

            for (int i = 0; i < CNT; ++i)
            {
                queue->push (new TestEvent (i));
                bx::yield();
            }

            return 0;
        }
    };
    mix::EventQueue queue;

    EXPECT_TRUE (queue.isEmpty());

    bx::Thread t1, t2;
    t1.init (Local::task, &queue);
    t2.init (Local::task, &queue);
    
    int cnt = 0;
    while (cnt < Local::CNT * 2)
    {
        if (queue.peek() != nullptr)
        {
            queue.discard();
            ++cnt;
        }
    }

    EXPECT_TRUE (queue.isEmpty());

}

#endif

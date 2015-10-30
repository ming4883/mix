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
    enum { CNT = 1024 };

    auto _lambda = [] (void* _userData)
    {
        mix::EventQueue* _queue = static_cast<mix::EventQueue*> (_userData);

        for (int i = 0; i < CNT; ++i)
        {
            _queue->push (new TestEvent (i));
            bx::yield();
        }

        return 0u;
    };

    mix::EventQueue _queue;
    EXPECT_TRUE (_queue.isEmpty());


    mix::ThreadWithLambda _t1 (std::move (_lambda)), _t2 (std::move (_lambda));
    _t1.init (&_queue, 0u, "EventQueue_Multithread_t1");
    _t2.init (&_queue, 0u, "EventQueue_Multithread_t2");

    int _cnt = 0;
    while (_cnt < CNT * 2)
    {
        if (_queue.peek() != nullptr)
        {
            _queue.discard();
            ++_cnt;
        }
    }

    EXPECT_TRUE (_queue.isEmpty());

}

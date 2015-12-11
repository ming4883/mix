#include <mix/mix_tests.h>
#include <mix/mix_string.h>

#include <string>

class TestsOfPool : public ::testing::Test
{
public:

    struct Object
    {
        std::string data;

        Object (std::string&& _data)
            : data (std::move (_data))
        {
        }
    };

    struct ObjectPoolTraits : public mix::PoolTraitsDefault<Object>
    {
    };

    typedef mix::Pool<ObjectPoolTraits> ObjectPool;
    
    TestsOfPool()
    {
    }

    void SetUp() override
    {
    }

    void TearDown() override
    {
    }
};

TEST_F (TestsOfPool, Pool_Basic)
{
    mix::AllocatorCrt<16> _alloc;

    ObjectPool* _pool = mix_new<ObjectPool> (_alloc, 2u, 2u);

    // create the 1st and 2nd object
    Object* _obj1 = _pool->newObject ("123");
    Object* _obj2 = _pool->newObject ("234");

    // verify contents
    EXPECT_EQ ("123", _obj1->data);
    EXPECT_EQ ("234", _obj2->data);

    EXPECT_TRUE (_pool->delObject (_obj1)); // destroy
    EXPECT_TRUE (_pool->delObject (_obj2));

    //create the 3nd and 4th object, they should be reusing the memory allocated for obj1 and obj2
    Object* _obj3 = _pool->newObject ("345");
    Object* _obj4 = _pool->newObject ("456");
    
    EXPECT_EQ (_obj1, _obj4);
    EXPECT_EQ (_obj2, _obj3);

    EXPECT_EQ ("345", _obj3->data);
    EXPECT_EQ ("456", _obj4->data);

    EXPECT_TRUE (_pool->delObject (_obj3));
    EXPECT_TRUE (_pool->delObject (_obj4));

    mix_del (_alloc, _pool);
}

TEST_F (TestsOfPool, Pool_AllocateNewNodes)
{
    mix::AllocatorCrt<16> _alloc;

    ObjectPool* _pool = mix_new<ObjectPool> (_alloc, 2u, 128u);

    for (int i = 0; i < 256; ++i)
    {
        _pool->newObject ("");
    }

    // allocated objects would be cleaned up by the pool automatically.
    mix_del (_alloc, _pool);
}

TEST_F (TestsOfPool, Pool_Foreach)
{
    mix::AllocatorCrt<16> _alloc;
    mix::StringFormatter _sfmt;

    ObjectPool* _pool = mix_new<ObjectPool> (_alloc, 2u, 128u);

    for (int i = 0; i < 256; ++i)
        _pool->newObject (_sfmt.format("%d", i));

    int _counter = 0;

    // verify the data
    _pool->foreach ([&_counter, &_sfmt](Object* _obj){
        EXPECT_EQ (_sfmt.format("%d", _counter), _obj->data);
        _counter++;
        return true;
    });

    EXPECT_EQ (256, _counter);

    // try iterating with the first 128 objects
    _counter = 0;

    _pool->foreach ([&_counter](Object* ){
        _counter++;
        return _counter < 128;
    });

    EXPECT_EQ (128, _counter);

    // clean up
    mix_del (_alloc, _pool);
}

TEST_F (TestsOfPool, Pool_DeleteAllObjects)
{
    mix::AllocatorCrt<16> _alloc;
    mix::StringFormatter _sfmt;

    ObjectPool* _pool = mix_new<ObjectPool> (_alloc, 2u, 128u);
    const int N = 64;

    Object* _allocated[N];

    for (int i = 0; i < N; ++i)
        _allocated[i] = _pool->newObject (_sfmt.format("%d", i));

    // delete the first, the middle, and the last object manually
    _pool->delObject(_allocated[0]);
    _pool->delObject(_allocated[N-1]);
    _pool->delObject(_allocated[N/2]);
    EXPECT_EQ (N-3, _pool->delAllObjects());

    for (int i = 0; i < N; ++i)
         _allocated[i] = _pool->newObject (_sfmt.format("%d", i));

    // verify allocation has the same order as foreach
    int _counter = 0;

    _pool->foreach ([&_counter, &_allocated](Object* _obj){
        EXPECT_EQ (_allocated[_counter], _obj);
        _counter++;
        return true;
    });

    EXPECT_EQ(N, _counter);

    // clean up
    mix_del (_alloc, _pool);
}

TEST_F (TestsOfPool, Pool_MultiThreaded)
{
    mix::AllocatorCrt<16> _alloc;
    
    ObjectPool* _pool = mix_new<ObjectPool> (_alloc, 2u, 128u);

    enum { CNT = 1024 };

    auto _lambda = [&_pool] (void* _userData)
    {
        mix::StringFormatter _sfmt;

        for (int i = 0; i < CNT; ++i)
        {
             _pool->newObject (_sfmt.format("%d", i));
            bx::yield();
        }

        return 0u;
    };

    mix::ThreadWithLambda _t1 (std::move (_lambda)), _t2 (std::move (_lambda));
    _t1.init (nullptr, 0u, "Pool_MultiThreaded_t1");
    _t2.init (nullptr, 0u, "Pool_MultiThreaded_t2");

    _t1.shutdown();
    _t2.shutdown();

    EXPECT_EQ (CNT * 2, _pool->getObjectCount());

    // clean up
    mix_del (_alloc, _pool);
}

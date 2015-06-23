#include <mix/mix_tests.h>


class TestsOfBuffer : public ::testing::Test
{
public:
    
    TestsOfBuffer()
    {
    }

    void SetUp() override
    {
    }

    void TearDown() override
    {
    }
};

TEST_F (TestsOfBuffer, Buffer_Uninitialized)
{
    mix::Buffer b;
    
    EXPECT_TRUE (b.isEmpty());

    EXPECT_EQ (0, b.size());

    EXPECT_EQ (nullptr, b.ptr());
}

TEST_F (TestsOfBuffer, Buffer_Resize)
{
    const uint32_t N1 = 10;
    const uint32_t N2 = 20;
    {
        mix::Buffer b;

        b.resize (N1);
        EXPECT_EQ (N1, b.size());

        for (uint32_t i = 0; i < N1; ++i)
            b.ptr()[i] = (uint8_t)i;

        b.resize (N2);
        EXPECT_EQ (N2, b.size());

        for (uint32_t i = 0; i < N1; ++i)
            EXPECT_EQ ((uint8_t)i, b.ptr()[i]);

        for (uint32_t i = 0; i < N2; ++i)
            b.ptr()[i] = (uint8_t)i;
    }
    
    {
        mix::Buffer b (N1);

        EXPECT_EQ (N1, b.size());

        for (uint32_t i = 0; i < N1; ++i)
            b.ptr()[i] = (uint8_t)i;

        b.resize (N2);
        EXPECT_EQ (N2, b.size());

        for (uint32_t i = 0; i < N1; ++i)
            EXPECT_EQ ((uint8_t)i, b.ptr()[i]);

        for (uint32_t i = 0; i < N2; ++i)
            b.ptr()[i] = (uint8_t)i;
    }
}

TEST_F (TestsOfBuffer, Buffer_Copy)
{
    const uint32_t N = 10;

    mix::Buffer b1 (N);

    for (uint32_t i = 0; i < N; ++i)
        b1.ptr()[i] = (uint8_t)i;

    mix::Buffer b2 (b1);

    // b1 and b2 should now have same size and contents
    EXPECT_EQ (N, b1.size());
    EXPECT_EQ (N, b2.size());

    for (uint32_t i = 0; i < N; ++i)
    {
        EXPECT_EQ (b1.ptr()[i], b2.ptr()[i]);
    }
}


TEST_F (TestsOfBuffer, Buffer_Move)
{
    const uint32_t N = 10;

    mix::Buffer b1 (N);

    for (uint32_t i = 0; i < N; ++i)
        b1.ptr()[i] = (uint8_t)i;

    mix::Buffer b2 (std::move (b1));

    // b1 should now be empty
    EXPECT_EQ (0, b1.size());
    EXPECT_EQ (N, b2.size());

    for (uint32_t i = 0; i < N; ++i)
    {
        EXPECT_EQ ((uint8_t)i, b2.ptr()[i]);
    }
}

#include <mix/mix_tests.h>

class TestsOfTransform : public ::testing::Test
{
public:
    
    TestsOfTransform()
    {
    }

    void SetUp() override
    {
    }

    void TearDown() override
    {
    }
};

TEST_F (TestsOfTransform, Transform_Identity)
{
    const float _000[] = {0, 0, 0};
    const float _0001[] = {0, 0, 0, 1};
    const float _111[] = {1, 1, 1};

    mix::Transform _t = mix::Transform::cIdentity;
    ::ArraysMatch (_t.position, _000);
    ::ArraysMatch (_t.orientation, _0001);
    ::ArraysMatch (_t.scale, _111);
}

TEST_F (TestsOfTransform, Transform_TransformPoint)
{
    {
        mix::Transform _t(
            0, 1, 0,
            0, 0, 0, 1,
            1, 1, 1);

        float _pt[] = {0, 0, 0};
        _t.transformPoint (_pt);

        const float _[] = {0, 1, 0};
        ::ArraysMatch (_t.position, _);
    }
    
}

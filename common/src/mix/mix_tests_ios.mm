#if defined (MIX_IOS) && defined (MIX_TESTS)

#include <mix/mix_tests.h>

#import <iostream>

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        if (_isError)
            std::cerr << _msg.str() << std::endl;
        else
            std::cout << _msg.str() << std::endl;
    }
}

int main (int _argc, char* _argv[])
{
    ::testing::InitGoogleTest (&_argc, _argv);

    ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

    return RUN_ALL_TESTS();
}

#endif // #if defined (MIX_IOS) && defined (MIX_TESTS)


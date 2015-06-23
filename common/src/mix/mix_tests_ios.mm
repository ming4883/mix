#if defined (MIX_IOS) && defined (MIX_TESTS)

#include <mix/mix_tests.h>
#include <mix/mix_log.h>

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
    mix::Log::init();

    ::testing::InitGoogleTest (&_argc, _argv);

    ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

    int result = RUN_ALL_TESTS();
    mix::Log::final();
    
    return result;
}

#endif // #if defined (MIX_IOS) && defined (MIX_TESTS)


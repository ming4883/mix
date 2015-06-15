#if defined (MIX_WINDOWS_DESKTOP)

#include <mix/mix_tests.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        OutputDebugString (_msg.str().c_str());
    }
}

GTEST_API_ int main (int _argc, char* _argv[])
{
#if _DEBUG
    _CrtSetDbgFlag (_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
    _CrtSetBreakAlloc (-1);
#endif

    ::testing::InitGoogleTest (&_argc, _argv);

    ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

    return RUN_ALL_TESTS();
}

#endif // #if defined (MIX_WINDOWS_DESKTOP)

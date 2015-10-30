#if defined (MIX_ANDROID)

#include <mix/mix_tests.h>
#include <mix/mix_log.h>

#include <jni.h>
#include <android/log.h>

#define LOG_TAG "org_mix_unittests"

class JNILogger
{
public:
    JNIEnv* env;
    jobject obj;
    jclass cls;
    jmethodID mth;

    JNILogger()
        : env (nullptr)
        , obj (nullptr)
        , cls (nullptr)
        , mth (nullptr)
    {

    }

    ~JNILogger()
    {
    }

    void init (JNIEnv* _env, jobject _obj)
    {
        env = _env;
        obj = env->NewGlobalRef (_obj);
        cls = env->GetObjectClass (obj);
        mth = env->GetMethodID (cls, "appendLog", "(ZLjava/lang/String;)V");

        if (!mth)
            mix::Log::e (LOG_TAG, "JNILogger method not found!");
    }

    void shutdown()
    {
        env->DeleteGlobalRef (obj);
    }

    void appendLog (bool _isError, mix::TestListener::Stream& _msg)
    {
        if (mth)
        {
            jobject _jmsg = env->NewStringUTF (_msg.str().c_str());
            env->CallVoidMethod (obj, mth, (jboolean)_isError, _jmsg);
            env->DeleteLocalRef (_jmsg);
        }
    }

    static JNILogger inst;
};

JNILogger JNILogger::inst;

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        JNILogger::inst.appendLog (_isError, _msg);

        if (_isError)
            mix::Log::e (LOG_TAG, _msg.str().c_str());
        else
            mix::Log::i (LOG_TAG, _msg.str().c_str());
    }
}

#define JNIMETHOD(type, method) JNIEXPORT type JNICALL Java_org_mix_unittests_TestsActivity_ ## method

// JNI native method
extern "C" {
    
    JNIMETHOD (void, handleExecute) (JNIEnv* env, jobject obj)
    {
        mix::Log::init();

        JNILogger::inst.init (env, obj);

        int argc = 0;
        char** argv = nullptr;
        ::testing::InitGoogleTest (&argc, argv);

        ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

        int result = RUN_ALL_TESTS();
        (void)result;

        JNILogger::inst.shutdown ();

        mix::Log::shutdown();
    }
}

#endif // #if defined (MIX_ANDROID)

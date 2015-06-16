#if defined (MIX_ANDROID)

#include <mix/mix_tests.h>

#include <jni.h>
#include <android/log.h>

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
            logE ("JNILogger method not found!");
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

        if (_isError)
            logE (_msg.str().c_str());
        else
            logI (_msg.str().c_str());
    }

    static JNILogger inst;

private:

    static void logI (const char* msg)
    {
        __android_log_print (ANDROID_LOG_INFO, "mix", "%s", msg);
    }

    static void logE (const char* msg)
    {
        __android_log_print (ANDROID_LOG_ERROR, "mix", "%s", msg);
    }
};

JNILogger JNILogger::inst;

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        JNILogger::inst.appendLog (_isError, _msg);
    }
}

#define JNIMETHOD(type, method) JNIEXPORT type JNICALL Java_org_mix_common_TestsActivity_ ## method

// JNI native method
extern "C" {
    
    JNIMETHOD (void, handleExecute) (JNIEnv* env, jobject obj)
    {
        JNILogger::inst.init (env, obj);

        int argc = 0;
        char** argv = nullptr;
        ::testing::InitGoogleTest (&argc, argv);

        ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

        int result = RUN_ALL_TESTS();
        (void)result;

        JNILogger::inst.shutdown ();
    }
}

#endif // #if defined (MIX_ANDROID)

#if defined (MIX_ANDROID)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <jni.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>

#define JNIMETHOD(type, method)	JNIEXPORT type JNICALL Java_org_mix_common_BaseActivity_00024NativeCode_ ## method

// JNI native method
extern "C" {
    
    JNIMETHOD (void, handleInit) (JNIEnv* env, jobject cls)
    {
        mix::Log::init();

        bgfx::PlatformData pd;
        pd.ndt				= NULL;
        pd.nwh    			= NULL;
        pd.context      	= eglGetCurrentContext();
        pd.backBuffer   	= NULL;
        pd.backBufferDS 	= NULL;
        bgfx::setPlatformData (pd);

        mix::Log::i ("app", "bgfx::renderFrame");
        bgfx::renderFrame();

        mix::Log::i ("app", "bgfx::init");
        bgfx::init();

        if (!mix::theApp())
        {
            mix::Log::e ("app", "no mix::Application was created!");
            return;
        }

        mix::theApp()->preInit();
        mix::Result ret = mix::theApp()->init();
        if (ret.isFail())
        {
            mix::Log::e ("app", "mix::theApp.init() failed: %s", ret.why());
        }
        
        mix::theApp()->postInit();
    }
    
    JNIMETHOD (void, handleUpdate) (JNIEnv* env, jobject cls)
    {
        if (mix::theApp())
        {
            mix::theApp()->preUpdate();
            mix::theApp()->update();
            mix::theApp()->postUpdate();
        }
    }
    
    JNIMETHOD (void, handleQuit) (JNIEnv* env, jobject cls)
    {
        if (mix::theApp())
        {
            mix::theApp()->preShutdown();
            mix::theApp()->shutdown();
            mix::Application::cleanup();
            mix::theApp()->postShutdown();
        }
        
        mix::Log::i ("app", "bgfx::shutdown");
        mix::Log::shutdown();
        bgfx::shutdown();
    }

    JNIMETHOD (void, handleFrontendEvent) (JNIEnv* env, jobject cls, jint evt, jfloat param0, jfloat param1)
    {
        if (evt == mix::FrontendEventType::Resized)
        {
            mix::theApp()->setBackbufferSize ((int)param0, (int)param1);
            mix::theApp()->pushEvent (mix::FrontendEvent::resized ((int)param0, (int)param1));
        }

        //mix::theApp()->processQueuedEvents();
    }

    
    JNIMETHOD (void, handleApplicationEvent) (JNIEnv* env, jobject cls, jint evt)
    {
        if (evt == mix::ApplicationEventType::Terminating)
            mix::theApp()->pushEvent (mix::ApplicationEvent::terminating());

        if (evt == mix::ApplicationEventType::LowMemory)
            mix::theApp()->pushEvent (mix::ApplicationEvent::lowMemory());

        if (evt == mix::ApplicationEventType::WillEnterBackground)
            mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterBackground());

        if (evt == mix::ApplicationEventType::DidEnterBackground)
            mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterBackground());

        if (evt == mix::ApplicationEventType::WillEnterForeground)
            mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterForeground());

        if (evt == mix::ApplicationEventType::DidEnterForeground)
            mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterForeground());

        mix::theApp()->processQueuedEvents();
    }
}

#endif // #if defined (MIX_ANDROID)

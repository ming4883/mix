#if defined (MIX_ANDROID)

#include <mix/mix_application.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <jni.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>

/*
#include <android/log.h>
void logI (const char* msg)
{
	__android_log_print (ANDROID_LOG_INFO, "bgfx", "%s", msg);
}

template<typename... Args>
void logI (const char* fmt, Args&&... args)
{
	__android_log_print (ANDROID_LOG_INFO, "bgfx", fmt, args...);
}
*/

#define JNIMETHOD(type, method)	JNIEXPORT type JNICALL Java_org_mix_common_BaseActivity_00024NativeCode_ ## method

// JNI native method
extern "C" {
	
	JNIMETHOD (void, handleInit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
        mix::Log::init();

		mix::Log::i ("app", "%d, %d", surfaceWidth, surfaceHeight);

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

		mix::Log::i ("app", "bgfx::reset");
		bgfx::reset (surfaceWidth, surfaceHeight, BGFX_RESET_NONE);
		
		if (!mix::theApp())
		{
			mix::Log::e ("app", "no mix::Application was created!");
			return;
		}

		mix::theApp()->setBackbufferSize ((int)surfaceWidth, (int)surfaceHeight);
		mix::theApp()->preInit();
		mix::Result ret = mix::theApp()->init();
		if (ret.isFail()) {
			mix::Log::e ("app", "mix::theApp.init() failed: %s", ret.why());
		}
		
		mix::theApp()->postInit();
	}
	
	JNIMETHOD (void, handleUpdate) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		if (mix::theApp())
		{
			mix::theApp()->setBackbufferSize ((int)surfaceWidth, (int)surfaceHeight);
			mix::theApp()->preUpdate();
			mix::theApp()->update();
			mix::theApp()->postUpdate();
		}
	}
	
	JNIMETHOD (void, handleQuit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
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
}

#endif // #if defined (MIX_ANDROID)

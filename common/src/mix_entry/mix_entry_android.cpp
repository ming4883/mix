#include <mix_entry/mix_entry.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <jni.h>
#include <android/log.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>

#include <memory>

namespace mix
{
	extern std::unique_ptr<Application> theApp;
	extern int theMainSurfaceWidth;
	extern int theMainSurfaceHeight;
	
} // namespace mix

void logI (const char* msg)
{
	__android_log_print (ANDROID_LOG_INFO, "bgfx", "%s", msg);
}

template<typename... Args>
void logI (const char* fmt, Args&&... args)
{
	__android_log_print (ANDROID_LOG_INFO, "bgfx", fmt, args...);
}

#define JNIMETHOD(type, method)	JNIEXPORT type JNICALL Java_org_mix_common_BaseActivity_00024NativeCode_ ## method

// JNI native method
extern "C" {
	
	JNIMETHOD (void, handleInit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		logI ("%d, %d", surfaceWidth, surfaceHeight);

		bgfx::PlatformData pd;
		pd.ndt				= NULL;
		pd.nwh    			= NULL;
		pd.context      	= eglGetCurrentContext();
		pd.backBuffer   	= NULL;
		pd.backBufferDS 	= NULL;
		bgfx::setPlatformData (pd);

		logI ("bgfx::renderFrame");
		bgfx::renderFrame();

		logI ("bgfx::init");
		bgfx::init();

		logI ("bgfx::reset");
		bgfx::reset (surfaceWidth, surfaceHeight, BGFX_RESET_NONE);
		
		if (!mix::theApp)
		{
			logI ("mix::theApp is nullptr!");
			return;
		}

		mix::Result ret = mix::theApp->init();
		if (ret.isFail()) {
			logI ("mix::theApp.init() failed: %s", ret.why());
		}
	}
	
	JNIMETHOD (void, handleUpdate) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		mix::theMainSurfaceWidth = (int)surfaceWidth;
		mix::theMainSurfaceHeight = (int)surfaceHeight;
		
		if (mix::theApp)
		{
			mix::theApp->update();
		}
	}
	
	JNIMETHOD (void, handleQuit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		if (mix::theApp)
		{
			mix::theApp->shutdown();
		}
		
		mix::theApp.reset();
		
		logI ("bgfx::shutdown");
		bgfx::shutdown();
	}
}
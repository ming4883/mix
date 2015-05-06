#include <bgfx.h>
#include <bgfxplatform.h>


#include <jni.h>
#include <android/log.h>
#include <android/native_window_jni.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>

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

	const int k_swapId = 0;
	
	JNIMETHOD (void, handleInit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		logI ("%d, %d", surfaceWidth, surfaceHeight);

		
		bgfx::PlatformData pd;
		pd.ndt				= NULL;
		pd.nwh    			= NULL;
		pd.context      	= eglGetCurrentContext();
		//pd.backBuffer   	= NULL;
		//pd.backBufferDS 	= NULL;
		bgfx::setPlatformData (pd);

		logI ("renderFrame");
		bgfx::renderFrame();

		logI ("init");
		bgfx::init ();

		logI ("reset");
		bgfx::reset (surfaceWidth, surfaceHeight, BGFX_RESET_NONE);

		bgfx::setDebug (BGFX_DEBUG_TEXT|BGFX_DEBUG_STATS);
	}
	
	JNIMETHOD (void, handleUpdate) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		static int s_state = 0;
		bgfx::setViewRect (k_swapId, 0, 0, surfaceWidth, surfaceHeight);
		
		bgfx::setViewClear (k_swapId
			, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH
			, (s_state << 24) | 0x003030ff
			, 1.0f
			, 0
			);

		bgfx::submit (k_swapId);
		bgfx::frame ();

		s_state = (s_state + 1) % 256;
	}
	
	JNIMETHOD (void, handleQuit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		logI ("quit");	
		bgfx::shutdown ();
	}
}
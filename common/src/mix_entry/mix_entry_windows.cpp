#include <mix_entry/mix_entry.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <Windows.h>

#inclue <memory>

namespace mix
{
	extern std::owned_ptr<Application> theApp;
	extern int theMainSurfaceWidth;
	extern int theMainSurfaceHeight;
	
} // namespace mix



#define WNDCLASSNAME "eglWindow"

LRESULT WINAPI windowMsgProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg)
    {
        case WM_CLOSE: {
            PostQuitMessage (0);
            break;
        }
    }

    return DefWindowProc(hWnd, msg, wParam, lParam);
}


class Frontend
{
public:
    HWND window;
    HDC display;

    bool init (const char* name, int w, int h)
    {
        WNDCLASSEXA wndCls = {0};
        
        DWORD dwExStyle = WS_EX_APPWINDOW;
        DWORD dwStyle = WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU;

        RECT rect;
        
        int windowWidth, windowHeight, windowLeft, windowTop;

        // create window
        wndCls.cbSize = sizeof (WNDCLASSEXA);
        wndCls.style = CS_OWNDC;
        wndCls.lpfnWndProc = windowMsgProc;
        wndCls.cbClsExtra = 0;
        wndCls.cbWndExtra = 0;
        wndCls.hInstance = GetModuleHandle (nullptr);
        wndCls.hIcon = NULL;
        wndCls.hCursor = LoadCursorA (NULL, IDC_ARROW);
        wndCls.hbrBackground = 0;
        wndCls.lpszMenuName = NULL;
        wndCls.lpszClassName = WNDCLASSNAME;
        
        if (!RegisterClassExA (&wndCls))
            return false;

        windowWidth = w;
        windowHeight = h;
        SetRect( &rect, 0, 0, windowWidth, windowHeight );
        AdjustWindowRectEx(&rect, dwStyle, FALSE, dwExStyle);
    
        windowWidth = rect.right - rect.left;
        windowHeight = rect.bottom - rect.top;

        windowLeft = GetSystemMetrics (SM_CXSCREEN) / 2 - windowWidth / 2;
        windowTop  = GetSystemMetrics (SM_CYSCREEN) / 2 - windowHeight / 2;

        window = CreateWindowExA (dwExStyle, WNDCLASSNAME, name, dwStyle, windowLeft, windowTop, windowWidth, windowHeight, nullptr, nullptr, GetModuleHandle (nullptr), 0);
        SetWindowTextA (window, name);

        display = GetDC (window);

        ShowWindow (window, SW_SHOW);

        return true;
    }

    bool step ()
    {
        MSG msg = {0};

        while (PeekMessage (&msg, 0, 0, 0, PM_REMOVE))
        {
            TranslateMessage (&msg);
            DispatchMessage (&msg);
        }

        return msg.message != WM_QUIT;
    }

    void final ()
    {
        ReleaseDC (window, display);
        DestroyWindow (window);
        UnregisterClassA (WNDCLASSNAME, NULL);
    }
};

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

		mix::Result ret = mix::theApp.init();
		if (!ret) {
			logI ("mix::theApp.init() failed: %s", ret.why());
		}
	}
	
	JNIMETHOD (void, handleUpdate) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		theMainSurfaceWidth = (int)surfaceWidth;
		theMainSurfaceHeight = (int)surfaceHeight;
		
		mix::theApp.update();
	}
	
	JNIMETHOD (void, handleQuit) (JNIEnv* env, jobject cls, jobject surface, jint surfaceWidth, jint surfaceHeight)
	{
		mix::theApp.shutdown();
		mix::theApp.reset();
		
		logI ("bgfx::shutdown");
		bgfx::shutdown();
	}
}
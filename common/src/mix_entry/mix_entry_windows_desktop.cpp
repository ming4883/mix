#include <mix_entry/mix_entry.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <Windows.h>
#include <stdio.h>

void logI (const char* msg)
{
    printf ("%s\n", msg);
}

template<typename... Args>
void logI (const char* fmt, Args&&... args)
{
    printf (fmt, args...);
}


#define WNDCLASSNAME "mixWindow"

class Window
{
public:
    HWND window;
    HDC display;
	
	static LRESULT WINAPI windowMsgProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
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

        windowWidth  = w;
        windowHeight = h;
        SetRect (&rect, 0, 0, windowWidth, windowHeight);
        AdjustWindowRectEx (&rect, dwStyle, FALSE, dwExStyle);
    
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

    bool update ()
    {
        MSG msg = {0};

        while (PeekMessage (&msg, 0, 0, 0, PM_REMOVE))
        {
            TranslateMessage (&msg);
            DispatchMessage (&msg);
        }

        return msg.message != WM_QUIT;
    }

    void shutdown ()
    {
        ReleaseDC (window, display);
        DestroyWindow (window);
        UnregisterClassA (WNDCLASSNAME, NULL);
    }
};

int main (int argc, const char** argv)
{
    
    if (!mix::Application::get())
    {
        logI ("mix::theApp is nullptr!");
        return -1;
    }

	Window window;
	
	int surfaceWidth  = mix::theApp()->getBackbufferWidth()  == 0 ? 800 : mix::theApp()->getBackbufferWidth();
	int surfaceHeight = mix::theApp()->getBackbufferHeight() == 0 ? 450 : mix::theApp()->getBackbufferHeight();
	window.init ("mixApp", surfaceWidth, surfaceHeight);
	
	logI ("%d, %d", surfaceWidth, surfaceHeight);
    mix::theApp()->setBackbufferSize (surfaceWidth, surfaceHeight);

	bgfx::PlatformData pd;
	pd.ndt				= NULL;
	pd.nwh    			= window.window;
	pd.context      	= NULL;
	pd.backBuffer   	= NULL;
	pd.backBufferDS 	= NULL;
	bgfx::setPlatformData (pd);

	//logI ("bgfx::renderFrame");
	//bgfx::renderFrame();

	logI ("bgfx::init");
	bgfx::init();

	logI ("bgfx::reset");
	bgfx::reset (surfaceWidth, surfaceHeight, BGFX_RESET_NONE);

	mix::theApp()->preInit();
	mix::Result ret = mix::theApp()->init();
	if (ret.isFail()) {
		logI ("mix::theApp()->init() failed: %s", ret.why());
		return 0;
	}
	mix::theApp()->postInit();
	
	while (window.update())
	{
		mix::theApp()->preUpdate();
		mix::theApp()->update();
		mix::theApp()->postUpdate();
	}
	
	mix::theApp()->preShutdown();
	mix::theApp()->shutdown();
	mix::theApp()->postShutdown();
	
	mix::Application::cleanup();
	
	logI ("bgfx::shutdown");
	bgfx::shutdown();
	
	window.shutdown();
	
	return 0;
}



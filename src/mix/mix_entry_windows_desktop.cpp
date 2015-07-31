#if defined (MIX_WINDOWS_DESKTOP)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#include <Windows.h>
#include <Windowsx.h>
#include <stdio.h>

/*
void logI (const char* msg)
{
    //printf ("%s\n", msg);
    ::OutputDebugStringA (msg);
    ::OutputDebugStringA ("\n");
}

template<typename... Args>
void logI (const char* fmt, Args&&... args)
{
    //printf (fmt, args...);
    char str[256];
    sprintf_s(str, fmt, args...);
    ::OutputDebugStringA (str);
    ::OutputDebugStringA ("\n");
}
*/

#define WNDCLASSNAME "mixWindow"

class Window
{
public:
    HWND window;
    HDC display;
    bool minimizied;
    int lastW, lastH;
    UINT mouseState;

    Window()
        : window (nullptr)
        , display (nullptr)
        , minimizied (false)
        , lastW (0)
        , lastH (0)
        , mouseState (0u)
    {
        
    }

    void handleWM_SIZE (WPARAM _wParam, LPARAM _lParam)
    {
        RECT _rect;
        GetClientRect (window, &_rect);
        int _fnw = (int)_rect.right - (int)_rect.left;
        int _fnh = (int)_rect.bottom - (int)_rect.top;

        switch (_wParam)
        {
        case SIZE_MINIMIZED:
            mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterBackground());
            minimizied = true;
            break;

        case SIZE_MAXIMIZED:
        case SIZE_RESTORED:
            {
                if (minimizied)
                    mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterForeground());

                int delta = abs (lastW - _fnw) + abs (lastH - _fnh);
                        
                if (delta >= 2)
                {
                    mix::theApp()->pushEvent (mix::FrontendEvent::resized (_fnw, _fnh));
                }
                        
                mix::theApp()->setBackbufferSize (_fnw, _fnh);
                        
                lastW = _fnw;
                lastH = _fnh;

                minimizied = false;
            }
            break;
        }

        //mix::Log::i ("WM_SIZE wParam=%d", _wParam);
    }

    mix::FrontendMouseId::Enum wmmsg2mouseid (UINT _wmmsg)
    {
        switch (_wmmsg)
        {
            case WM_LBUTTONDOWN:
            case WM_LBUTTONUP:
                return mix::FrontendMouseId::Left;

            case WM_RBUTTONDOWN:
            case WM_RBUTTONUP:
                return mix::FrontendMouseId::Right;

            case WM_MBUTTONDOWN:
            case WM_MBUTTONUP:
                return mix::FrontendMouseId::Middle;

            default:
                return mix::FrontendMouseId::None;
        }
    }

    bool isOutside (int _clientx, int _clienty)
    {
        if (_clientx < 0) return true;
        if (_clienty < 0) return true;
        if (_clientx >= lastW) return true;
        if (_clienty >= lastH) return true;

        return false;
    }

    void handle_WM_XBUTTONDOWN (UINT _msg, WPARAM _wParam, LPARAM _lParam)
    {
        if (0u == mouseState)
        {
            SetCapture (window);
        }

        mix::FrontendMouseId::Enum _mouseid = wmmsg2mouseid (_msg);
        int _mousex = GET_X_LPARAM (_lParam), 
            _mousey = GET_Y_LPARAM (_lParam);

        mouseState |= _mouseid;

        mix::theApp()->pushEvent (mix::FrontendEvent::touchDown ((float)_mousex, (float)_mousey, _mouseid));
    }

    void handle_WM_XBUTTONUP (UINT _msg, WPARAM _wParam, LPARAM _lParam)
    {
        mix::FrontendMouseId::Enum _mouseid = wmmsg2mouseid (_msg);
        int _mousex = GET_X_LPARAM (_lParam), 
            _mousey = GET_Y_LPARAM (_lParam);

        mouseState &= ~_mouseid;

        if (mix::FrontendMouseId::None == mouseState && GetCapture() == window)
            ReleaseCapture ();

        if (isOutside (_mousex, _mousey))
            mix::theApp()->pushEvent (mix::FrontendEvent::touchCancel ((float)_mousex, (float)_mousey, _mouseid));
        else
            mix::theApp()->pushEvent (mix::FrontendEvent::touchUp ((float)_mousex, (float)_mousey, _mouseid));
    }
    
    void handle_WM_MOUSEMOVE (WPARAM _wParam, LPARAM _lParam)
    {
        int _mousex = GET_X_LPARAM (_lParam), 
            _mousey = GET_Y_LPARAM (_lParam);

        if (GetCapture() == window && !isOutside (_mousex, _mousey))
        {
            size_t touchid = 0u;
            if (_wParam & (MK_LBUTTON))
                touchid |= mix::FrontendMouseId::Left;

            if (_wParam & (MK_RBUTTON))
                touchid |= mix::FrontendMouseId::Right;

            if (_wParam & (MK_MBUTTON))
                touchid |= mix::FrontendMouseId::Middle;

            mix::theApp()->pushEvent (mix::FrontendEvent::touchMove ((float)_mousex, (float)_mousey, touchid));
        }
    }
    
    static LRESULT WINAPI windowMsgProc (HWND _hWnd, UINT _msg, WPARAM _wParam, LPARAM _lParam)
    {
        Window* _this = reinterpret_cast<Window*> (GetWindowLongA (_hWnd, GWL_USERDATA));
        if (nullptr != _this)
        {
            switch (_msg)
            {
                case WM_CLOSE:
                {
                    mix::theApp()->pushEvent (mix::FrontendEvent::closed());
                    PostQuitMessage (0);
                    break;
                }

                case WM_SIZE:
                {
                    _this->handleWM_SIZE (_wParam, _lParam);
                    break;
                }

                case WM_LBUTTONDOWN:
                case WM_RBUTTONDOWN:
                case WM_MBUTTONDOWN:
                {
                    _this->handle_WM_XBUTTONDOWN (_msg, _wParam, _lParam);
                    break;
                }

                case WM_LBUTTONUP:
                case WM_RBUTTONUP:
                case WM_MBUTTONUP:
                {
                     _this->handle_WM_XBUTTONUP (_msg, _wParam, _lParam);
                    break;
                }

                case WM_MOUSEMOVE:
                {
                    _this->handle_WM_MOUSEMOVE (_wParam, _lParam);
                    break;
                }
            }
        }
        
        return DefWindowProc(_hWnd, _msg, _wParam, _lParam);
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
        SetWindowLongA (window, GWL_USERDATA, reinterpret_cast<LONG> (this));

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
    mix::Log::init();

    if (!mix::Application::get())
    {
        mix::Log::e ("app", "mix::theApp is nullptr!");
        return -1;
    }

    Window window;
    
    int surfaceWidth  = mix::theApp()->getBackbufferWidth()  == 0 ? 800 : mix::theApp()->getBackbufferWidth();
    int surfaceHeight = mix::theApp()->getBackbufferHeight() == 0 ? 450 : mix::theApp()->getBackbufferHeight();
    window.init ("mixApp", surfaceWidth, surfaceHeight);
    
    mix::Log::e ("app", "%d, %d", surfaceWidth, surfaceHeight);
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

    mix::Log::e ("app", "bgfx::init");
    bgfx::init();

    //logI ("bgfx::reset");
    //bgfx::reset (surfaceWidth, surfaceHeight, BGFX_RESET_NONE);

    mix::theApp()->preInit();
    mix::Result ret = mix::theApp()->init();
    if (ret.isFail()) {
        mix::Log::e ("app", "mix::theApp()->init() failed: %s", ret.why());
        return 0;
    }
    mix::theApp()->postInit();
    
    while (window.update())
    {
        mix::theApp()->preUpdate();
        mix::theApp()->update();
        mix::theApp()->postUpdate();
    }

    mix::theApp()->pushEvent (mix::ApplicationEvent::terminating());
    
    mix::theApp()->preShutdown();
    mix::theApp()->shutdown();
    mix::theApp()->postShutdown();
    
    mix::Application::cleanup();
    
    mix::Log::e ("app", "bgfx::shutdown");
    bgfx::shutdown();
    
    window.shutdown();

    mix::Log::shutdown();
    
    return 0;
}

#endif // #if defined (MIX_WINDOWS_DESKTOP)
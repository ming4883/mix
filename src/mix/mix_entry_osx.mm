#if defined (MIX_OSX) && !defined (MIX_TESTS)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>
#include <map>


#import <Cocoa/Cocoa.h>

@interface mixWindowDelegate : NSObject<NSWindowDelegate>
-(id)initWithWindow:(NSWindow*) _window;
@end

@implementation mixWindowDelegate
{
    NSWindow* m_window;
}

-(id)initWithWindow:(NSWindow*) _window
{
    if (nil != [self init])
    {
        m_window = _window;
        [_window setDelegate:self];
        [self windowDidResize: nil];
    }

    return self;
}

- (void)windowDidResize:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    CGRect _rect = [[m_window contentView] frame];
    mix::theApp()->platformSetBackbufferSize ((int)_rect.size.width, (int)_rect.size.height);
    mix::theApp()->pushEvent (mix::FrontendEvent::resized((int)_rect.size.width, (int)_rect.size.height));
}

- (void)windowWillClose:(NSNotification *)_notification
{
    BX_UNUSED(_notification);
}

- (BOOL)windowShouldClose:(NSWindow*)_window
{
    [m_window setDelegate:nil];
    [NSApp terminate:self];
    return YES;
}

@end

@interface mixAppDelegate : NSObject<NSApplicationDelegate>
+ (mixAppDelegate*)sharedDelegate;
- (BOOL)hasTerminated;
- (NSInteger)processEvents;
@end

@implementation mixAppDelegate
{
    NSMutableArray* m_windowDelegates;
    BOOL m_quit;
}

+ (mixAppDelegate*)sharedDelegate
{
    static id delegate = [[mixAppDelegate alloc] init];
    return delegate;
}

- (id)init
{
    self = [super init];
    self->m_quit = NO;
    self->m_windowDelegates = [[NSMutableArray alloc] init];
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [m_windowDelegates release];
    [super dealloc];
}
#endif

- (BOOL)hasTerminated
{
    return self->m_quit;
}

- (NSEvent*) peekEvent
{
    return [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES];
}

- (CGPoint) getMouseLocation:(NSEvent*) _evt
{
    NSWindow* _win = [_evt window];
    NSRect originalFrame = [_win frame];
    NSPoint location = [_win mouseLocationOutsideOfEventStream];
    NSRect adjustFrame = [_win contentRectForFrameRect: originalFrame];

    int x = location.x;
    int y = (int)adjustFrame.size.height - (int)location.y;

    // clamp within the range of the window
    //if (x < 0) x = 0;
    //if (y < 0) y = 0;
    if (x > (int)adjustFrame.size.width) x = (int)adjustFrame.size.width;
    if (y > (int)adjustFrame.size.height) y = (int)adjustFrame.size.height;

    return CGPointMake (x, y);
}

- (void) handleMouseMove:(NSEvent*) _evt
{

}

- (void) handleMouseDown:(NSEvent*) _evt
               withButton:(mix::FrontendMouseId::Enum) _mid
{
    CGPoint _pt = [self getMouseLocation:_evt];
    if (_pt.y >= 0)
        mix::theApp()->pushEvent (mix::FrontendEvent::touchDown (_pt.x, _pt.y, _mid));
}

- (void) handleMouseUp:(NSEvent*) _evt
              withButton:(mix::FrontendMouseId::Enum) _mid
{
    CGPoint _pt = [self getMouseLocation:_evt];
    if (_pt.y >= 0)
        mix::theApp()->pushEvent (mix::FrontendEvent::touchUp (_pt.x, _pt.y, _mid));

}

- (NSInteger)processEvents
{
    NSEvent* _evt = [self peekEvent];
    NSInteger _cnt = 0;

    while (nil != _evt)
    {
        _cnt++;

        switch ([_evt type])
        {
            case NSMouseMoved:
            case NSLeftMouseDragged:
            case NSRightMouseDragged:
            case NSOtherMouseDragged:
                {
                    [self handleMouseMove: _evt];
                    break;
                }

            case NSLeftMouseDown:
                {
                    [self handleMouseDown: _evt withButton:mix::FrontendMouseId::Left];
                    break;
                }

            case NSLeftMouseUp:
                {
                    [self handleMouseUp: _evt withButton:mix::FrontendMouseId::Left];
                    break;
                }

            case NSRightMouseDown:
                {
                    [self handleMouseDown: _evt withButton:mix::FrontendMouseId::Right];
                    break;
                }

            case NSRightMouseUp:
                {
                    [self handleMouseUp: _evt withButton:mix::FrontendMouseId::Right];
                    break;
                }
        };

        [NSApp sendEvent:_evt];
        [NSApp updateWindows];

        _evt = [self peekEvent];
    }

    return _cnt;
}

- (NSWindow*)createWindow:(const mix::FrontendDesc&) _request
{
    NSUInteger _style = 0
        | NSTitledWindowMask
        | NSClosableWindowMask
        | NSResizableWindowMask
        | NSMiniaturizableWindowMask
    ;

    CGRect _windowRect = CGRectMake (_request.left, _request.top, _request.width, _request.height);

    CGRect _screenRect = [NSScreen mainScreen].frame;

    if (mix::FrontendDesc::SizeFullScreen == _request.width)
        _windowRect.size.width = _screenRect.size.width;
    else if (mix::FrontendDesc::SizeAuto == _request.width)
        _windowRect.size.width = _screenRect.size.width / 2;

    if (mix::FrontendDesc::SizeFullScreen == _request.height)
        _windowRect.size.height = _screenRect.size.height;
    else if (mix::FrontendDesc::SizeAuto == _request.height)
        _windowRect.size.height = _screenRect.size.height / 2;

    if (mix::FrontendDesc::PositionCentered == _request.left)
        _windowRect.origin.x = (_screenRect.size.width - _windowRect.size.width) / 2;

    if (mix::FrontendDesc::PositionCentered == _request.top)
        _windowRect.origin.y = (_screenRect.size.height - _windowRect.size.height) / 2;

    _windowRect.origin.x = floorf (_windowRect.origin.x);
    _windowRect.origin.y = floorf (_windowRect.origin.y);
    _windowRect.size.width = floorf (_windowRect.size.width);
    _windowRect.size.height = floorf (_windowRect.size.height);

    NSWindow* _win = [[NSWindow alloc] initWithContentRect:_windowRect styleMask:_style backing:NSBackingStoreBuffered defer:NO];

    [_win setTitle:[[NSProcessInfo processInfo] processName]];
    [_win setAcceptsMouseMovedEvents:YES];
    [_win setBackgroundColor:[NSColor blackColor]];

    mixWindowDelegate* _winDele = [mixWindowDelegate alloc];
    [_winDele initWithWindow:_win];
    [m_windowDelegates addObject:_winDele];

    return _win;
}

- (void)applicationDidFinishLaunching:(NSNotification *)_notification
{
    BX_UNUSED(_notification);
    mix::Log::init();
    mix::Asset::init (nullptr);

    if (!mix::theApp())
    {
        mix::Log::e ("app", "no mix::Application was created!");
        return;
    }

    NSWindow* _window = [self createWindow:(mix::theApp()->getMainFrontendDesc())];
    [_window makeKeyAndOrderFront: _window];

    bgfx::PlatformData pd;
    pd.ndt              = NULL;

#if !__has_feature(objc_arc)
    pd.nwh              = (void*)_window;
#else
    pd.nwh              = (__bridge_retained void*)_window;
#endif
    pd.context          = NULL;
    pd.backBuffer       = NULL;
    pd.backBufferDS     = NULL;
    bgfx::setPlatformData (pd);

    mix::Log::i ("app", "bgfx::init");
    bgfx::init();

    mix::theApp()->preInit();

    mix::Result ret = mix::theApp()->init();
    if (ret.isFail()) {
        mix::Log::i ("app", "mix::theApp().init() failed: %s", ret.why());
    }

    mix::theApp()->postInit();
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)_sender
{
    BX_UNUSED(_sender);

    if (mix::theApp())
    {
        mix::theApp()->pushEvent (mix::ApplicationEvent::terminating());
        mix::theApp()->preShutdown();
        mix::theApp()->shutdown();
        mix::theApp()->postShutdown();
        mix::Application::cleanup();
    }

    mix::Log::i ("app", "bgfx::shutdown");
    bgfx::shutdown();

    mix::Asset::shutdown();
    mix::Log::shutdown();

    self->m_quit = YES;
    return NSTerminateCancel;
}

-(void)applicationWillBecomeActive:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    if (mix::theApp())
    {
        mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterForeground());
    }
}

-(void)applicationWillResignActive:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    if (mix::theApp())
    {
        mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterBackground());
    }
}

-(void)applicationDidBecomeActive:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    if (mix::theApp())
    {
        mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterForeground());
    }
}

-(void)applicationDidResignActive:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    if (mix::theApp())
    {
        mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterBackground());
    }
}

@end

int main(int _argc, char* _argv[])
{
    [NSApplication sharedApplication];

    mixAppDelegate* _appDelegate = [mixAppDelegate sharedDelegate];

    [NSApp setDelegate:_appDelegate];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp finishLaunching];

    // a small work around for fixing GL_INVALID_FRAMEBUFFER_OPERATION in glClear during startup
    while ([_appDelegate processEvents] <= 0);

    while (![_appDelegate hasTerminated])
    {
        [_appDelegate processEvents];

        if (mix::theApp())
        {
            mix::theApp()->preUpdate();
            mix::theApp()->update();
            mix::theApp()->postUpdate();
        }
    }

    return 0;
}

#endif // #if defined (MIX_IOS) && !defined (MIX_TESTS)

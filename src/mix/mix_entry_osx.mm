#if defined (MIX_OSX) && !defined (MIX_TESTS)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>
#include <map>


#import <Cocoa/Cocoa.h>

@interface mixWindowDelegate : NSObject<NSWindowDelegate>

@end

@implementation mixWindowDelegate


- (void)windowDidResize:(NSNotification *)_notification
{
    BX_UNUSED(_notification);
}

- (void)windowWillClose:(NSNotification *)_notification
{
    BX_UNUSED(_notification);
}

@end

@interface mixAppDelegate : NSObject<NSApplicationDelegate>
- (bool)hasTerminated;
- (void)processEvents;
@end

@implementation mixAppDelegate
{
    NSWindow* m_window;
    mixWindowDelegate* m_windowDelegate;
    BOOL m_quit;
}

- (id)init
{
    self = [super init];
    self->m_quit = NO;
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [m_window release];
    [m_windowDelegate release];
    [super dealloc];
}
#endif

- (bool)hasTerminated
{
    return self->m_quit;
}

- (NSEvent*) peekEvent
{
    return [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES];
}

- (void)processEvents
{
    NSEvent* _evt = [self peekEvent];

    while (nil != _evt)
    {
        [NSApp sendEvent:_evt];
        [NSApp updateWindows];

        _evt = [self peekEvent];
    }
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
    [_win setDelegate:m_windowDelegate];

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

    m_windowDelegate = [mixWindowDelegate alloc];

    m_window = [self createWindow:(mix::theApp()->getMainFrontendDesc())];
    [m_window makeKeyAndOrderFront: m_window];

    bgfx::PlatformData pd;
    pd.ndt              = NULL;

#if !__has_feature(objc_arc)
    pd.nwh              = (void*)m_window;
#else
    pd.nwh              = (__bridge_retained void*)m_window;
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


    {
        CGRect _ = [[m_window contentView] frame];
        bgfx::reset ((uint32_t)_.size.width, (uint32_t)_.size.height, BGFX_RESET_NONE);
        mix::theApp()->platformSetBackbufferSize((int)_.size.width, (int)_.size.height);
    }

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

@end

int main(int _argc, char* _argv[])
{
    [NSApplication sharedApplication];

    mixAppDelegate* _appDelegate = [mixAppDelegate alloc];

    [NSApp setDelegate:_appDelegate];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp finishLaunching];

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

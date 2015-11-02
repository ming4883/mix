#if defined (MIX_OSX) && defined (MIX_TESTS)

#include <mix/mix_tests.h>
#include <mix/mix_log.h>

#import <Cocoa/Cocoa.h>

@interface mixUnitTestWindowDelegate : NSObject<NSWindowDelegate>
-(id)initWithWindow:(NSWindow*) _window;
@end

@implementation mixUnitTestWindowDelegate
{
    NSWindow* m_window;
}

-(id)initWithWindow:(NSWindow*) _window
{
    if (nil != [self init])
    {
        m_window = _window;
        [_window setDelegate:self];
    }

    return self;
}

- (BOOL)windowShouldClose:(NSWindow*)_window
{
    [m_window setDelegate:nil];
    [NSApp terminate:self];
    return YES;
}

@end

@interface mixUnitTestAppDelegate : NSObject<NSApplicationDelegate>
+ (mixUnitTestAppDelegate*)sharedDelegate;
- (BOOL)hasTerminated;
- (NSInteger)processEvents;
- (void)appendLog:(const char*)_msg withType:(BOOL)_isError;
@end

@implementation mixUnitTestAppDelegate
{
    mixUnitTestWindowDelegate* m_windowDele;
    NSTextView* m_textView;
    BOOL m_quit;
}

+ (mixUnitTestAppDelegate*)sharedDelegate
{
    static id delegate = [[mixUnitTestAppDelegate alloc] init];
    return delegate;
}

- (id)init
{
    self = [super init];
    m_quit = NO;
    m_windowDele = nil;
    m_textView = nil;
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [m_textView release];
    [m_windowDele release];
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

- (NSInteger)processEvents
{
    NSEvent* _evt = [self peekEvent];
    NSInteger _cnt = 0;

    while (nil != _evt)
    {
        _cnt++;

        [NSApp sendEvent:_evt];
        [NSApp updateWindows];
        
        _evt = [self peekEvent];
    }

    return _cnt;
}

- (NSWindow*)createWindow
{
    NSUInteger _style = 0
        | NSTitledWindowMask
        | NSClosableWindowMask
        | NSResizableWindowMask
        | NSMiniaturizableWindowMask
    ;

    CGRect _screenRect = [NSScreen mainScreen].frame;
    CGRect _windowRect = CGRectMake (_screenRect.size.width / 4, _screenRect.size.height / 4, _screenRect.size.width / 2, _screenRect.size.height / 2);

    _windowRect.origin.x = floorf (_windowRect.origin.x);
    _windowRect.origin.y = floorf (_windowRect.origin.y);
    _windowRect.size.width = floorf (_windowRect.size.width);
    _windowRect.size.height = floorf (_windowRect.size.height);

    NSWindow* _win = [[NSWindow alloc] initWithContentRect:_windowRect styleMask:_style backing:NSBackingStoreBuffered defer:NO];

    [_win setTitle:[[NSProcessInfo processInfo] processName]];
    [_win setAcceptsMouseMovedEvents:YES];
    [_win setBackgroundColor:[NSColor blackColor]];

    NSView* _rootView = _win.contentView;
    //CGFloat scale = [_win backingScaleFactor];
    //[_rootView.layer setContentsScale:scale];

    CGRect _frame = CGRectMake (0, 0, _windowRect.size.width, _windowRect.size.height);

    NSScrollView* _scroll = [[NSScrollView alloc] initWithFrame:_frame];
    [_rootView addSubview:_scroll];

    NSTextView* _textView = [[NSTextView alloc] initWithFrame:_frame];
    _textView.editable = NO;
    _textView.selectable = YES;
    _textView.font = [NSFont fontWithName:@"Courier New" size:12.0f];
    _scroll.documentView = _textView;

    mixUnitTestWindowDelegate* _winDele = [[mixUnitTestWindowDelegate alloc] initWithWindow:_win];
    m_windowDele = _winDele;
    m_textView = _textView;

#if !__has_feature(objc_arc)
    [m_windowDele retain];
    [m_textView retain];
#endif

    return _win;
}

- (void)applicationDidFinishLaunching:(NSNotification *)_notification
{
    BX_UNUSED(_notification);

    NSWindow* _window = [self createWindow];
    [_window makeKeyAndOrderFront: _window];

    int _result = RUN_ALL_TESTS();
    BX_UNUSED (_result);

    [m_textView scrollRangeToVisible:NSMakeRange([[m_textView string] length], 0)];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)_sender
{
    BX_UNUSED(_sender);

    self->m_quit = YES;
    return NSTerminateCancel;
}

- (void)appendLog:(const char*)_msg withType:(BOOL)_isError
{
    NSString* _str = [m_textView.string stringByAppendingString:([NSString stringWithUTF8String:_msg])];
    m_textView.string = _str;
}

@end

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        //if (_isError)
        //    std::cerr << _msg.str() << std::endl;
        //else
        //    std::cout << _msg.str() << std::endl;
        [[mixUnitTestAppDelegate sharedDelegate] appendLog:(_msg.str().c_str()) withType:_isError];
    }
}

int main (int _argc, char* _argv[])
{
    @autoreleasepool {

        [NSApplication sharedApplication];

        mixUnitTestAppDelegate* _appDelegate = [mixUnitTestAppDelegate sharedDelegate];

        [NSApp setDelegate:_appDelegate];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [NSApp activateIgnoringOtherApps:YES];
        [NSApp finishLaunching];

        mix::Log::init();

        ::testing::InitGoogleTest (&_argc, _argv);
        ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

        while (![_appDelegate hasTerminated])
        {
            [_appDelegate processEvents];
        }

        mix::Log::shutdown();

    }

    return 0;
}

#endif // #if defined (MIX_IOS) && defined (MIX_TESTS)



#if defined (MIX_IOS) && !defined (MIX_TESTS)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx/bgfx.h>
#include <bgfx/bgfxplatform.h>
#include <map>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAEAGLLayer.h>

@interface mixView : UIView
{
    CADisplayLink* m_displayLink;
}

@end

@implementation mixView
{
    std::map<id, int> m_touchMappings;
    int m_touchid;
    UISwipeGestureRecognizer* m_swipLeft;
    UISwipeGestureRecognizer* m_swipRight;
    UISwipeGestureRecognizer* m_swipUp;
    UISwipeGestureRecognizer* m_swipDown;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];

    if (nil == self)
    {
        return nil;
    }

    self.multipleTouchEnabled = YES;
    m_touchid = 0;
    m_swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandleSwipeLeft)];
    m_swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandleSwipeRight)];
    m_swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandleSwipeUp)];
    m_swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandleSwipeDown)];

    m_swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    m_swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    m_swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    m_swipDown.direction = UISwipeGestureRecognizerDirectionDown;

    [self addGestureRecognizer:m_swipLeft];
    [self addGestureRecognizer:m_swipRight];
    [self addGestureRecognizer:m_swipUp];
    [self addGestureRecognizer:m_swipDown];

    return self;
}

- (void)layoutSubviews
{
    CGRect _rect = self.frame;

    // raise a resize event manually
    int _backbufw = (int)(self.contentScaleFactor * _rect.size.width);
    int _backbufh = (int)(self.contentScaleFactor * _rect.size.height);
    mix::theApp()->platformSetBackbufferSize (_backbufw, _backbufh);

    mix::theApp()->pushEvent (mix::FrontendEvent::resized (_backbufw, _backbufh));


    //printf ("layoutSubviews %.1f, %.1f", _rect.size.width, _rect.size.height);
}

- (void)start
{
    if (nil == m_displayLink)
    {
        m_displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(renderFrame)];
        [m_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stop
{
    if (nil != m_displayLink)
    {
        [m_displayLink invalidate];
        m_displayLink = nil;
    }
}

- (void)renderFrame
{
    if (mix::theApp())
    {
        mix::theApp()->preUpdate();
        mix::theApp()->update();
        mix::theApp()->postUpdate();
    }
}

- (void)touchMappingAdd: (UITouch *)_touch
{
    m_touchMappings[_touch] = m_touchid++;
}

- (void)touchMappingRemove: (UITouch *)_touch
{
    m_touchMappings.erase(_touch);

    if (m_touchMappings.size() == 0)
        m_touchid = 0;
}

- (int)touchMappingOf: (UITouch *)_touch
{
    if (m_touchMappings.count (_touch) == 0)
        return -1;

    return m_touchMappings[_touch];
}

- (void)touchesBegan:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);

    float _screenscale = [[UIScreen mainScreen] scale];
    BX_UNUSED(_screenscale);

    for (UITouch* _touch in _touches)
    {
        [self touchMappingAdd:_touch];

        CGPoint _pt = [_touch locationInView:self];
        _pt.x *= _screenscale;
        _pt.y *= _screenscale;
        float _force = _touch.force;
        float _maxForce = _touch.maximumPossibleForce;

        mix::theApp()->pushEvent(mix::FrontendEvent::touchDown([self touchMappingOf:_touch], _pt.x, _pt.y, _force, _maxForce));
    }
}

- (void)touchesMoved:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);

    float _screenscale = [[UIScreen mainScreen] scale];
    BX_UNUSED(_screenscale);

    for (UITouch* _touch in _touches)
    {
        CGPoint _pt = [_touch locationInView:self];
        _pt.x *= _screenscale;
        _pt.y *= _screenscale;
        float _force = _touch.force;
        float _maxForce = _touch.maximumPossibleForce;

        mix::theApp()->pushEvent(mix::FrontendEvent::touchMove([self touchMappingOf:_touch], _pt.x, _pt.y, _force, _maxForce));
    }
}

- (void)touchesEnded:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);

    float _screenscale = [[UIScreen mainScreen] scale];
    BX_UNUSED(_screenscale);

    for (UITouch* _touch in _touches)
    {
        CGPoint _pt = [_touch locationInView:self];
        _pt.x *= _screenscale;
        _pt.y *= _screenscale;
        float _force = _touch.force;
        float _maxForce = _touch.maximumPossibleForce;

        mix::theApp()->pushEvent(mix::FrontendEvent::touchUp([self touchMappingOf:_touch], _pt.x, _pt.y, _force, _maxForce));

        [self touchMappingRemove:_touch];
    }
}

- (void)touchesCancelled:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);

    float _screenscale = [[UIScreen mainScreen] scale];
    BX_UNUSED(_screenscale);

    for (UITouch* _touch in _touches)
    {
        CGPoint _pt = [_touch locationInView:self];
        _pt.x *= _screenscale;
        _pt.y *= _screenscale;
        float _force = _touch.force;
        float _maxForce = _touch.maximumPossibleForce;

        mix::theApp()->pushEvent(mix::FrontendEvent::touchCancel([self touchMappingOf:_touch], _pt.x, _pt.y, _force, _maxForce));

        [self touchMappingRemove:_touch];
    }
}

- (void)gestureHandleSwipeLeft
{
    mix::theApp()->pushEvent(mix::FrontendEvent::swipeLeft (0, 0, 0, 0));
}

- (void)gestureHandleSwipeRight
{
   mix::theApp()->pushEvent(mix::FrontendEvent::swipeRight (0, 0, 0, 0));
}

- (void)gestureHandleSwipeUp
{
    mix::theApp()->pushEvent(mix::FrontendEvent::swipeUp (0, 0, 0, 0));
}

- (void)gestureHandleSwipeDown
{
    mix::theApp()->pushEvent(mix::FrontendEvent::swipeDown (0, 0, 0, 0));
}

@end

@interface mixViewController : UIViewController
{

}
@end

@implementation mixViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


@end

@interface mixAppDelegate : UIResponder<UIApplicationDelegate>

@end

@implementation mixAppDelegate
{
    UIWindow* m_window;
    mixView* m_view;
    mixViewController* m_viewcontroller;
}

- (BOOL)application:(UIApplication *)_application didFinishLaunchingWithOptions:(NSDictionary *)_launchOptions
{
    BX_UNUSED(_application, _launchOptions);
    mix::Log::init();
    mix::Asset::init (nullptr);

    CGRect _rect = [ [UIScreen mainScreen] bounds];
    m_window = [ [UIWindow alloc] initWithFrame: _rect];
    m_view = [ [mixView alloc] initWithFrame: _rect];
    m_viewcontroller = [[mixViewController alloc] init];
    m_viewcontroller.view = m_view;

    m_window.rootViewController = m_viewcontroller;
    [m_window makeKeyAndVisible];

    float scaleFactor = [[UIScreen mainScreen] scale]; // should use this, but ui is too small on ipad retina
    //float scaleFactor = 1.0f;
    [m_view setContentScaleFactor: scaleFactor];

    if (!mix::theApp())
    {
        mix::Log::e ("app", "no mix::Application was created!");
        return NO;
    }

    bgfx::PlatformData pd;
    pd.ndt              = NULL;
#if !__has_feature(objc_arc)
    pd.nwh              = (void*)m_view.layer;
#else
    pd.nwh              = (__bridge_retained void*)m_view.layer;
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

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)_application
{
    BX_UNUSED(_application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterBackground());
    [m_view stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)_application
{
    BX_UNUSED(_application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterBackground());
}

- (void)applicationWillEnterForeground:(UIApplication *)_application
{
    BX_UNUSED(_application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterForeground());
}

- (void)applicationDidBecomeActive:(UIApplication *)_application
{
    BX_UNUSED(_application);
    [m_view start];
    mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterForeground());
}

- (void)applicationWillTerminate:(UIApplication *)_application
{
    BX_UNUSED(_application);
    [m_view stop];

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
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)_application
{
    mix::theApp()->pushEvent (mix::ApplicationEvent::lowMemory());
    mix::theApp()->processQueuedEvents();
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [m_window release];
    [m_view release];
    [m_viewcontroller release];
    [super dealloc];
}
#endif

@end

int main(int _argc, char* _argv[])
{
    @autoreleasepool
    {
        int exitCode = UIApplicationMain(_argc, _argv, @"UIApplication", NSStringFromClass([mixAppDelegate class]) );
        return exitCode;
    }
}

#endif // #if defined (MIX_IOS) && !defined (MIX_TESTS)

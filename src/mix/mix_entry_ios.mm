#if defined (MIX_IOS) && !defined (MIX_TESTS)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>
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

        mix::theApp()->pushEvent(mix::FrontendEvent::touchDown(_pt.x, _pt.y, [self touchMappingOf:_touch]));
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

        mix::theApp()->pushEvent(mix::FrontendEvent::touchMove(_pt.x, _pt.y, [self touchMappingOf:_touch]));
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

        mix::theApp()->pushEvent(mix::FrontendEvent::touchUp(_pt.x, _pt.y, [self touchMappingOf:_touch]));

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

        mix::theApp()->pushEvent(mix::FrontendEvent::touchCancel(_pt.x, _pt.y, [self touchMappingOf:_touch]));

        [self touchMappingRemove:_touch];
    }
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
    pd.nwh              = m_view.layer;
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
    
    mix::Log::shutdown();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)_application
{
    mix::theApp()->pushEvent (mix::ApplicationEvent::lowMemory());
    mix::theApp()->processQueuedEvents();
}

- (void)dealloc
{
    [m_window release];
    [m_view release];
    [m_viewcontroller release];
    [super dealloc];
}

@end

int main(int _argc, char* _argv[])
{
    NSAutoreleasePool* pool = [ [NSAutoreleasePool alloc] init];
    int exitCode = UIApplicationMain(_argc, _argv, @"UIApplication", NSStringFromClass([mixAppDelegate class]) );
    [pool release];
    return exitCode;
}

#endif // #if defined (MIX_IOS) && !defined (MIX_TESTS)

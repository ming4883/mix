#if defined (MIX_IOS) && !defined (MIX_TESTS)

#include <mix/mix_application.h>
#include <mix/mix_frontend.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAEAGLLayer.h>

@interface mixView : UIView
{
    CADisplayLink* m_displayLink;
}

@end

@implementation mixView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];

    if (nil == self)
    {
        return nil;
    }

    //CAEAGLLayer* layer = (CAEAGLLayer*)self.layer;
    //bgfx::iosSetEaglLayer (layer);

    return self;
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

- (void)touchesBegan:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);

    float _screenscale = [[UIScreen mainScreen] scale];
    BX_UNUSED(_screenscale);

    for (UITouch* _touch in _touches)
    {
        CGPoint _pt = [_touch locationInView:self];
        _pt.x *= _screenscale;
        _pt.y *= _screenscale;

        printf ("%p begin %.1f, %.1f\n", _touch, _pt.x, _pt.y);
    }
}

- (void)touchesMoved:(NSSet *)_touches withEvent:(UIEvent *)_event
{
    BX_UNUSED(_touches);
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

        printf ("%p end %.1f, %.1f\n", _touch, _pt.x, _pt.y);
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

        printf ("%p cancel %.1f, %.1f\n", _touch, _pt.x, _pt.y);
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

@end

@interface mixAppDelegate : UIResponder<UIApplicationDelegate>
{
    UIWindow* m_window;
    mixView* m_view;
    mixViewController* m_viewcontroller;
}

@end

@implementation mixAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BX_UNUSED(application, launchOptions);
    mix::Log::init();

    CGRect rect = [ [UIScreen mainScreen] bounds];
    m_window = [ [UIWindow alloc] initWithFrame: rect];
    m_view = [ [mixView alloc] initWithFrame: rect];
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

    // raise a resize event manually
    int backbufw = (int)(scaleFactor * rect.size.width);
    int backbufh = (int)(scaleFactor * rect.size.height);
    mix::theApp()->setBackbufferSize (backbufw, backbufh);

    mix::theApp()->pushEvent (mix::FrontendEvent::resized (backbufw, backbufh));

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    BX_UNUSED(application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterBackground());
    [m_view stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BX_UNUSED(application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterBackground());
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    BX_UNUSED(application);
    mix::theApp()->pushEvent (mix::ApplicationEvent::willEnterForeground());
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BX_UNUSED(application);
    [m_view start];
    mix::theApp()->pushEvent (mix::ApplicationEvent::didEnterForeground());
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BX_UNUSED(application);
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

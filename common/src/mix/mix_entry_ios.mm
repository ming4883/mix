#if defined (MIX_IOS)

#include <mix/mix_application.h>

#include <bgfx.h>
#include <bgfxplatform.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAEAGLLayer.h>

void logI (const char* msg)
{
    printf ("%s\n", msg);
}

template<typename... Args>
void logI (const char* fmt, Args&&... args)
{
    printf (fmt, args...);
}

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BX_UNUSED(touches);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BX_UNUSED(touches);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BX_UNUSED(touches);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    BX_UNUSED(touches);
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
        logI ("no mix::Application was created!");
        return NO;
    }
	
    bgfx::PlatformData pd;
    pd.ndt				= NULL;
    pd.nwh    			= m_view.layer;
    pd.context      	= NULL;
    pd.backBuffer   	= NULL;
    pd.backBufferDS 	= NULL;
    bgfx::setPlatformData (pd);

    logI ("bgfx::renderFrame");
    bgfx::renderFrame();

    logI ("bgfx::init");
    bgfx::init();

    logI ("bgfx::reset");
    mix::theApp()->setBackbufferSize ((int)(scaleFactor * rect.size.width), (int)(scaleFactor * rect.size.height));

    bgfx::reset (mix::theApp()->getBackbufferWidth(), mix::theApp()->getBackbufferHeight(), BGFX_RESET_NONE);

    mix::theApp()->preInit();

    mix::Result ret = mix::theApp()->init();
    if (ret.isFail()) {
        logI ("mix::theApp().init() failed: %s", ret.why());
    }

    mix::theApp()->postInit();

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    BX_UNUSED(application);
    [m_view stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BX_UNUSED(application);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    BX_UNUSED(application);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BX_UNUSED(application);
    [m_view start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    BX_UNUSED(application);
    [m_view stop];

    if (mix::theApp())
    {
        mix::theApp()->preShutdown();
        mix::theApp()->shutdown();
        mix::theApp()->postShutdown();
		mix::Application::cleanup();
    }

    logI ("bgfx::shutdown");
    bgfx::shutdown();
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

#endif // #if defined (MIX_IOS)

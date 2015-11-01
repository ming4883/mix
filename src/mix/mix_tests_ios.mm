#if defined (MIX_IOS) && defined (MIX_TESTS)

#include <mix/mix_tests.h>
#include <mix/mix_log.h>

#import <iostream>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CAEAGLLayer.h>

@interface mixUnitTestView : UITextView
{
}

@end

@implementation mixUnitTestView
{
}

- (id)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect textContainer:nullptr];

    if (nil == self)
    {
        return nil;
    }

    self.font = [UIFont fontWithName:@"Courier New" size:12.0f];
    self.editable = NO;

    return self;
}

@end

@interface mixUnitTestViewController : UIViewController
{

}
@end

@implementation mixUnitTestViewController

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

@interface mixUnitTestAppDelegate : UIResponder<UIApplicationDelegate>
-(void)appendLog:(const char*)_msg withType:(BOOL)_isError;
@end

namespace mix
{
    void TestListener::output (bool _isError, Stream& _msg)
    {
        mixUnitTestAppDelegate* dele = (mixUnitTestAppDelegate*)[UIApplication sharedApplication].delegate;
        [dele appendLog:_msg.str().c_str() withType:_isError];
    }
}

@implementation mixUnitTestAppDelegate
{
    UIWindow* m_window;
    mixUnitTestView* m_view;
    mixUnitTestViewController* m_viewcontroller;
}

- (BOOL)application:(UIApplication *)_application didFinishLaunchingWithOptions:(NSDictionary *)_launchOptions
{
    BX_UNUSED(_application, _launchOptions);
    mix::Log::init();

    CGRect _rect = [ [UIScreen mainScreen] bounds];
    m_window = [ [UIWindow alloc] initWithFrame: _rect];
    m_view = [ [mixUnitTestView alloc] initWithFrame: _rect];
    m_viewcontroller = [[mixUnitTestViewController alloc] init];
    m_viewcontroller.view = m_view;

    m_window.rootViewController = m_viewcontroller;
    [m_window makeKeyAndVisible];

    float scaleFactor = [[UIScreen mainScreen] scale]; // should use this, but ui is too small on ipad retina
    [m_view setContentScaleFactor: scaleFactor];

    ::testing::UnitTest::GetInstance()->listeners().Append (new mix::TestListener);

    int _result = RUN_ALL_TESTS();
    BX_UNUSED(_result);

    [m_view scrollRangeToVisible:NSMakeRange(m_view.text.length -1, 1)];
    [m_view setScrollEnabled:NO];
    [m_view setScrollEnabled:YES];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)_application
{
    BX_UNUSED(_application);

    mix::Log::shutdown();
}

-(void)appendLog:(const char*)_msg withType:(BOOL)_isError
{
    NSString* _text = [m_view.text stringByAppendingString:[NSString stringWithUTF8String:_msg]];
    m_view.text = _text;
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
        ::testing::InitGoogleTest (&_argc, _argv);
        int exitCode = UIApplicationMain(_argc, _argv, @"UIApplication", NSStringFromClass([mixUnitTestAppDelegate class]) );
        return exitCode;
    }
}

#endif // #if defined (MIX_IOS) && defined (MIX_TESTS)



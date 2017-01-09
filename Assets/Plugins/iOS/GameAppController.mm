//----------------------------------------------------------------//
//Created by LDW on 16-9-4.
//重载UnityAppController，接入sdk生命周期
//----------------------------------------------------------------//



#import "UnityAppController.h"

#include "CommonAppDelegate.h"
#include "SdkBridge.h"


@interface GameAppController : UnityAppController {}
@end



@implementation GameAppController

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 初始化sdk
    SdkBridge * cbi = new SdkBridge();
    [[CommonAppDelegate getInstance]setBridge:cbi];
    [[CommonAppDelegate getInstance]application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
    
    [[CommonAppDelegate getInstance]applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
    
    // 这里sdk只是处理插屏广告
    // [[CommonAppDelegate getInstance]applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [super applicationDidBecomeActive:application];
    
    [[CommonAppDelegate getInstance]applicationDidBecomeActive:application];
}


- (void)applicationWillResignActive:(UIApplication*)application
{
    [super applicationWillResignActive:application];
    
    [[CommonAppDelegate getInstance]applicationWillResignActive:application];
}


- (void)applicationWillTerminate:(UIApplication*)application
{
    [[CommonAppDelegate getInstance]applicationWillTerminate:application];

    // 这里先通知sdk再调用父类
    [super applicationWillTerminate:application];
}





@end


IMPL_APP_CONTROLLER_SUBCLASS(GameAppController)



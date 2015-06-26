/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */
//
//  MMDelegate.m
//  MMCore
//
//


#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreApplication.h>

#import "MFUIApplication.h"
#import "MFMenuViewController.h"
#import "MFSimpleSplashViewController.h"
#import "MFTransitionController.h"
#import "MFDeckViewController.h"
#import "UIViewController+MFViewControllerUtils.h"
#import "MFHelperFile.h"
#import "MFFormBaseViewController.h"
#import "MFAppDelegate.h"

@interface MFAppDelegate ()

@property (nonatomic,strong) MFApplication *applicationContext;
@property (nonatomic,strong) MFStarter *starter;

@end

@implementation MFAppDelegate
@synthesize fieldValidatorsByAttributes = _fieldValidatorsByAttributes;

#ifdef DEBUG
/**
 Host observed by framework stule management system.
 */
static NSString *const CONST_HOST = @"http://localhost:8888/";
#endif


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&ApplicationExceptionHandler);
    
    [MFLoggingHelper initializeLogging:mfStartLogLevel];
    MFCoreLogVerbose(@"didFinishLaunchingWithOptions after initializeLogging ");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    MFSimpleSplashViewController *splashViewController = [[UIStoryboard storyboardWithName:@"Splash" bundle:nil] instantiateViewControllerWithIdentifier:@"MFSimpleSplashViewController"];
    
    
    _applicationContext = [MFApplication getInstance];
    _starter = [MFStarter getInstance];
    [self setupFirstLaunching];
    
    //retrieve the default Movalys menu.
    UIViewController<MFMenuViewControllerProtocol> __block *leftController = [self customMenuViewController];
    if([leftController isKindOfClass:[MFFormBaseViewController class]]) {
        ((MFFormBaseViewController *)leftController).needDoFillAction = NO;
    }
    
    MFTransitionController *transitionController = [[MFTransitionController alloc] initWithViewController:splashViewController];
    self.transitionController = transitionController;
    
    MFDeckViewController *menuController = [[MFDeckViewController alloc] initWithCenterViewController:transitionController leftViewController:leftController];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    menuController.leftSize = screenRect.size.width - 200;
    
    self.window.rootViewController = menuController;
    
    [self.window makeKeyAndVisible];
    
    if ( [_starter.settingsValidationManager isUserSettingsValuesCorrect] == YES ) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [_starter start];
            if([leftController isKindOfClass:[MFFormBaseViewController class]]) {
                ((MFFormBaseViewController *)leftController).needDoFillAction = YES;
            }        });
    }
    
    return YES;
}

//Attention fonction c ...
void ApplicationExceptionHandler(NSException *exception)
{
    [[MFUIApplication getInstance] treatUnhandledException:exception];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    MFCoreLogVerbose(@"> applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ( [_starter.settingsValidationManager isUserSettingsValuesCorrect] == YES ) {
        [_starter.settingsValidationManager verifyIfUserFwkSettingsHasChanged];
        if ( [_starter isStarted] == NO && [_starter isStartRunning] == NO ) {
            [self application:application  didFinishLaunchingWithOptions:nil] ;
        }
    }
    MFCoreLogVerbose(@"< applicationWillEnterForeground");
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)applicationWillTerminate:(UIApplication *)application {
    
}
#pragma mark - Styles


-(void) setupFirstLaunching{
    [_starter setupFirstLaunching];
}

-(UIViewController<MFMenuViewControllerProtocol> *) customMenuViewController {
    return [MFMenuViewController getInstance];
}

-(id<MFComponentProviderProtocol>)componentProvider {
    return [NSClassFromString(@"MFBeanComponentProvider") new];
}


@end

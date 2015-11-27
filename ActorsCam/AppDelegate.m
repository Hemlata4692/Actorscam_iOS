//
//  AppDelegate.m
//  ActorsCam
//
//  Created by Hema on 17/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Activity indicator
- (void) ShowIndicator
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.dimBackground=YES;
    hud.labelText=[@"Loading..." changeTextLanguage:@"Loading..."];
}

//Method for stop indicator
- (void)StopIndicator
{
    [MBProgressHUD hideHUDForView:self.window animated:YES];
}
#pragma mark - end

#pragma mark - Appdelegate methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", @"en", @"fr", nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Override point for customization after application launch.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@""] || ([[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] == NULL)){
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"Language"];
    }
  //  NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"]);

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:253.0/255.0 green:138.0/255.0 blue:43.0/255.0 alpha:1.0]];
     
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"OpenSans-Semibold" size:18.0], NSFontAttributeName, nil]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.navigationController = (UINavigationController *)[self.window rootViewController];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil)
    {
        
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

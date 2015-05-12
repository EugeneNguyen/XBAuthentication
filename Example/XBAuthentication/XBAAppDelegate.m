//
//  XBAAppDelegate.m
//  XBAuthentication
//
//  Created by CocoaPods on 12/22/2014.
//  Copyright (c) 2014 eugenenguyen. All rights reserved.
//

#import "XBAAppDelegate.h"
#import <XBAuthentication.h>

@implementation XBAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[XBAuthentication sharedInstance] setHost:@"http://wunhunt.sflashcard.com"];
    [[XBAuthentication sharedInstance] setIsDebug:YES];
    
    return [[XBAuthentication sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];;
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[XBAuthentication sharedInstance] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[XBAuthentication sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end

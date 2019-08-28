//
//  AppDelegate.m
//  BLEFileTransfer
//
//  Created by Anil Kumar on 19/07/19.
//  Copyright © 2019 AIT. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  
  [self configureLocalNotification];
  
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[BluetoothConnectionController alloc] init]];
  self.window.rootViewController = navController;
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  
  [self.window makeKeyAndVisible];
  
  return YES;
}


#pragma mark - Custom Methods

- (void)configureLocalNotification {
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
  
  [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (!granted) {
      NSLog(@"Something went wrong");
    }
  }];
}


#pragma mark - UNUserNotificationCenterDelegate Methods

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  // Play sound and show alert to the user
  completionHandler(UNAuthorizationOptionAlert + UNAuthorizationOptionSound);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  
  if ([response.notification.request.identifier isEqualToString:@"UYLLocalNotification"]) {
    
    if ([response.actionIdentifier isEqualToString:@"Snooze"]) {
      NSLog(@"Snooze");
    } else if ([response.actionIdentifier isEqualToString:@"Delete"]) {
      // Do Nothing
    } else {
      // Do Nothing
    }
  }
  
  completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

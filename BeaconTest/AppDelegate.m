//
//  AppDelegate.m
//  BeaconTest
//
//  Created by 佐々木 善隆 on 2014/04/30.
//  Copyright (c) 2014年 WillCraft. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconTrigger.h"

#define kBEACON_UID @"UID入れてね"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[BeaconTrigger sharedInstance] startBeaconWithUid:kBEACON_UID
                                            identifier:@"jp.willcraft"
                                    foundBeaconHandler:^(CLBeacon *beacon) {

                                        NSString *rangeMessage;
                                        
                                        switch (beacon.proximity) {
                                            case CLProximityImmediate:
                                                rangeMessage = @"超近い！";
                                                break;
                                            case CLProximityNear:
                                                rangeMessage = @"近い！";
                                                break;
                                            case CLProximityFar:
                                                rangeMessage = @"遠い！";
                                                break;
                                            default:
                                                rangeMessage = @"不明！";
                                                break;
                                        }
                                        
                                        // TODO: BeaconはUserDefaultあたりに保持して連続で通知しないようにする
                                        NSString *message = [NSString stringWithFormat:@"%@ major:%@, minor:%@, accuracy:%f, rssi:%ld",
                                                             rangeMessage, beacon.major, beacon.minor, beacon.accuracy, beacon.rssi];
                                        
                                        NSLog(@"%@", message);
                                        
                                        [self sendLocalNotificationForMessage:message];
                                        
                                    }
                                         regionHandler:^(RegionStatus status) {
                                             switch (status) {
                                                 case EnterRegion:
                                                     NSLog(@"Beacon領域に入りました");
                                                     break;
                                                 case ExitRegion:
                                                     NSLog(@"Beacon領域から出ました");
                                                     break;
                                             }
                                         }];
    
    return YES;
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)sendLocalNotificationForMessage:(NSString *)message {
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end

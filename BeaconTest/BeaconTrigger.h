//
//  BeaconTrigger.h
//  iMenuTest
//
//  Created by 佐々木 善隆 on 2014/02/15.
//  Copyright (c) 2014年 WillCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kFOUND_BEACON_NOTIFICATION @"FoundBeaconNotification"
#define kENTER_REGION_NOTIFICATION @"EnterRegionNotification"
#define kEXIT_REGION_NOTIFICATION @"ExitRegionNotification"

typedef NS_ENUM(NSInteger, RegionStatus) {
    EnterRegion,
    ExitRegion
};

typedef void (^FoundBeaconHandler)(CLBeacon *);
typedef void (^RegionHandler)(RegionStatus);


@interface BeaconTrigger : NSObject

@property (nonatomic) BOOL isStartBeacon;

+ (BeaconTrigger *)sharedInstance;

- (BOOL)isStartBeacon;

- (void)startBeaconWithUid:(NSString *)uid
                identifier:(NSString *)identifier;

- (void)startBeaconWithUid:(NSString *)uid
                identifier:(NSString *)identifier
        foundBeaconHandler:(FoundBeaconHandler)foundBeaconHandler
             regionHandler:(RegionHandler)regionHandler;

- (void)stopBeacon;

@end

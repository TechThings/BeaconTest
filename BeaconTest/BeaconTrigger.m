//
//  BeaconTrigger.m
//  iMenuTest
//
//  Created by 佐々木 善隆 on 2014/02/15.
//  Copyright (c) 2014年 WillCraft. All rights reserved.
//

#import "BeaconTrigger.h"

@interface BeaconTrigger () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) NSMutableDictionary *beacons;

@property (nonatomic, copy) FoundBeaconHandler foundBeaconHandler;
@property (nonatomic, copy) RegionHandler regionHandler;

@end

@implementation BeaconTrigger


+ (BeaconTrigger *)sharedInstance {
    static BeaconTrigger *beaconTrigger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        beaconTrigger = [[BeaconTrigger alloc] initSharedInstance];
    });
    return beaconTrigger;
}

- (id)initSharedInstance {
    if (self = [super init]) {
        _isStartBeacon = false;
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)startBeaconWithUid:(NSString *)uid
                identifier:(NSString *)identifier
        foundBeaconHandler:(FoundBeaconHandler)foundBeaconHandler
             regionHandler:(RegionHandler)regionHandler {
    
    _foundBeaconHandler = foundBeaconHandler;
    _regionHandler = regionHandler;
    [self startBeaconWithUid:uid identifier:identifier];
}

- (void)startBeaconWithUid:(NSString *)uid
                identifier:(NSString *)identifier {
    
    if (_isStartBeacon) {
        [self stopBeacon];
    }
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uid];
    
    if (uuid != nil) {
        _beacons = [NSMutableDictionary dictionary];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
        [_locationManager startMonitoringForRegion:_beaconRegion];
        _isStartBeacon = YES;
    } else {
        // error;
    }
}

- (void)stopBeacon {
    
    if (_isStartBeacon) {
        [_beacons removeAllObjects];
        [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
        [_locationManager stopMonitoringForRegion:_beaconRegion];
        _beacons = nil;
        _beaconRegion = nil;
        _isStartBeacon = NO;
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region {

    [_locationManager requestStateForRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {

    switch (state) {
        case CLRegionStateInside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            }
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    
    if (_regionHandler) {
        _regionHandler(EnterRegion);
    }
    
    NSNumber *status = [NSNumber numberWithInt:EnterRegion];
    NSNotification *notification = [NSNotification notificationWithName:kENTER_REGION_NOTIFICATION object:self userInfo:@{@"status": status}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    if ([CLLocationManager isRangingAvailable]) {
        [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    
    if (_regionHandler) {
        _regionHandler(ExitRegion);
    }
    
    NSNumber *status = [NSNumber numberWithInt:ExitRegion];
    NSNotification *notification = [NSNotification notificationWithName:kEXIT_REGION_NOTIFICATION object:self userInfo:@{@"status": status}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    if ([CLLocationManager isRangingAvailable]) {
        [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown];
    NSArray *validBeacons = [beacons filteredArrayUsingPredicate:predicate];

    if (validBeacons.count > 0) {
        CLBeacon *beacon = validBeacons.firstObject;
        if (_foundBeaconHandler) {
            _foundBeaconHandler(beacon);
        }
        NSNotification *notification = [NSNotification notificationWithName:kFOUND_BEACON_NOTIFICATION object:self userInfo:@{@"beacon": beacon}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end

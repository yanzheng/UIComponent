//
//  RTLocationManager.m
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTLocationManager.h"

#define RTGetCitySuccessNotification @"city_did_get"

@implementation RTLocationManager
@synthesize locationManager = _locationManager;
@synthesize userLocation = _userLocation;
@synthesize locatedCityID = _locatedCityID;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTLocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTLocationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 500;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

- (CLLocation *)userLocation {
    if (self.locationManager.location == nil)
        [self restartLocation];
    
//    NSLog(@"cur: lat: %f, lng: %f, timestamp:%@", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.latitude, self.locationManager.location.timestamp);
    
    return self.locationManager.location;
}

- (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (RTCLServiceStatus)locationServicesStatus{
    RTCLServiceStatus status = RTCLServiceStatusUnknowError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.2")) {
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            switch (authorizationStatus) {
                case kCLAuthorizationStatusNotDetermined:
                    status = RTCLServiceStatusFirst;
                    break;
                case kCLAuthorizationStatusAuthorized:
                    status = RTCLServiceStatusOK;
                    break;
                case kCLAuthorizationStatusDenied:
                    status = RTCLServiceStatusDenied;
                    break;
                default:
                    if (![[RTApiRequestProxy sharedInstance] isWiFiAvailiable] && ![[RTApiRequestProxy sharedInstance] isInternetAvailiable]) {
                        status = RTCLServiceStatusNoNetwork;
                    }
                    break;
            }
        }
    }else {
        status = RTCLServiceStatusDenied;
    }
    return status;
}

- (void)restartLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
}


- (void)startLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }    
}

- (void)stopLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    }        
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    DLog(@"new: lat: %f, lng: %f, timestamp:%@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.timestamp);
//    [self updateLocatedCityID];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}


@end

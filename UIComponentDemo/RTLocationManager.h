//
//  RTLocationManager.h
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    RTCLServiceStatusFirst,//定位第一次打开 ios4.2以上
    RTCLServiceStatusOK,//定位服务开启
    RTCLServiceStatusDenied, //用户拒绝服务
    RTCLServiceStatusNoNetwork,//用户网络未开
    RTCLServiceStatusUnknowError //其他错误
} RTCLServiceStatus;//定位服务状态

@interface RTLocationManager : NSObject <CLLocationManagerDelegate>

+ (id)sharedInstance;
- (id)init;

@property (nonatomic, readonly) CLLocation *userLocation;
@property (nonatomic, copy) NSString *locatedCityID;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;
- (BOOL)locationServicesEnabled;

//new
- (RTCLServiceStatus)locationServicesStatus;
@end

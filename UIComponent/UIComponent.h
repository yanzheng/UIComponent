//
//  UIComponent.h
//  UIComponent
//
//  Created by zheng yan on 12-6-25.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#ifndef RTCOMMON_RTCOMMON_H
#define RTCOMMON_RTCOMMON_H

// ui components
#import "RTPhotoScrollView.h"
#import "MWPhotoBrowser.h"
#import "RTPhoto.h"
#import "IndexScrollController.h"
#import "JWFolders.h"
#import "SimplePingHelper.h"

#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

#import "RTButtonSegmentControl.h"
#import "APISwitchView.h"

#import "WEPopoverContainerView.h"
#import "WEPopoverController.h"

#import "WebImageView.h"
#import "CustomBadge.h"

// category
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"


#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s #%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

//版本比较
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)


#endif
//
//  RTPhoto.h
//  PhotoScroller
//
//  Created by zheng yan on 12-7-4.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RTPHOTO_LOADING_DID_END_NOTIFICATION @"RTPHOTO_LOADING_DID_END_NOTIFICATION"

@interface RTPhoto : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSURL *photoURL;
@property (nonatomic, copy) NSString *photoPath;

@property (nonatomic, retain) NSString *caption;

- (void)loadImage;
- (void)unloadImage;

+ (RTPhoto *)photoWithImage:(UIImage *)image;
+ (RTPhoto *)photoWithFilePath:(NSString *)path;
+ (RTPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

@end

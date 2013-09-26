//
//  RTPhoto.m
//  PhotoScroller
//
//  Created by zheng yan on 12-7-4.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTPhoto.h"

@implementation RTPhoto
@synthesize image = _image;
@synthesize photoURL = _photoURL;
@synthesize photoPath = _photoPath;
@synthesize caption = _caption;

- (void) dealloc {
//    [[RTApiRequestProxy sharedInstance] cancelRequestsWithTarget:self];
    self.image = nil;
    self.photoURL = nil;
    
    [super dealloc];
}

#pragma mark Class Methods

+ (RTPhoto *)photoWithImage:(UIImage *)image {
	return [[[RTPhoto alloc] initWithImage:image] autorelease];
}

+ (RTPhoto *)photoWithFilePath:(NSString *)path {
	return [[[RTPhoto alloc] initWithFilePath:path] autorelease];
}

+ (RTPhoto *)photoWithURL:(NSURL *)url {
	return [[[RTPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		_image = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

- (void)loadImage {
    if (self.image)
        return;
    
    if (_photoPath) {
        self.image = [UIImage imageWithContentsOfFile:_photoPath];
        return;
    }
    
    if (_photoURL)
        return;
    
//    NSLog(@"load image: %@", _photoURL);
}

- (void)unloadImage {
    return;
//    [[RTApiRequestProxy sharedInstance] cancelRequestsWithTarget:self];
    
    if (_image)
        _image = nil;
}


@end

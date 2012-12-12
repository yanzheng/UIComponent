//
//  RTPhoto.m
//  PhotoScroller
//
//  Created by zheng yan on 12-7-4.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTPhoto.h"
#import "RTApiProxy.h"

@implementation RTPhoto
@synthesize image = _image;
@synthesize photoURL = _photoURL;
@synthesize photoPath = _photoPath;
@synthesize caption = _caption;

- (void) dealloc {
    [[RTApiRequestProxy sharedInstance] cancelRequestsWithTarget:self];
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
    if (_image)
        return;
    
    if (_photoPath) {
        _image = [UIImage imageWithContentsOfFile:_photoPath];
        return;
    }
    
    if (_photoURL)
        [[RTApiRequestProxy sharedInstance] fetchImage:_photoURL target:self action:@selector(onFetchImage:)];
    
//    NSLog(@"load image: %@", _photoURL);
}

- (void)unloadImage {
    [[RTApiRequestProxy sharedInstance] cancelRequestsWithTarget:self];
    
    if (_image)
        _image = nil;
}

- (void)onFetchImage:(RTNetworkResponse *)response {
    // network error
    if ([response status] != RTNetworkResponseStatusSuccess) {
        NSLog(@"RTNetwork error");
        return;
    }
    
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        _photoPath = [[response content] objectForKey:@"imagePath"];
        self.image = [UIImage imageWithContentsOfFile:_photoPath];
        
//        NSLog(@"fetch image success: %@", _photoURL);
        [[NSNotificationCenter defaultCenter] postNotificationName:RTPHOTO_LOADING_DID_END_NOTIFICATION
                                                            object:self];
    }
}

@end

//
//  WebImageView.m
//  UIComponent
//
//  Created by yan zheng on 12-11-26.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "WebImageView.h"
#import "RTApiProxy.h"

@implementation WebImageView
@synthesize imageUrl = _imageUrl;
@synthesize notificationName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [[RTApiRequestProxy sharedInstance] cancelRequestsWithTarget:self];
    [super dealloc];
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = [imageUrl copy];
    if (_imageUrl)
        [[RTApiRequestProxy sharedInstance] fetchImage:[NSURL URLWithString:imageUrl] target:self action:@selector(onImageFetched:)];
}

- (void)onImageFetched:(RTNetworkResponse *)response {
    // network error
    if ([response status] != RTNetworkResponseStatusSuccess)
        return;
    
    // cache image's local path
    id status = [[response content] objectForKey:@"status"];
    if (status && [[(NSString *)status uppercaseString] isEqualToString:@"OK"]) {
        NSString *imagePath = [[response content] objectForKey:@"imagePath"];
        self.image = [UIImage imageWithContentsOfFile:imagePath];
        [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

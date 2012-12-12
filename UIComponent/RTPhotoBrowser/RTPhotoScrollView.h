//
//  RTPhotoScrollView.h
//  PhotoScroller
//
//  Created by zheng yan on 12-7-4.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTPhoto.h"
#import "MWZoomingScrollView.h"

@protocol RTPhotoScrollViewDelegate <NSObject>
@optional
- (void)singleTapAtIndex:(NSUInteger)index;
- (void)doubleTapAtIndex:(NSUInteger)index;
- (void)didPhotoScroll:(id)photoScrollView scrollToIndex:(NSUInteger)index;
- (void)didPhotoLoaded:(id)imageView atIndex:(NSUInteger)index;
@end

@interface RTPhotoScrollView : UIScrollView <UIScrollViewDelegate, MWZoomingScrollViewDelegate> {
}

@property (nonatomic, assign) id<RTPhotoScrollViewDelegate> tapDelegate;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *photoUrls;
@property (nonatomic, retain) NSMutableSet *cachedPages;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, assign) BOOL loopEnabled;         // default: disable
@property (nonatomic, assign) CGFloat padding;   // padding between pages: default 0
@property (nonatomic, assign) BOOL zoomEnabled;             // default: disable
@property (nonatomic, assign) BOOL photoScrollEnabled;             // default: disable
@property (nonatomic, assign) BOOL pageControlEnabled;      // default: enabled
@property (nonatomic, assign) NSUInteger preCacheCount;     // reload previous page's count. default: 1
@property (nonatomic, assign) NSUInteger nextCacheCount;    // reload next page's count, default: 1
@property (nonatomic, assign) UIViewContentMode viewContentMode;
@property (nonatomic, assign) BOOL rotating;

- (void)showAtIndex:(NSUInteger)index;
- (UIImageView *)currentImageView;
- (RTPhoto *)currentPhoto;

@end

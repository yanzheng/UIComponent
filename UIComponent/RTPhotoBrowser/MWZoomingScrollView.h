//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"
#import "RTPhoto.h"

@class MWPhotoBrowser, MWPhoto;

@protocol MWZoomingScrollViewDelegate <NSObject>
- (void)singleTapAtIndex:(NSUInteger)index;
- (void)doubleTapAtIndex:(NSUInteger)index;
@end

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate> {
    RTPhoto *_photo;
    
	MWTapDetectingView *_tapView; // for background taps
	MWTapDetectingImageView *_photoImageView;
	UIActivityIndicatorView *_spinner;
	
}

@property (nonatomic, assign) id<MWZoomingScrollViewDelegate> touchDelegate;
@property (nonatomic, retain) RTPhoto *photo;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL zoomEnabled;
@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, retain) MWTapDetectingImageView *photoImageview;

- (id)initWithFrame:(CGRect)frame;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;

@end

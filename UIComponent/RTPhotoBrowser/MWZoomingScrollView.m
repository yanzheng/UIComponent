//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWZoomingScrollView.h"


// Private methods and properties
@interface MWZoomingScrollView ()
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;
@end

@implementation MWZoomingScrollView
@synthesize touchDelegate = _touchDelegate;
@synthesize photo = _photo;
@synthesize index = _index;
@synthesize zoomEnabled = _zoomEnabled;
@synthesize photoImageview = _photoImageView;
@synthesize imageContentMode = _imageContentMode;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		// Tap view for background
		_tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
        
		_tapView.tapDelegate = self;
		_tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor clearColor];
		[self addSubview:_tapView];
		
		// Image view
		_photoImageView = [[MWTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
		_photoImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_photoImageView];
        
		// Spinner
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.hidesWhenStopped = YES;
		_spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_spinner];
		
		// Setup
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        self.scrollEnabled = NO;
    }
    return self;
}

- (void)dealloc {
	[_tapView release];
	[_spinner release];
    [_photo unloadImage];
    
    self.photoImageview = nil;
    self.photo = nil;
	[super dealloc];
}

- (void)setPhoto:(RTPhoto *)photo {
    _photoImageView.image = nil; // Release image
    if (_photo != photo) {
        [_photo release];
        _photo = [photo retain];
    }
    if (_photo)
        [self displayImage];
}


#pragma mark - Image

// Get and display image
- (void)displayImage {
    if (!_photo)
        return;
    
	if (_photoImageView.image == nil) {
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
        
		// Get image from browser as it handles ordering of fetching
		UIImage *img = [_photo image];
		if (img) {
			// Hide spinner
			[_spinner stopAnimating];
			
			// Set image
			_photoImageView.image = img;
			_photoImageView.hidden = NO;
            
			// Setup photo frame: aspect fit
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = img.size;
            _photoImageView.frame = photoImageViewFrame;
            self.contentSize = photoImageViewFrame.size;
            
			// Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
		} else {
            [_photo loadImage];
            
			// Hide image view
			_photoImageView.hidden = YES;
			[_spinner startAnimating];
			
		}
		[self setNeedsLayout];
	} else {    // scale back
        [self setZoomScale:.0f animated:NO];
    }
}

// Image failed so just show black!
- (void)displayImageFailure {
	[_spinner stopAnimating];
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (_photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    if (self.imageContentMode == UIViewContentModeScaleAspectFill)
        minScale = MAX(xScale, yScale);
    
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}
    
	// Calculate Max
	CGFloat maxScale = 2.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	// Reset position
	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
	[self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
	// Update tap view frame
	_tapView.frame = self.bounds;
	
	// Spinner
	if (!_spinner.hidden) _spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
                                                        floorf(self.bounds.size.height/2.0));
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
    
    //    NSLog(@"image frame: %f, %f", _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    //    NSLog(@"page  frame: %f, %f", self.frame.size.width, self.frame.size.height);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    //	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //	[_photoBrowser hideControlsAfterDelay];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    if ([_touchDelegate respondsToSelector:@selector(singleTapAtIndex:)])
        [_touchDelegate singleTapAtIndex:_index];
    
    if (!self.zoomEnabled)
        return;
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    if ([_touchDelegate respondsToSelector:@selector(doubleTapAtIndex:)])
        [_touchDelegate doubleTapAtIndex:_index];
    
	if (!self.zoomEnabled)
        return;
    
	
	// Zoom
	if (self.zoomScale == self.maximumZoomScale) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
	
	// Delay controls
    //	[_photoBrowser hideControlsAfterDelay];
	
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}

@end

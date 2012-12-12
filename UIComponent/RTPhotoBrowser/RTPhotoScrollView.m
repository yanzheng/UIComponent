//
//  RTPhotoScrollView.m
//  PhotoScroller
//
//  Created by zheng yan on 12-7-4.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTPhotoScrollView.h"
#import "MWZoomingScrollView.h"

@interface RTPhotoScrollView()
- (void)configurePage:(MWZoomingScrollView *)page withIndex:(NSUInteger)index;
@end

@implementation RTPhotoScrollView

@synthesize tapDelegate = _tapDelegate;
@synthesize photos = _photos;
@synthesize photoUrls = _photoUrls;
@synthesize cachedPages = _cachedPages;
@synthesize pageControl = _pageControl;
@synthesize loopEnabled = _loopEnabled;
@synthesize padding = _padding;
@synthesize zoomEnabled = _zoomEnabled;
@synthesize photoScrollEnabled = _photoScrollEnabled;
@synthesize pageControlEnabled = _pageControlEnabled;
@synthesize preCacheCount = _preCacheCount;
@synthesize nextCacheCount = _nextCacheCount;
@synthesize viewContentMode = _viewContentMode;
@synthesize rotating = _rotating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.pagingEnabled = YES;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        self.photoScrollEnabled = YES;
        self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake((frame.size.width-100)/2, frame.size.height-20, 100, 10)] autorelease];
        _pageControl.hidden = NO;
        
        // Listen for MWPhoto notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRTPhotoLoadingDidEndNotification:)
                                                     name:RTPHOTO_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
        
        // set default property
        _zoomEnabled = NO;
        _preCacheCount = 1;
        _nextCacheCount = 1;
        _padding = 0;
        _viewContentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.cachedPages = nil;
    self.photos = nil;
    self.photoUrls = nil;
    self.pageControl = nil;
    self.tapDelegate = nil;
    
    [super dealloc];
}

- (void)setPhotos:(NSArray *)photos {
    if (!photos) {
        [_photos release];
        _photos = nil;
        return;
    }
    if (_photos != photos) {
        [_photos release];
        _photos = [photos retain];
    }
    
    _pageControl.numberOfPages = _photos.count;
    self.cachedPages = [NSMutableSet set];
}

- (void)setPhotoUrls:(NSArray *)photoUrls {
    if (!photoUrls)
        return;
    
    if (_photoUrls != photoUrls) {
        [_photoUrls release];
        _photoUrls = [photoUrls retain];
    }
    
    NSMutableArray *photoArray = [NSMutableArray array];
    for (id url in _photoUrls) {
        RTPhoto *photo = [RTPhoto photoWithURL:[NSURL URLWithString:(NSString *)url]];
        [photoArray addObject:photo];
    }
    
    [self setPhotos:photoArray];
}

- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
    _pageControl.hidden = !pageControlEnabled;
}

- (void)showAtIndex:(NSUInteger)index {
    self.contentSize = CGSizeMake(self.bounds.size.width*_photos.count + 2*_padding*(_photos.count-1), self.bounds.size.height);
    
    index = MIN(index, _photos.count-1);
    
    _pageControl.currentPage = index;
    CGRect bound = self.bounds;
    bound.origin.x = bound.size.width * index;
    self.bounds = bound;
    
    [self tilePage];
}

#pragma mark - ScrollView Delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.rotating)
        return;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // update current index and page control's index
	CGRect visibleBounds = self.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    index = MAX(index, 0);
    index = MIN(index, _photos.count-1);
    
	if (index != _pageControl.currentPage) {
        _pageControl.currentPage = index;
        [self tilePage];
    }
}

#pragma mark - Page
- (void)tilePage {
    int currentIndex = _pageControl.currentPage;
    int preIndex = currentIndex-_preCacheCount;
    int nextIndex = currentIndex+_nextCacheCount;
    preIndex = MAX(preIndex, 0);
    nextIndex = MIN(nextIndex, _photos.count-1);
    NSMutableSet *cachedIndexes = [NSMutableSet set];
    
    // remove all pages beyond the cached
    for (id item in [[_cachedPages copy] autorelease]) {
        MWZoomingScrollView *page = (MWZoomingScrollView *)item;
        if (page.index < preIndex || page.index > nextIndex) {
            [page removeFromSuperview];
            [_cachedPages removeObject:page];
        }
        else {
            [cachedIndexes addObject:[NSNumber numberWithInt:page.index]];
            [page displayImage];
        }
    }
    
    // create pages that need to be cached
    if (![cachedIndexes containsObject:[NSNumber numberWithInt:currentIndex]]) {
        MWZoomingScrollView *page = [[MWZoomingScrollView alloc] initWithFrame:[self frameForPageAtIndex:currentIndex]];
        [self configurePage:page withIndex:currentIndex];
        [self addSubview:page];
        [_cachedPages addObject:page];
        [cachedIndexes addObject:[NSNumber numberWithInt:page.index]];
        [page release];
    }
    for (int i = preIndex; i <= nextIndex; i++) {
        if (![cachedIndexes containsObject:[NSNumber numberWithInt:i]] && currentIndex != i) {
            MWZoomingScrollView *page = [[MWZoomingScrollView alloc] initWithFrame:[self frameForPageAtIndex:i]];
            [self configurePage:page withIndex:i];
            [self addSubview:page];
            [_cachedPages addObject:page];
            [page release];
        }
    }
    
    [self didScrolledToIndex:currentIndex];
}


- (void)configurePage:(MWZoomingScrollView *)page withIndex:(NSUInteger)index {
    if (self.photos.count == 0)
        return;
    
    [page setTouchDelegate:self];
    [page setIndex:index];
    [page setPhoto:[self.photos objectAtIndex:index]];
    [page setZoomEnabled:_zoomEnabled];
    [page setScrollEnabled:self.photoScrollEnabled];
    [page setImageContentMode:self.viewContentMode];
    [page displayImage];
}

- (MWZoomingScrollView *)pageDisplayingPhoto:(RTPhoto *)photo {
	MWZoomingScrollView *thePage = nil;
	for (MWZoomingScrollView *page in _cachedPages) {
		if (page.photo == photo) {
			thePage = page;
            break;
		}
	}
	return thePage;
}


#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= _padding;
    frame.size.width += (2 * _padding);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * _padding);
    pageFrame.origin.x = (bounds.size.width * index) + _padding;
    return pageFrame;
}

#pragma mark - MWPhoto Loading Notification

- (void)handleRTPhotoLoadingDidEndNotification:(NSNotification *)notification {
    RTPhoto *photo = [notification object];
    MWZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo image]) {
            // Successful load
            [page displayImage];
            if ([_tapDelegate respondsToSelector:@selector(didPhotoLoaded:atIndex:)])
                [_tapDelegate didPhotoLoaded:page.photoImageview atIndex:page.index];
        }
    }
}

#pragma mark - MWZoomingScrollView Delegates
- (void)singleTapAtIndex:(NSUInteger)index {
    if ([_tapDelegate respondsToSelector:@selector(singleTapAtIndex:)])
        [_tapDelegate singleTapAtIndex:index];
}

- (void)doubleTapAtIndex:(NSUInteger)index {
    if ([_tapDelegate respondsToSelector:@selector(doubleTapAtIndex:)])
        [_tapDelegate doubleTapAtIndex:index];
}

- (void)didScrolledToIndex:(NSUInteger)index {
    if ([_tapDelegate respondsToSelector:@selector(didPhotoScroll:scrollToIndex:)])
        [_tapDelegate didPhotoScroll:self scrollToIndex:index];
}

- (UIImageView *)currentImageView {
    NSUInteger currentPageNum = self.pageControl.currentPage;
    
	for (id item in _cachedPages) {
        if (![item isKindOfClass:[MWZoomingScrollView class]])
            continue;
        
        MWZoomingScrollView *page = (MWZoomingScrollView *)item;
        if (currentPageNum == page.index)
            return page.photoImageview;
    }
    
    return nil;
}

- (RTPhoto *)currentPhoto {
    return [self.photos objectAtIndex:self.pageControl.currentPage];
}

@end

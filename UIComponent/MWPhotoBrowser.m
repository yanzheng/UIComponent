//
//  MWPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MWPhotoBrowser.h"
#import "MWZoomingScrollView.h"
#import "MBProgressHUD.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Private
@interface MWPhotoBrowser () {	
    NSUInteger _currentPageIndex;
    
	// Navigation & controls
	NSTimer *_controlVisibilityTimer;
	UIBarButtonItem *_previousButton, *_nextButton, *_actionButton, *_deleteButton;
    UIActionSheet *_actionsSheet;
    MBProgressHUD *_progressHUD;

    // Appearance
    UIImage *_navigationBarBackgroundImageDefault, 
    *_navigationBarBackgroundImageLandscapePhone;
    UIColor *_previousNavBarTintColor;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIBarButtonItem *_previousViewControllerBackButton;
    
    // Misc
    BOOL _displayActionButton;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewIsActive;
}

// Private Properties
@property (nonatomic, retain) UIColor *previousNavBarTintColor;
@property (nonatomic, retain) UIBarButtonItem *previousViewControllerBackButton;
@property (nonatomic, retain) UIImage *navigationBarBackgroundImageDefault, *navigationBarBackgroundImageLandscapePhone;
@property (nonatomic, retain) UIActionSheet *actionsSheet;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

// Private Methods

// Layout
- (void)performLayout;

// Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated;
- (void)storePreviousNavBarAppearance;
- (void)restorePreviousNavBarAppearance:(BOOL)animated;

// Frames
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

@end

// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

// MWPhotoBrowser
@implementation MWPhotoBrowser
@synthesize delegate = _delegate;
@synthesize toolbar = _toolbar;
@synthesize customizeToolBar = _customizeToolBar;

// Properties
@synthesize previousNavBarTintColor = _previousNavBarTintColor;
@synthesize navigationBarBackgroundImageDefault = _navigationBarBackgroundImageDefault,
navigationBarBackgroundImageLandscapePhone = _navigationBarBackgroundImageLandscapePhone;
@synthesize displayActionButton = _displayActionButton, actionsSheet = _actionsSheet, progressHUD = _progressHUD;
@synthesize previousViewControllerBackButton = _previousViewControllerBackButton;

@synthesize photoUrls = _photoUrls;
@synthesize photoPaths = _photoPaths;
@synthesize pagingScrollView = _pagingScrollView;
@synthesize browserTitle = _browserTitle;

@synthesize photoCaptions = _photoCaptions;
@synthesize padding;

#pragma mark - NSObject

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Photo Browser";

        // Defaults
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        _displayActionButton = NO;
        _didSavePreviousStateOfNavBar = NO;        
        _viewIsActive = NO;
    }
    
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [self init])) {
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_previousNavBarTintColor release];
    [_navigationBarBackgroundImageDefault release];
    [_navigationBarBackgroundImageLandscapePhone release];
    [_previousViewControllerBackButton release];
	[_previousButton release];
	[_nextButton release];
    [_actionButton release];
    [_deleteButton release];
    
    if (self.pagingScrollView)
        self.pagingScrollView.tapDelegate = nil;
    self.pagingScrollView = nil;
    self.photoCaptions = nil;
    self.photoUrls = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	
	// Release any cached data, images, etc that aren't in use.	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

#pragma mark - View Loading

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// View
	self.view.backgroundColor = [UIColor blackColor];
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = self.view.bounds;
	_pagingScrollView = [[RTPhotoScrollView alloc] initWithFrame:pagingScrollViewFrame];
	_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.zoomEnabled = YES;
    _pagingScrollView.viewContentMode = UIViewContentModeScaleAspectFit;
    _pagingScrollView.pageControl.hidden = YES;
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    _pagingScrollView.tapDelegate = self;
    _pagingScrollView.padding = self.padding;
    _pagingScrollView.nextCacheCount = 3;
    _pagingScrollView.preCacheCount = 3;
    
    [self initPhotos];
	[self.view addSubview:_pagingScrollView];
	
    
    // Toolbar Items
    _previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
    _nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
    _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    _deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonPressed:)];

    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    if (!self.customizeToolBar) {
        UIBarButtonItem *fixedLeftSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil] autorelease];
        fixedLeftSpace.width = 32; // To balance action button
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        if (_displayActionButton)
            [items addObject:_actionButton];
        
        NSUInteger numberOfPhotos = [self numberOfPhotos];
        [items addObject:flexSpace];
        if (numberOfPhotos > 1)
            [items addObject:_previousButton];
        
        [items addObject:flexSpace];
        if (numberOfPhotos > 1)
            [items addObject:_nextButton];

        [items addObject:flexSpace];
        
        [_toolbar setItems:items];
        [items release];
    }
    
    _toolbar.tintColor = nil;
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    }
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
    [self initCaptionView];
    [self performLayout];

	// Super
    [super viewDidLoad];	
}

// init caption view
- (void)initCaptionView {
    _captionView = [[UIView alloc] initWithFrame:CGRectZero]; // Random initial frame
    _captionView.opaque = NO;
    _captionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _captionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;       
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 
                                                              _captionView.bounds.size.width-20,
                                                              _captionView.bounds.size.height)];
    
    _captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _captionLabel.opaque = NO;
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textAlignment = UITextAlignmentCenter;
    _captionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _captionLabel.numberOfLines = 3;
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(1, 1);
    _captionLabel.font = [UIFont systemFontOfSize:17];
    [_captionView addSubview:_captionLabel];    
//    [self.view addSubview:_captionView];
}

- (void)initPhotos {
    NSMutableArray *photoArray = [NSMutableArray array];
    int i = 0;
    if (_photoPaths) {
        for (id path in _photoPaths) {
            RTPhoto *photo = [RTPhoto photoWithFilePath:path];        
            photo.caption = [self.photoCaptions objectAtIndex:i];
            [photoArray addObject:photo];
            i++;
        }        
    } else if (_photoUrls) {
        for (id url in _photoUrls) {
            RTPhoto *photo = [RTPhoto photoWithURL:[NSURL URLWithString:(NSString *)url]];        
            photo.caption = [self.photoCaptions objectAtIndex:i];
            [photoArray addObject:photo];
            i++;
        }
    }
    [self.pagingScrollView setPhotos:photoArray];
}

- (void)performLayout {
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    // Toolbar
    if (numberOfPhotos > 1 || _displayActionButton) {
        [self.view addSubview:_toolbar];
    } else {
        [_toolbar removeFromSuperview];
    }
    
    // Toolbar items & navigation
	[self updateNavigation];
    
    // Navigation buttons
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        // We're first on stack so show done button
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)] autorelease];
        // Set appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        self.navigationItem.leftBarButtonItem = doneButton;
    } else {
        // We're not first so show back button
        UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        NSString *backButtonTitle = previousViewController.navigationItem.backBarButtonItem ? previousViewController.navigationItem.backBarButtonItem.title : previousViewController.title;
        UIBarButtonItem *newBackButton = [[[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        // Appearance
        if ([UIBarButtonItem respondsToSelector:@selector(appearance)]) {
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
            [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        }
        self.previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem; // remember previous
        previousViewController.navigationItem.backBarButtonItem = newBackButton;
    }
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    
    // layout caption view
    CGFloat yOffset = [_toolbar superview] ? _toolbar.frame.origin.y-44 : self.view.bounds.size.height-44;
    CGRect frame = CGRectMake(0, yOffset, self.view.bounds.size.width, 44);
    _captionView.frame = frame;
}

#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
	
	// Layout manually (iOS < 5)
    if (SYSTEM_VERSION_LESS_THAN(@"5")) [self viewWillLayoutSubviews];
    
    // Status bar
    if (self.wantsFullScreenLayout && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
    }
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Update UI
	[self hideControlsAfterDelay];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
        
    }
    
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (self.wantsFullScreenLayout && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
	// Super
	[super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}

- (NSUInteger)rtSupportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Nav Bar Appearance

- (void)setNavBarAppearance:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    self.previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        self.navigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.navigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        self.navigationController.navigationBar.tintColor = _previousNavBarTintColor;
        self.navigationController.navigationBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [self.navigationController.navigationBar setBackgroundImage:_navigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [self.navigationController.navigationBar setBackgroundImage:_navigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        }
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            self.previousViewControllerBackButton = nil;
        }
    }
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {    
    // Super
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5")) 
        [super viewWillLayoutSubviews];
	
	
	// Toolbar
	_toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
		
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	_pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    
    // resize all cached pages
	for (MWZoomingScrollView *page in _pagingScrollView.cachedPages) {
        NSUInteger index = page.index;
		page.frame = [self frameForPageAtIndex:index];
        page.contentSize = _pagingScrollView.bounds.size;
		[page setMaxMinZoomScalesForCurrentBounds];
	}
    
    
    // layout caption view
    CGFloat yOffset = [_toolbar superview] ? _toolbar.frame.origin.y-44 : self.view.bounds.size.height-44;
    CGRect frame = CGRectMake(0, yOffset, self.view.bounds.size.width, 44);
    _captionView.frame = frame;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {	
    self.pagingScrollView.rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	// Layout manually (iOS < 5)
    if (SYSTEM_VERSION_LESS_THAN(@"5")) [self viewWillLayoutSubviews];
	
	// Delay control holding
	[self hideControlsAfterDelay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.pagingScrollView.rotating = NO;
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= self.padding;
    frame.size.width += (2 * self.padding);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * self.padding);
    pageFrame.origin.x = (bounds.size.width * index) + self.padding;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

#pragma mark - Navigation

- (void)updateNavigation {
	// Title
	if ([self numberOfPhotos] > 1) {
		self.title = [NSString stringWithFormat:@"%i / %i", _currentPageIndex+1, [self numberOfPhotos]];		
	} else {
		self.title = nil;
	}
	
	// Buttons
	_previousButton.enabled = (_currentPageIndex > 0);
	_nextButton.enabled = (_currentPageIndex < [self numberOfPhotos]-1);
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
	[_pagingScrollView showAtIndex:index];
//    _currentPageIndex = index;
    return;
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:_currentPageIndex-1]; }
- (void)gotoNextPage { [self jumpToPageAtIndex:_currentPageIndex+1]; }

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Cancel any timers
    [self cancelControlHiding];
	
	// Status bar and nav bar positioning
    if (self.wantsFullScreenLayout) {
        
        // Get status bar height if visible
        CGFloat statusBarHeight = 0;
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
        }
        
        // Status Bar
        if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden animated:animated];
        }
        
        // Get status bar height if visible
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
        }
        
        // Set navigation bar frame
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        navBarFrame.origin.y = statusBarHeight;
        self.navigationController.navigationBar.frame = navBarFrame;
        
    }
    
	// Animate
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.35];
    }
    CGFloat alpha = hidden ? 0 : 1;
	[self.navigationController.navigationBar setAlpha:alpha];
	[_toolbar setAlpha:alpha];
    [_captionView setAlpha:alpha];
    
	if (animated) [UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	if (!permanent) [self hideControlsAfterDelay];
	
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (_controlVisibilityTimer) {
		[_controlVisibilityTimer invalidate];
		[_controlVisibilityTimer release];
		_controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	if (![self areControlsHidden]) {
        [self cancelControlHiding];
		_controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
}

- (BOOL)areControlsHidden { return (_toolbar.alpha == 0); /* [UIApplication sharedApplication].isStatusBarHidden; */ }
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

#pragma mark - Properties
- (void)showAtIndex:(NSInteger)index {
    if (self.pagingScrollView)
        [self.pagingScrollView showAtIndex:index];
}


#pragma mark - Misc

- (void)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MBProgressHUD

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]] autorelease];
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (NSUInteger)numberOfPhotos {
    if (self.photoPaths)
        return self.photoPaths.count;
    else if (self.photoUrls)
        return self.photoUrls.count;
    else 
        return 0;
}


#pragma mark - PhotoScrollView Delegate
- (void)singleTapAtIndex:(NSUInteger)index {
	[self performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)doubleTapAtIndex:(NSUInteger)index {
    
}

- (void)didPhotoScroll:(id)photoScrollView scrollToIndex:(NSUInteger)index {
    _currentPageIndex = index;
    if (index < self.photoCaptions.count) {
        _captionLabel.text = [self.photoCaptions objectAtIndex:index];
    }
    
    [self updateNavigation];
}

- (void)didPhotoLoaded:(id)imageView atIndex:(NSUInteger)index {
    
}

@end

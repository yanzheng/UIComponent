//
//  FlipDemo.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-28.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "FlipDemo.h"

@interface FlipDemo () {
    AFKPageFlipper *flipper;
    NSUInteger currentPage;
    NSTimer *hideControlTimer;
}

@end

@implementation FlipDemo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView { 
	[super loadView];
    
    self.wantsFullScreenLayout = YES;
    
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"U<->D" style:UIBarButtonItemStyleBordered target:self action:@selector(doSwitch:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self setControlsHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    // init page flipper
    flipper = [[AFKPageFlipper alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:flipper];
    
	flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	flipper.dataSource = self;
    flipper.delegate = self;

    [super viewWillAppear:animated];
}

- (void)doSwitch:(id)sender {
    if (flipper.flipLeftRight) {
        self.navigationItem.rightBarButtonItem.title = @"U<->D";
        flipper.flipLeftRight = NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"L<->R";
        flipper.flipLeftRight = YES;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [flipper refreshPage];

    return YES;
}

#pragma mark - Flipper delegate

- (void)pageFlipper:(AFKPageFlipper *)flipper didFlipped:(NSUInteger)index {
    self.title = [NSString stringWithFormat:@"Flipped Page %d", index];
}

- (void)pageFlipperSingleTapped {
    bool hidden = self.navigationController.navigationBar.alpha == 0;
    [self setControlsHidden:!hidden animated:YES];
}

#pragma mark - Flipper Datasource

- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *) pageFlipper {
    return 100;
}

- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper {
    currentPage = page;
    
    UIView *view = [[UIView alloc] initWithFrame:pageFlipper.bounds];
    NSString *fileName;
    if (page%3 == 0)
        fileName = @"th.png";
    else if (page%3 == 1)
        fileName = @"th2.png";
    else 
        fileName = @"th3.png";
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
    imageView.frame = view.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];    
    label.backgroundColor = [UIColor clearColor];
    [label setText:[NSString stringWithFormat:@"PAGE FLIPPER %d", page]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setTextColor:[UIColor orangeColor]];
    [label setFont:[UIFont systemFontOfSize:30]];
    [view addSubview:label];
    
    UIView *redLine = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 240, 5)];
    redLine.backgroundColor = [UIColor redColor];
    [view addSubview:redLine];
    
//    // add hint view at first page
//    if (page == 1) {
//        __block UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 50)];
//        hintLabel.textAlignment = UITextAlignmentCenter;
//        hintLabel.text = @"tap here to show navigation bar";
//        hintLabel.backgroundColor = [UIColor clearColor];
//        [view addSubview:hintLabel];
//        [UIView animateWithDuration:5 animations:^{
//            hintLabel.alpha = 0;
//        }];
//    }
    return view;
}

// If permanent then we don't set timers to hide again
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {	
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
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated];
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
    
	if (animated) [UIView commitAnimations];
    
    if (!hidden)
        [self hideControlsAfterDelay];	
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
    if (hideControlTimer) {
        [hideControlTimer invalidate];
        hideControlTimer = nil;
    }
    hideControlTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
}

- (void)hideControls {
    if (self.navigationController.navigationBar.alpha == 1)
        [self setControlsHidden:YES animated:YES];
}

@end

//
//  IndexScrollController.m
//  IndexScrollController
//
//  Created by zheng yan on 12-7-18.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "IndexScrollController.h"
#import "UIView+Screenshot.h"

@interface IndexScrollController ()

@end

@implementation IndexScrollController
@synthesize contentControllers = _contentControllers;
@synthesize indexScrollView = _indexScrollView;
@synthesize contentScrollView = _contentScrollView;
@synthesize enablePageChange = _enablePageChange;
@synthesize currentViewController = _currentViewController;

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	        
    // 1. add content scroll view
    CGRect frame = self.view.bounds;
    frame.origin.y = INDEX_SCROLL_VIEW_HEIGHT;
    frame.size.height -= INDEX_SCROLL_VIEW_HEIGHT;
    frame.size.width += 20;
    _contentScrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    _contentScrollView.delegate = self;
    [self.view addSubview:_contentScrollView];
    
    _scrollViewWidth = _contentScrollView.bounds.size.width;
    _scrollViewHeight = _contentScrollView.bounds.size.height;
    _contentScrollView.contentSize = CGSizeMake(_scrollViewWidth * (self.contentControllers.count+2), _scrollViewHeight);    
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.scrollsToTop = NO;
    _contentScrollView.pagingEnabled = YES;    
    _contentScrollView.contentSize = CGSizeMake(_scrollViewWidth * (self.contentControllers.count+2), _scrollViewHeight);    
    _contentScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"aifang_82"]];
    
    // 2. add index scroll view
    if (!self.indexScrollView)
        _indexScrollView = [[[IndexScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, INDEX_SCROLL_VIEW_HEIGHT)] autorelease];
    
    [_indexScrollView setTitles:[_contentControllers valueForKeyPath:@"topicTitle"]];    
    [_indexScrollView setIndexScrollController:self];
    [self.view addSubview:_indexScrollView];   
    [self addHeadTailImages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 3. show controller
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private methods

- (void)jumpToControllerIndex:(NSUInteger)index {
    if (index >= self.contentControllers.count)
        return;
        
    currentPlaceIndex = index+1;    
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = _scrollViewWidth*currentPlaceIndex;
    
//    NSLog(@"jump to controller: %d, contentOffset: %f", index, offset.x);
    self.contentScrollView.contentOffset = offset;
    [self pageChanged];
}

// paste controller's view in scrollview
- (void)placeController:(UIViewController *)controller atIndex:(int)index
{
    if (index <= 0 || index > self.contentControllers.count)
        return;
        
    if ([controller.view superview])
        return;
    
    CGRect frame = controller.view.frame;
    frame.origin.x = _scrollViewWidth*index;
    controller.view.frame = frame;
    controller.view.tag = index;
    [_contentScrollView addSubview:controller.view];
    [controller viewWillAppear:YES];
//    NSLog(@"===== place controller %d at position %d, x: %f", [self.contentControllers indexOfObject:controller], index, frame.origin.x);
//    NSLog(@"subviews: %@", _contentScrollView.subviews);
}

// add head and tail screen shot
- (void)addHeadTailImages {
    UIImageView *head = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, _scrollViewHeight)] autorelease];
    UIImageView *tail = [[[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewWidth*(_contentControllers.count+1), 0, 320, _scrollViewHeight)] autorelease];
    head.tag = 100;
    tail.tag = _contentControllers.count+1+100;
    
    [_contentScrollView addSubview:head];
    [_contentScrollView addSubview:tail];
    
//    NSLog(@"add head tail subviews: %@", _contentScrollView.subviews);
}

- (void)placeImage:(UIImage *)screenshot atIndex:(NSUInteger)index {
    if (index == 0 || index == self.contentControllers.count+1) {
        UIView *imageView = [self.contentScrollView viewWithTag:index+100];
        if (!imageView || ![imageView isKindOfClass:[UIImageView class]])
            return;
        [(UIImageView *)imageView setImage:screenshot];        
    }
}

- (UIViewController *)controllerForPlaceIndex:(NSUInteger)placeIndex {    
    return [self.contentControllers objectAtIndex:[self controllerIndexFromPlaceIndex:placeIndex]];
}

- (NSUInteger)controllerIndexFromPlaceIndex:(NSUInteger)placeIndex {
    NSUInteger controllerIndex = (placeIndex+(self.contentControllers.count-1)) % self.contentControllers.count;
    return controllerIndex;
}

- (void)pageChanged {
    [self placeController:[self controllerForPlaceIndex:currentPlaceIndex] atIndex:currentPlaceIndex];
    [self.indexScrollView scrollToIndex:[self controllerIndexFromPlaceIndex:currentPlaceIndex]];
    self.currentViewController = [self controllerForPlaceIndex:currentPlaceIndex];
    
    // place last controller's screenshot at the first placement
    int preIndex = currentPlaceIndex-1;
    if (preIndex <= 1) {
        UITableViewController *viewController = [self.contentControllers lastObject];
        UIImage *screenshot = [viewController.view screenshot];
        [self placeImage:screenshot atIndex:0];
    }
    else
        [self placeController:[self controllerForPlaceIndex:preIndex] atIndex:preIndex];
    
    // place first controller's screenshot at the last palcement
    int nextIndex = currentPlaceIndex+1;
    if (nextIndex >= self.contentControllers.count) {
        UITableViewController *viewController = [self.contentControllers objectAtIndex:0];
        UIImage *screenshot = [viewController.tableView screenshot];
        [self placeImage:screenshot atIndex:self.contentControllers.count+1];
    } else
        [self placeController:[self controllerForPlaceIndex:nextIndex] atIndex:nextIndex];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int count = self.contentControllers.count;
    
    if (scrollView.contentOffset.x > _scrollViewWidth * count+_scrollViewWidth/2) {
        CGPoint offset = scrollView.contentOffset;
        offset.x -= _scrollViewWidth*count;        
        scrollView.contentOffset = offset;
    }
    else if (scrollView.contentOffset.x < _scrollViewWidth/2) {
        CGPoint offset = scrollView.contentOffset;
        offset.x += _scrollViewWidth*count;
        scrollView.contentOffset = offset;        
    }
    	
    // change when more than 50% of the previous/next page is visible
    int placeIndex = floor((scrollView.contentOffset.x - _scrollViewWidth / 2) / _scrollViewWidth) + 1;    
    if (currentPlaceIndex != placeIndex) {
        currentPlaceIndex = placeIndex; 
        [self.indexScrollView scrollToIndex:[self controllerIndexFromPlaceIndex:currentPlaceIndex]];
        _enablePageChange = YES;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"end scroll dragging");    
    return;
    if (_enablePageChange) {
        [self pageChanged];
        _enablePageChange = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"end scroll animation");
    if (_enablePageChange) {
        [self pageChanged];
        _enablePageChange = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    // called when scroll view grinds to a halt
//    NSLog(@"end scroll decelerating");
    if (_enablePageChange) {
        [self pageChanged];
        _enablePageChange = NO;
    }
}

#pragma mark - IndexScrollView Delegate
- (void)didIndexScrolledToIndex:(NSInteger)index {
    [self jumpToControllerIndex:index];
}

@end

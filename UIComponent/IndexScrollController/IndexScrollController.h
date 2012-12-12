//
//  IndexScrollController.h
//  IndexScrollController
//
//  Created by zheng yan on 12-7-18.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexScrollView.h"

@interface IndexScrollController : UIViewController<UIScrollViewDelegate, IndexScrollViewDelegate> {
    CGFloat _scrollViewWidth, _scrollViewHeight;
    NSUInteger currentPlaceIndex;
}

// should be set outside
@property (nonatomic, retain) NSArray *contentControllers;

// member variables
@property (nonatomic, retain) UIScrollView *contentScrollView;
@property (nonatomic, retain) IndexScrollView *indexScrollView;
@property (nonatomic, assign) BOOL enablePageChange;
@property (nonatomic, retain) UIViewController *currentViewController;

- (void)jumpToControllerIndex:(NSUInteger)index;

@end

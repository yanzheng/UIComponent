//
//  IndexScrollView.h
//  IndexScrollController
//
//  Created by zheng yan on 12-7-19.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDEX_SCROLL_VIEW_HEIGHT 40

@protocol IndexScrollViewDelegate <NSObject>
- (void)didIndexScrolledToIndex:(NSInteger)index;
@end

@interface IndexScrollView : UIScrollView<UIScrollViewDelegate> {
    CGFloat _labelWidth;
    CGFloat _labelHeight;
    NSUInteger _currentLabelIndex;
    NSUInteger _indexCount;
}

@property (nonatomic, retain) NSMutableArray *titles;
@property (nonatomic, assign) id<IndexScrollViewDelegate> indexScrollController;
@property (nonatomic, assign) BOOL isLayouting;

- (void)scrollToIndex:(NSInteger)index;

@end

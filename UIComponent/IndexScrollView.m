//
//  IndexScrollView.m
//  IndexScrollController
//
//  Created by zheng yan on 12-7-19.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "IndexScrollView.h"

@implementation IndexScrollView
@synthesize indexScrollController = _indexScrollController;
@synthesize titles = _titles;
@synthesize isLayouting = _isLayouting;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelFrame = frame;
        labelFrame.size.width = frame.size.width/3;
        self.delegate = self;
        UIImageView *arrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aifang_81.png"]] autorelease];
        arrowView.frame = CGRectMake(151, 31, 18, 9);
        [self addSubview:arrowView];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"aifang_79"]];
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;        
        self.decelerationRate = .7;
        _labelWidth = self.bounds.size.width/3;
        _labelHeight = self.bounds.size.height;
    }
    return self;
}

- (void)setTitles:(NSArray *)titles {
    if (titles.count < 3)
        return;
    
    if (_titles)
        [_titles release];
    
    _indexCount = titles.count;
    _titles = [titles mutableCopy];
    NSRange first2Range, last2Range;
    first2Range.location = 0;
    first2Range.length = 2;
    last2Range.location = _indexCount-2;
    last2Range.length = 2;
    
    NSArray *first2 = [_titles subarrayWithRange:first2Range];
    NSArray *last2 = [_titles subarrayWithRange:last2Range];
    
    [_titles insertObjects:last2 atIndexes:[NSIndexSet indexSetWithIndexesInRange:first2Range]];
    [_titles addObjectsFromArray:first2];
    
    self.contentSize = CGSizeMake(_labelWidth*(_titles.count), _labelHeight);
    CGPoint offset = self.contentOffset;
    offset.x -= _labelWidth;        
    self.contentOffset = offset;
    [self layoutIndexTitles];
}

- (void)scrollToIndex:(NSInteger)index {
//    NSLog(@"scroll page %d -> %d", _currentLabelIndex, index);
    
    // switch offset: first <-> last
    if (_currentLabelIndex == _indexCount-1 && index == 0) {
        CGPoint firstLabelOffset = CGPointMake(0, 0);
        [self setContentOffset:firstLabelOffset];
    } else if (_currentLabelIndex == 0 && index == _indexCount-1) {
        CGPoint lastLabelOffset = CGPointMake(_labelWidth*(_indexCount+1), 0);
        self.contentOffset = lastLabelOffset;        
    }
    
    CGPoint offset = self.contentOffset;
    offset.x = _labelWidth*(index+1);
//    NSLog(@"%f -> %f", self.contentOffset.x, offset.x);
    [self setContentOffset:offset animated:YES];
    _currentLabelIndex = index;
}

- (void)layoutIndexTitles {
    for (UIView *view in self.subviews)
        [view removeFromSuperview];
    
    int i = 0;
    
    for (id title in self.titles) {  
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_labelWidth*i, 0, _labelWidth, _labelHeight)];
//        NSLog(@"title: %@: %@", title, label);
        
        label.text = (NSString *)title;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:label];
        [label release];
        i++;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.decelerating)
//        NSLog(@">>>>> deceletate");
}

- (void)layoutSubviews {
    _isLayouting = YES;
    
    [super layoutSubviews];

//    NSLog(@"offset: %f", self.contentOffset.x);
    
    if (self.contentOffset.x > _labelWidth * _indexCount+_labelWidth*.5) {
        CGPoint offset = self.contentOffset;
        offset.x -= _labelWidth*_indexCount;        
//        NSLog(@"%f <<< : %f", self.contentOffset.x, offset.x);        
        [self setContentOffset:offset animated:NO];
    }
    else if (self.contentOffset.x < _labelWidth*.5) {
        CGPoint offset = self.contentOffset;
        offset.x += _labelWidth*_indexCount;
//        NSLog(@" %f >>> : %f", self.contentOffset.x, offset.x);
        [self setContentOffset:offset animated:NO];
    }
    _isLayouting = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"end scroll dragging");    
    if (_isLayouting) {
//        NSLog(@"is layouting...");
        return;
    }
    if (decelerate || _isLayouting)
        return;
    
    [self adjust];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"end scroll animation");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    // called when scroll view grinds to a halt
//    NSLog(@"end scroll decelerating");
//    if (_isLayouting) {
//        NSLog(@"is layouting...");
//        return;
//    }
    if (self.dragging)
        return;
    
    [self adjust];
}

- (void)adjust {     
//    NSLog(@"adjust");
//    return;
    
    if (self.contentOffset.x > _labelWidth * _indexCount+_labelWidth*.5 
        ||  self.contentOffset.x < _labelWidth*.5) {
//        NSLog(@"contentoffset.x = %f", self.contentOffset.x);
    }


    NSUInteger posIndex = self.contentOffset.x / _labelWidth;
    CGFloat distance = self.contentOffset.x - posIndex * _labelWidth;
    if (distance > _labelWidth/2)
        posIndex += 1;
    
    int pageIndex = posIndex-1;
    if (pageIndex < 0 || pageIndex >= _indexCount)
        return;

//    NSLog(@"current %d -> %d",  _currentLabelIndex, pageIndex);
    _currentLabelIndex = pageIndex;    
    if ([self.indexScrollController respondsToSelector:@selector(didIndexScrolledToIndex:)])
        [self.indexScrollController didIndexScrolledToIndex:pageIndex];
    
    [self scrollToIndex:pageIndex];
}

@end

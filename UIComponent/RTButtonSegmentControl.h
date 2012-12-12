//
//  RTButtonSegmentControl.h
//  UIComponent
//
//  Created by zheng yan on 12-8-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTButtonSegmentControl : UIView {
    id _target;
    SEL _action;
}

- (id)initWithButtons:(NSArray *)buttons;
- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic) NSUInteger selectedSegmentIndex;

@end

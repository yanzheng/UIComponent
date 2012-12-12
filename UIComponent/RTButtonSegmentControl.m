//
//  RTButtonSegmentControl.m
//  UIComponent
//
//  Created by zheng yan on 12-8-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTButtonSegmentControl.h"

@implementation RTButtonSegmentControl
@synthesize selectedSegmentIndex = _selectedSegmentIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithButtons:(NSArray *)buttons {
    if (buttons.count == 0)
        return nil;
    
    UIButton *lastButton = [buttons lastObject];
    CGFloat buttonWith = lastButton.bounds.size.width;
    CGFloat buttonHeight = lastButton.bounds.size.height;
    CGRect frame = CGRectMake(0, 0, buttonWith*buttons.count, buttonHeight);
    
    self = [self initWithFrame:frame];
    int i = 0;
    for (id item in buttons) {
        if (![item isKindOfClass:[UIButton class]])
            return nil;
        
        UIButton *button = (UIButton *)item;
        button.frame = CGRectMake(buttonWith*i, 0, buttonWith, buttonHeight);
        button.tag = i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        i++;
    }
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
    for (id item in self.subviews) {
        if (![item isKindOfClass:[UIButton class]])
            continue;
        UIButton *button = (UIButton *)item;
        if (button.tag == selectedSegmentIndex) {
            [self buttonAction:button];
            break;
        }
    }    
}

- (void)buttonAction:(id)sender {
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
    
    // don't perform action when the selected button is tapped
    if (_selectedSegmentIndex == [(UIButton *)sender tag])
        return;
    
    _selectedSegmentIndex = [(UIButton *)sender tag];
    // deselect all anothor buttons
    for (id item in self.subviews) {
        if (item == sender)
            continue;
        
        if (![item isKindOfClass:[UIButton class]])
            continue;
        
        UIButton *button = (UIButton *)item;
        [button setHighlighted:NO];
//        [button setSelected:NO];
    }
    
    if ([_target respondsToSelector:_action])
        [_target performSelector:_action];
}

- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

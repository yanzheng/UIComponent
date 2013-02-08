//
//  RTPopupSheet.m
//  RTCommon
//
//  Created by zheng yan on 12-8-14.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTPopupSheet.h"
#import <QuartzCore/QuartzCore.h>

#define POPUP_BUTTON_HEIGHT 40
#define POPUP_BUTTON_WIDTH 150
#define POPUP_WIDTH_GAP 15
#define POPUP_HEIGHT_GAP 12

@implementation RTPopupSheet
@synthesize delegate = _delegate;
@synthesize titles = _titles;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDelegate:(id<RTPopupSheetDelegate>)delegate titles:(NSArray *)titles {
    self.delegate = delegate;
    self.titles = titles;
    
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    self.titles = nil;

    if (popupView) {
        [popupView release];
        popupView = nil;
    }
    [super dealloc];
}

- (void)presentAtPoint:(CGPoint)point inView:(UIView *)view {
    CGFloat heightGap = (self.titles.count+1)*POPUP_HEIGHT_GAP;
    CGFloat height = self.titles.count * POPUP_BUTTON_HEIGHT + heightGap;
    self.frame = CGRectMake(0, 0, POPUP_BUTTON_WIDTH+2*POPUP_WIDTH_GAP, height);
    self.layer.cornerRadius = 10.0f;
    
    int i = 0;
    for (NSString *title in self.titles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(POPUP_WIDTH_GAP, POPUP_BUTTON_HEIGHT*i+POPUP_HEIGHT_GAP*(i+1), POPUP_BUTTON_WIDTH, POPUP_BUTTON_HEIGHT);
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:250.0/255 green:240.0/255 blue:210.0/255 alpha:1.0];
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.borderWidth = 0.5f;
        button.layer.cornerRadius = 5.0f;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        CGRect rect = button.bounds;
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *hightlightImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [button setBackgroundImage:hightlightImage forState:UIControlStateHighlighted];
        
        [self addSubview:button];
        i++;
    }
    
    popupView = [[SNPopupView alloc] initWithContentView:self contentSize:self.bounds.size];
    popupView.direction = SNPopupViewRight;
    [popupView presentModalAtPoint:point inView:view];
}

- (void)buttonAction:(id)sender {
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    UIButton *button = (UIButton *)sender;
    
    if ([self.delegate respondsToSelector:@selector(popupSheet:clickedButtonAtIndex:)])
        [self.delegate popupSheet:self clickedButtonAtIndex:button.tag];
    
    [popupView dismissModal];
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

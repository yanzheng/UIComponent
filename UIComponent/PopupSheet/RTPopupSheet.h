//
//  RTPopupSheet.h
//  RTCommon
//
//  Created by zheng yan on 12-8-14.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPopupView.h"

@class RTPopupSheet;

@protocol RTPopupSheetDelegate <NSObject>
@optional
- (void)popupSheet:(RTPopupSheet *)popupSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface RTPopupSheet : UIView {
    SNPopupView *popupView;
}

@property (nonatomic, assign) id<RTPopupSheetDelegate> delegate;
@property (nonatomic, retain) NSArray *titles;

- (id)initWithDelegate:(id<RTPopupSheetDelegate>)delegate titles:(NSArray *)titles;
- (void)presentAtPoint:(CGPoint)point inView:(UIView *)view;

@end

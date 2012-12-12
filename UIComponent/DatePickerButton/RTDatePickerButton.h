//
//  RTDatePickerButton.h
//  RTCommon
//
//  Created by zheng yan on 12-8-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTDatePickerButtonDelegate<NSObject>
- (void)datePickerWillPopup;
- (void)datePickerWillDismiss;
@end

@interface RTDatePickerButton : UIButton {
    UITextField *_textField;
}

@property (nonatomic, readonly, retain) UIDatePicker *datePicker;
@property (nonatomic, assign) id<RTDatePickerButtonDelegate> delegate;

@end

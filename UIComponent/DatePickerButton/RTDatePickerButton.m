//
//  RTDatePickerButton.m
//  RTCommon
//
//  Created by zheng yan on 12-8-17.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "RTDatePickerButton.h"

@implementation RTDatePickerButton
@synthesize datePicker = _datePicker;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _datePicker = [[UIDatePicker alloc] init];
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self addSubview:_textField];    
        _textField.inputView = _datePicker; 
        
        UIToolbar* keyboardToolBar = [[UIToolbar alloc] init];
        keyboardToolBar.barStyle = UIBarStyleBlack;
        keyboardToolBar.translucent = YES;
        keyboardToolBar.tintColor = nil;
        [keyboardToolBar sizeToFit];
        
//        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
//                                                                       style:UIBarButtonItemStyleBordered target:self
//                                                                      action:@selector(cancelClicked:)];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(doneClicked:)];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [keyboardToolBar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];

        [doneButton release];
        [flexibleSpace release];

        _textField.inputAccessoryView = keyboardToolBar;
        [self addTarget:self action:@selector(popupDatePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc {
    [_textField release];
    [_datePicker release];

    _textField = nil;
    _datePicker = nil;
    [super dealloc];
}

- (void)popupDatePicker {
    if ([self.delegate respondsToSelector:@selector(datePickerWillPopup)])
         [self.delegate datePickerWillPopup];
    [_textField becomeFirstResponder];
}

- (void)doneClicked:(id)sender {
    [_textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(datePickerWillDismiss)])
        [self.delegate datePickerWillDismiss];
}

- (void)cancelClicked:(id)sender {
    [_textField resignFirstResponder];
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

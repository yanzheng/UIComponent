//
//  LocalNotificationController.h
//  UIComponentDemo
//
//  Created by zheng yan on 12-9-20.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalNotificationController : UIViewController

- (IBAction)setNotificationAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

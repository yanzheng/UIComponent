//
//  LocalNotificationController.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-9-20.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "LocalNotificationController.h"

@interface LocalNotificationController ()

@end

@implementation LocalNotificationController
@synthesize timeLabel;
@synthesize datePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.datePicker.date = [NSDate date];
}

- (void)viewDidUnload
{
    [self setTimeLabel:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)setNotificationAction:(id)sender {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    UILocalNotification *notification=[[UILocalNotification alloc] init]; 
    if (notification!=nil) { 
        notification.fireDate = self.datePicker.date; 
        notification.timeZone = [NSTimeZone defaultTimeZone]; 
        notification.alertBody = @"时间到"; 
        notification.applicationIconBadgeNumber = 1;
        notification.repeatInterval = NSMinuteCalendarUnit;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
        notification.userInfo = infoDict;

        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateChangedAction:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    
    self.timeLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

@end

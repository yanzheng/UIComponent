//
//  BoundsDemo.h
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-6.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoundsDemo : UIViewController {
    UIView *blueView;
}

- (IBAction)restartAction:(id)sender;
- (IBAction)transitionAction:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *weatherLabel;

@end

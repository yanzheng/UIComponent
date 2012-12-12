//
//  BoundsDemo.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-6.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "BoundsDemo.h"

@interface BoundsDemo ()

@end

@implementation BoundsDemo
@synthesize weatherLabel;

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
}

- (void)viewDidUnload
{
    [self setWeatherLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    blueView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    blueView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueView];

    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    redView.backgroundColor = [UIColor redColor];
    [blueView addSubview:redView];
        
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.titleLabel.textColor = [UIColor blackColor];     // useless
    button.titleLabel.textAlignment = UITextAlignmentLeft;  // useless
    button.titleLabel.shadowOffset  = CGSizeMake (3.0, 0.0);

    
    [button setTitle:@"demo" forState:UIControlStateNormal];
    NSLog(@"button title: %@", [button titleForState:UIControlStateNormal]);
    [button setTitle:@"hignlight" forState:UIControlStateHighlighted];
    [redView addSubview:button];

    [self boundsAnimation:5.0];
}

- (void)boundsAnimation:(NSTimeInterval)delay {    
    [UIView animateWithDuration:delay animations:^{
        blueView.bounds = CGRectMake(100, 100, 100, 100);
        blueView.backgroundColor = [UIColor yellowColor];
        blueView.transform = CGAffineTransformMakeRotation(M_PI);
        blueView.transform = CGAffineTransformMakeTranslation(0, 100);
    } completion:^(BOOL finished) {
        blueView.bounds = CGRectMake(0, 0, 100, 100);
        blueView.backgroundColor = [UIColor blueColor];
        blueView.transform = CGAffineTransformMakeRotation(0);
        blueView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];    
}

- (IBAction)restartAction:(id)sender {
    [self boundsAnimation:3];
}

- (IBAction)transitionAction:(id)sender {
    [UIView transitionWithView:blueView duration:2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        UIView *orangeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        orangeView.backgroundColor = [UIColor orangeColor];
        [blueView addSubview:orangeView];
    } completion:^(BOOL finished) {
    }];
}

@end

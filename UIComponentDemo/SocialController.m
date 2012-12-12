//
//  SocialController.m
//  UIComponentDemo
//
//  Created by yan zheng on 12-10-9.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "SocialController.h"

@interface SocialController ()

@end

@implementation SocialController

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
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action: @selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = actionItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareAction:(id)sender {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Set as cover", nil];
        [actionSheet showInView:self.view];
        return;
    }
    
    NSArray *activityItems = [NSArray arrayWithObjects:@"test1", nil];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    
//    NSString *const UIActivityTypePostToFacebook;
//    NSString *const UIActivityTypePostToTwitter;
//    NSString *const UIActivityTypePostToWeibo;
//    NSString *const UIActivityTypeMessage;
//    NSString *const UIActivityTypeMail;
//    NSString *const UIActivityTypePrint;
//    NSString *const UIActivityTypeCopyToPasteboard;
//    NSString *const UIActivityTypeAssignToContact;

    [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:nil]];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"actionsheet click index: %d", buttonIndex);
}

@end

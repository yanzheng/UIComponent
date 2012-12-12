//
//  HomeViewController.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-3.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "HomeViewController.h"
#import "FolderViewController.h"
#import "IndexScrollContainer.h"
#import "BoundsDemo.h"
#import "PhotoAssetDemo.h"
#import "FlipDemo.h"
#import "ExpandingGridViewController.h"
#import "Twitter/Twitter.h"
#import "LocalNotificationController.h"
#import "SocialController.h"

extern NSString* CTSettingCopyMyPhoneNumber();

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize dataSource = _dataSource;

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        self.title = @"Demo List";
    }
    return self;    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.dataSource = [NSArray arrayWithObjects:@"Folder + ImageScroll + PullRefresh", @"IndexScrollController+ButtonSegment", @"BoundsAnimation", @"Flip Animation", @"PhotoAsset+PopupView", @"Multiple column Tableview", @"Local Notification", @"Social share", nil];
    
    NSLog(@"number: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSString *phone = CTSettingCopyMyPhoneNumber();
    NSLog(@"private num: %@", phone);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *demoController = nil;
    if (indexPath.row == 0) {
        demoController = [[FolderViewController alloc] init];
    } else if (indexPath.row == 1) {
        demoController = [[IndexScrollContainer alloc] init];
        [demoController view];
        [(IndexScrollContainer *)demoController jumpToControllerIndex:0];
    } else if (indexPath.row == 2) {
        demoController = [[BoundsDemo alloc] init];
    } else if (indexPath.row == 3) {
        demoController = [[FlipDemo alloc] init];
    } else if (indexPath.row == 4) {
        demoController = [[PhotoAssetDemo alloc] init];
    } else if (indexPath.row == 5) {
        demoController = [[ExpandingGridViewController alloc] init];
    } else if (indexPath.row == 6) {
        demoController = [[LocalNotificationController alloc] init];
    } else if (indexPath.row == 7) {
        demoController = [[SocialController alloc] init];
    }

    if (demoController)
        [self.navigationController pushViewController:demoController animated:YES];
}

@end

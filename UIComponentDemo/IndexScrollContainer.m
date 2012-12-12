//
//  IndexScrollContainer.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-3.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "IndexScrollContainer.h"
#import "MyTableViewController.h"

@interface IndexScrollContainer ()

@end

@implementation IndexScrollContainer

- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *contentControllers = [NSMutableArray array];
        
        for (int i = 0; i < 6; i++) {
            MyTableViewController *controller = [[MyTableViewController alloc] init];
            controller.homeNavController = self.navigationController;
            controller.view.frame = CGRectMake(0, 0, 320, 416-INDEX_SCROLL_VIEW_HEIGHT);
            controller.tableView.frame = controller.view.frame;
            controller.topicTitle = [NSString stringWithFormat:@"Topic %d", i];
            [contentControllers addObject:controller];
        }
        
        self.title = @"";
        self.contentControllers = contentControllers;        
    }
    return self;    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
//    UIImage *seg01 = [UIImage imageNamed:@"aifang_seg1.png"];
//    UIImage *seg01_sel = [UIImage imageNamed:@"aifang_seg1_sel.png"];
//    UIImage *seg02 = [UIImage imageNamed:@"aifang_seg2.png"];
//    UIImage *seg02_sel = [UIImage imageNamed:@"aifang_seg2_sel.png"];
    
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listButton setFrame:CGRectMake(0, 0, 58, 30)];
    [mapButton setFrame:CGRectMake(0, 0, 58, 30)];
//    [listButton setBackgroundImage:seg01 forState:UIControlStateNormal];
//    [listButton setBackgroundImage:seg01_sel forState:UIControlStateHighlighted | UIControlStateSelected];
//    [mapButton setBackgroundImage:seg02 forState:UIControlStateNormal];
//    [mapButton setBackgroundImage:seg02_sel forState:UIControlStateHighlighted | UIControlStateSelected];
//    NSArray *buttons = [NSArray arrayWithObjects:listButton, mapButton, nil];
//    segment = [[RTButtonSegmentControl alloc] initWithButtons:buttons];
//    segment.backgroundColor = [UIColor clearColor];
//    [segment addTarget:self action:@selector(doSwitch)];
//    segment.selectedSegmentIndex = 1;
//
//    self.navigationItem.titleView = segment;
}

- (void)doSwitch {
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

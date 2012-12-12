//
//  FolderViewController.h
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-3.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderViewController : UITableViewController<EGORefreshTableHeaderDelegate, RTPhotoScrollViewDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    RTPhotoScrollView *photoScroller;
}

- (id)init;

//@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *photoArray;
@property (nonatomic, strong) NSArray *photoCaptions;

@end

//
//  FolderViewController.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-3.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "FolderViewController.h"

@interface FolderViewController ()

@end

@implementation FolderViewController
//@synthesize tableView = _tableView;
@synthesize photoArray = _photoArray;
@synthesize photoCaptions = _photoCaptions;

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.photoArray = [NSArray arrayWithObjects:
                       @"http://d.pic1.ajkimg.com/display/aifang/c9890cf71376b9cdf3821511da1f9f00/444x332c.jpg",
                       @"http://c.pic1.ajkimg.com/display/aifang/21e90d19b745a598ba957f78552d343d/600x600.jpg",
                       @"http://b.pic1.ajkimg.com/display/aifang/e2fb314d0972f19738c00c1759afb460/600x600.jpg",
                       @"http://b.pic1.ajkimg.com/display/aifang/5487d049be38136be40b42c8744a21cb/600x600.jpg",
                       @"http://api.map.baidu.com/staticimage?center=121.44745918821,31.403946315418&zoom=14&width=630&height=266&markers=121.44745918821,31.403946315418&markerStyles=l,A",
                       nil];
        self.photoCaptions = [NSArray arrayWithObjects:@"test1", @"test2", @"test3", @"test4", @"test5", nil];
    }
    return self;    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)dealloc {
    photoScroller.tapDelegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
//    [_tableView setDelegate:self];
//    [_tableView setDataSource:self];
//    
//    [self.view addSubview:self.tableView];
    
    // EGO Pull Refresh
    if (_refreshHeaderView == nil) {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		_refreshHeaderView.delegate = self;
		[self.tableView addSubview:_refreshHeaderView];		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action: @selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = actionItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Section 0";
    }
        
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Folder Demo %d", indexPath.row];
    if (indexPath.section == 0) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        photoScroller = [[RTPhotoScrollView alloc] initWithFrame:backgroundView.bounds];
        photoScroller.tapDelegate = self;
        [photoScroller setPhotoUrls:self.photoArray];
        [photoScroller showAtIndex:indexPath.row%self.photoArray.count];
        [backgroundView addSubview:photoScroller];
        [cell.contentView addSubview:backgroundView];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 100;
    else
        return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell)
        return;
    
    CGPoint openPoint = CGPointMake(.0f, cell.frame.origin.y+cell.frame.size.height-tableView.contentOffset.y); //arbitrary point
//    NSLog(@"open point: %f, %f", openPoint.x, openPoint.y);
    
    UIView *noiseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    noiseView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise"]];
    
    photoScroller = [[RTPhotoScrollView alloc] initWithFrame:noiseView.bounds];
    photoScroller.tapDelegate = self;
    [photoScroller setPhotoUrls:self.photoArray];
    [photoScroller showAtIndex:indexPath.row%self.photoArray.count];
    [noiseView addSubview:photoScroller];
    [noiseView addSubview:photoScroller.pageControl];

    CGRect frame = noiseView.frame;
    if (openPoint.y < tableView.bounds.size.height-noiseView.bounds.size.height)
        frame.origin.y = openPoint.y;
    else
        frame.origin.y = tableView.bounds.size.height-noiseView.bounds.size.height;
    
    if (openPoint.y > tableView.bounds.size.height) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        openPoint = CGPointMake(.0f, tableView.bounds.size.height); //arbitrary point
    }
    
    noiseView.frame = frame;
    [JWFolders openFolderWithContentView:noiseView
                                position:openPoint 
                           containerView:self.view 
                                  sender:self 
                               openBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                   //perform custom animation here on contentView if you wish
//                                   NSLog(@"Folder view: %@ is opening with duration: %f", contentView, duration);
                               }
                              closeBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                  //also perform custom animation here on contentView if you wish
//                                  NSLog(@"Folder view: %@ is closing with duration: %f", contentView, duration);
                              }
                         completionBlock:^ {
                             //the folder is closed and gone, lets do something cool!
                         }
     ];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    return;
}

- (void)singleTapAtIndex:(NSUInteger)index {
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] init];
    [photoBrowser setPhotoUrls:(NSMutableArray *)self.photoArray];
    [photoBrowser setPhotoCaptions:(NSMutableArray *)self.photoCaptions];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    [self presentModalViewController:nav animated:YES];
    [photoBrowser showAtIndex:0];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)shareAction:(id)sender {
//    ActivityImageItem *imageItem = [[ActivityImageItem alloc] init];
//    ActivityStringItem *contentItem = [[ActivityStringItem alloc] init];
//    ActivityStringItem *signItem = [[ActivityStringItem alloc] init];
//
//    imageItem.activityImage = [UIImage imageNamed:@"th.png"];
//    contentItem.activityContext = @"oh my activity!";
//    signItem.activityContext = @"sent by demo";
//
//    NSArray *activityItems = [NSArray arrayWithObjects:imageItem, contentItem, signItem, nil];
//    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:nil];
}


@end

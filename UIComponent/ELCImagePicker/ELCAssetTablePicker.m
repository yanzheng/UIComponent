//
//  AssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import <QuartzCore/QuartzCore.h>

@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;

@end

@implementation ELCAssetTablePicker

@synthesize parent = _parent;;
@synthesize selectedAssetsLabel = _selectedAssetsLabel;
@synthesize assetGroup = _assetGroup;
@synthesize elcAssets = _elcAssets;
@synthesize singleSelection = _singleSelection;
@synthesize columns = _columns;

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
    if (self.immediateReturn) {
        
    } else {
        UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
        [self.navigationItem setRightBarButtonItem:doneButtonItem];
        [self.navigationItem setTitle:NSLocalizedString(@"Pick Photos", nil)];
    }

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
    
    if (!self.progressHUD) {
        self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        self.progressHUD.minSize = CGSizeMake(120, 120);
        self.progressHUD.minShowTime = 1;
        [self.navigationController.view addSubview:self.progressHUD];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"enumerating photos");
    [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
     
        if(result == nil) {
            return;
        }

        ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
        if ([self.excludedAssetURLList containsObject:elcAsset.asset.defaultRepresentation.url])
            [elcAsset setMasked:YES];
        [elcAsset setParent:self];
        
        BOOL isAssetFiltered = NO;
        if (self.assetPickerFilterDelegate &&
           [self.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
        {
	        isAssetFiltered = [self.assetPickerFilterDelegate assetTablePicker:self isAssetFilteredOut:(ELCAsset*)elcAsset];
        }

        if (!isAssetFiltered) {
	        [self.elcAssets addObject:elcAsset];
        }
        
        [elcAsset release];
     }];
//    NSLog(@"done enumerating photos");
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
//        // scroll to bottom
//        long section = [self numberOfSectionsInTableView:self.tableView] - 1;
//        long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
//        if (section >= 0 && row >= 0) {
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:row
//                                                 inSection:section];
//            [self.tableView scrollToRowAtIndexPath:ip
//                                  atScrollPosition:UITableViewScrollPositionBottom
//                                          animated:NO];
//        }
        
        [self.navigationItem setTitle:self.singleSelection ? NSLocalizedString(@"Pick Photo", nil) : NSLocalizedString(@"Pick Photos", nil)];
    });
    
    [pool release];

}

- (void)doneAction:(id)sender
{
    self.progressHUD.labelText = NSLocalizedString(@"Loading...", nil);
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    

	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) {

		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [self.parent selectedAssets:selectedAssetsImages];
}

- (void)assetSelected:(id)asset
{
    if (self.singleSelection) {

        for(ELCAsset *elcAsset in self.elcAssets) {
            if(asset != elcAsset) {
                elcAsset.selected = NO;
            }
        }
    }
    if (self.immediateReturn) {
        NSArray *singleAssetArray = [NSArray arrayWithObject:[asset asset]];
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil([self.elcAssets count] / (float)self.columns);
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    long index = path.row * self.columns;
    long length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];

    } else {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) {
		if([asset selected]) {   
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    self.progressHUD = nil;
    self.excludedAssetURLList = nil;

    [_assetGroup release];
    [_elcAssets release];
    [_selectedAssetsLabel release];
    [super dealloc];    
}

@end

//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize assetGroup, elcAssets;
@synthesize progressView;
@synthesize excludedAssetURLList;

-(void)viewDidLoad {
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self.navigationItem setTitle:NSLocalizedString(@"Pick Photos", nil)];
    
    // disable done button when loading photos
    self.navigationItem.rightBarButtonItem.enabled = NO;

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationController.view.bounds.size.width/2 - 50, self.navigationController.view.bounds.size.height/2 - 50, 100, 100)];
    self.progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 8.0f;
    
    UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [self.progressView addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(30, 30, 40, 40);
    [activityIndicator startAnimating];
}

-(void)preparePhotos {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {         
         if(result == nil) 
         {
             return;
         }
         
         ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
         if ([self.excludedAssetURLList containsObject:elcAsset.asset.defaultRepresentation.url])
             [elcAsset setMasked:YES];
         
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];
    
    // enable done button when load finish
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
	[self.tableView reloadData];    
    
    [pool release];
}

- (void)doneAction:(id)sender {
    [self.navigationController.view addSubview:self.progressView];
    [self performSelector:@selector(handlePhotos) withObject:nil afterDelay:0];
}

- (void)handlePhotos {
    NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
    for(ELCAsset *elcAsset in self.elcAssets)
    {
        if([elcAsset selected]) {
            
            [selectedAssetsImages addObject:[elcAsset asset]];
        }
    }
    
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
    [self.progressView removeFromSuperview];    
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    self.progressView = nil;
    self.excludedAssetURLList = nil;
    
    [elcAssets release];
    [super dealloc];
}

@end

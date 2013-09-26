//
//  Asset.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@implementation ELCAsset

@synthesize asset = _asset;
@synthesize parent = _parent;
@synthesize selected = _selected;

- (id)initWithAsset:(ALAsset*)asset
{
	self = [super init];
	if (self) {
		self.asset = asset;
        _selected = NO;
    }
    
	return self;	
}

- (void)toggleSelection
{
    if (self.masked)
        return;
    
    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 30) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Maximum support 30 photos", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
    }
    
    self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        if (_parent != nil && [_parent respondsToSelector:@selector(assetSelected:)]) {
            [_parent assetSelected:self];
        }
    }
}

- (void)dealloc 
{    
    [_asset release];
    [super dealloc];
}

@end


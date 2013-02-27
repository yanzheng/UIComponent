//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@implementation ELCAsset

@synthesize asset;
@synthesize parent;
@synthesize masked = _masked;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		[assetImageView release];
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {
    if (self.masked)
        return;
    
    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 30) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Maximum support 30 photos", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
    }

	overlayView.hidden = !overlayView.hidden;
}

-(BOOL)selected {
    if (self.masked)
        return NO;
    
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    if (self.masked)
        return;
    
	[overlayView setHidden:!_selected];
}

- (void)setMasked:(BOOL)masked {
    _masked = masked;
    if (_masked) {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        maskView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.6];
        [self addSubview:maskView];
    } else {
        
    }
}

- (void)dealloc
{    
    self.asset = nil;
	[overlayView release];
    [super dealloc];
}

@end


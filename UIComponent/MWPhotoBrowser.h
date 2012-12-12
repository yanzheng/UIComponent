//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RTPhotoScrollView.h"

@protocol MWPhotoBrowserDelegate <NSObject>
- (void)photoDidRemoved:(NSUInteger)index;
- (void)photoSetDefault:(NSUInteger)index;
@end


@interface MWPhotoBrowser : UIViewController <RTPhotoScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    UIView *_captionView;
    UILabel *_captionLabel;
}

// flag
@property (nonatomic, assign) BOOL customizeToolBar;
@property (nonatomic, retain) UIToolbar *toolbar;

// Properties
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic, assign) id<MWPhotoBrowserDelegate> delegate;
// Init
@property (nonatomic, retain) NSMutableArray *photoPaths;
@property (nonatomic, retain) NSMutableArray *photoUrls;
@property (nonatomic, retain) NSMutableArray *photoCaptions;
@property (nonatomic, retain) RTPhotoScrollView *pagingScrollView;
@property (nonatomic, copy) NSString *browserTitle;

@property (nonatomic, assign) CGFloat padding;

- (void)hideControlsAfterDelay;

- (void)showAtIndex:(NSInteger)index;

@end



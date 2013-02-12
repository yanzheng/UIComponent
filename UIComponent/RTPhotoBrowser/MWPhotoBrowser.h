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


@interface MWPhotoBrowser : UIViewController <RTPhotoScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSUInteger _currentPageIndex;

    UIView *_captionView;
    UILabel *_captionLabel;
    UIBarButtonItem *_actionButton, *_deleteButton;
    UIBarButtonItem *_previousButton, *_nextButton;
}

// customize toolbar
@property (nonatomic, assign) BOOL customizeToolBar;
@property (nonatomic, retain) UIToolbar *toolbar;

// Properties
@property (nonatomic) BOOL displayActionButton;

// Init
@property (nonatomic, retain) NSMutableArray *photoPaths;
@property (nonatomic, retain) NSMutableArray *photoUrls;
@property (nonatomic, retain) NSMutableArray *photoCaptions;
@property (nonatomic, retain) RTPhotoScrollView *pagingScrollView;
@property (nonatomic, copy) NSString *browserTitle;

@property (nonatomic, assign) CGFloat padding;

- (NSUInteger)numberOfPhotos;
- (void)hideControlsAfterDelay;
- (void)showAtIndex:(NSInteger)index;

- (void)actionButtonPressed:(id)sender;
- (void)trashButtonPressed:(id)sender;

@end



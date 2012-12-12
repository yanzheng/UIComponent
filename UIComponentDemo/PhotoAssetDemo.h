//
//  PhotoAssetDemo.h
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-10.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAssetDemo : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, RTPopupSheetDelegate> {
    NSURL *_assetURL;
    RTPopupSheet *popupView;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *assetLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *thumbImageView;
- (IBAction)takePhoto:(id)sender;
- (IBAction)loadPhoto:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)loadThumb:(id)sender;
@end

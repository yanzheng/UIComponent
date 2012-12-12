//
//  PhotoAssetDemo.m
//  UIComponentDemo
//
//  Created by zheng yan on 12-8-10.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "PhotoAssetDemo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "RTLocationManager.h"

@interface PhotoAssetDemo ()

@end

@implementation PhotoAssetDemo
@synthesize addPhotoButton;
@synthesize assetLabel;
@synthesize imageView;
@synthesize thumbImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setAssetLabel:nil];
    [self setThumbImageView:nil];
    [self setAddPhotoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)takePhoto:(id)sender {
    popupView = [[RTPopupSheet alloc] initWithDelegate:self titles:[NSArray arrayWithObjects:@"SHOT", @"CHOOSE", nil]];
    popupView.backgroundColor = [UIColor greenColor];
    CGPoint point = self.addPhotoButton.center;
    if (point.y > 300)
        point.y -= self.addPhotoButton.bounds.size.height/2;
    else 
        point.y += self.addPhotoButton.bounds.size.height/2;
    point.x += self.addPhotoButton.bounds.size.width/2;
    
    [popupView presentAtPoint:point inView:self.view];// showAtPoint:point inView:self.view animated:YES];
}

- (void)popupSheet:(RTPopupSheet *)popupSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self shotAction:nil];
    else 
        [self chooseAction:nil];
}

- (void)shotAction:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return;
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];    
}

- (void)chooseAction:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];        
}

- (IBAction)loadPhoto:(id)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:_assetURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        self.imageView.image = [UIImage imageWithCGImage:representation.fullScreenImage];

        NSDictionary *metadataDict = [representation metadata]; 
        NSDictionary *metaData = [metadataDict objectForKey:@"{GPS}"];
        NSLog(@"gps info: %@", metaData);
        NSLog(@"file name: %@, size:%llu", representation.filename, representation.size);
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];        
}

- (IBAction)resetAction:(id)sender {
    self.imageView.image = nil;
    self.thumbImageView.image = nil;
}

- (IBAction)loadThumb:(id)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:_assetURL resultBlock:^(ALAsset *asset) {
        self.thumbImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];        
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"photo info: %@", info);

    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    self.imageView.image = image;

    NSURL *assetURLCamera = [info objectForKey:UIImagePickerControllerReferenceURL];    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    CLLocation *location = [[RTLocationManager sharedInstance] userLocation];

    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSDictionary *gpsInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[self getGPSDictionaryForLocation:location], @"{GPS}", nil];
    
    NSLog(@"camera asset:%@", assetURLCamera);
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:gpsInfoDict completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"library asset:%@", assetURL);
        _assetURL = assetURL;
        self.assetLabel.text = [assetURL description];
    }]; 
}

//FOR CAMERA IMAGE

- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}


@end

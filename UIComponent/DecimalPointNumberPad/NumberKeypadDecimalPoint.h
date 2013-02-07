//
//  DecimalPointButton.h
//  iDeal
//
//  Created by David Casserly on 13/03/2010.
//  Copyright 2010 devedup.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	The UIButton that will have the decimal point on it
 */
@interface DecimalPointButton : UIButton {
	CGFloat screenHeight;
}

+ (DecimalPointButton *) decimalPointButton;

@end


/**
 *	The class used to create the keypad
 */
@interface NumberKeypadDecimalPoint : NSObject {
	
	UITextField *currentTextField;
	
	DecimalPointButton *decimalPointButton;
	
	NSTimer *showDecimalPointTimer;
}

@property (nonatomic, retain) NSTimer *showDecimalPointTimer;
@property (nonatomic, retain) DecimalPointButton *decimalPointButton;

@property (assign) UITextField *currentTextField;

#pragma mark -
#pragma mark Show the keypad

+ (NumberKeypadDecimalPoint *) keypadForTextField:(UITextField *)textField; 

- (void) removeButtonFromKeyboard;

@end



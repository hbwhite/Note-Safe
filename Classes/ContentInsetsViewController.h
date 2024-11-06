//
//  ContentInsetsViewController.h
//  Note Safe
//
//  Created by Harrison White on 12/8/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentInsetsViewController : UITableViewController <UITextFieldDelegate> {
	UITextField *selectedTextField;
	NSDecimalNumberHandler *decimalNumberHandler;
	CGFloat maximumContentWidth;
	CGFloat maximumContentHeight;
}

@property (nonatomic, assign) UITextField *selectedTextField;
@property (nonatomic, assign) NSDecimalNumberHandler *decimalNumberHandler;
@property (nonatomic) CGFloat maximumContentWidth;
@property (nonatomic) CGFloat maximumContentHeight;

- (NSString *)keyForTextFieldWithTag:(NSInteger)tag;
- (NSDecimalNumber *)decimalNumberForString:(NSString *)string;
- (void)textFieldEditingChanged:(id)sender;
- (void)doneButtonPressed;
- (void)saveMarginSizeForTextField:(UITextField *)textField;

@end

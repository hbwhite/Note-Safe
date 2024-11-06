//
//  PrintingOptionsViewController.h
//  Note Safe
//
//  Created by Harrison White on 1/29/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintingOptionsViewController : UITableViewController <UITextFieldDelegate> {
	
}

- (void)textFieldEditingChanged:(id)sender;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)doneButtonPressed;
- (void)savePrintedFontSizeForText:(NSString *)text;

@end

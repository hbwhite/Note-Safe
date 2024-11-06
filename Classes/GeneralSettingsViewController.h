//
//  GeneralSettingsViewController.h
//  Note Safe
//
//  Created by Harrison White on 10/31/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralSettingsViewController : UITableViewController <UITextFieldDelegate> {
	
}

- (void)switchValueChanged:(id)sender;
- (void)textFieldEditingChanged:(id)sender;
- (void)doneButtonPressed;
- (void)saveFontSizeForText:(NSString *)text;

@end

//
//  ForgotPasscodeSettingsViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/24/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasscodeSettingsViewController : UITableViewController <UITextFieldDelegate> {
	NSMutableString *securityQuestion;
	NSMutableString *securityQuestionAnswer;
}

@property (nonatomic, assign) NSMutableString *securityQuestion;
@property (nonatomic, assign) NSMutableString *securityQuestionAnswer;

- (void)switchValueChanged:(id)sender;
- (void)textFieldEditingChanged:(id)sender;
- (void)saveSecurityInformation;

@end

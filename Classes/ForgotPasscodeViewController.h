//
//  ForgotPasscodeViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/20/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ForgotPasscodeViewController : UITableViewController <UITextFieldDelegate> {
	
}

- (void)doneButtonPressed;
- (void)verifySecurityQuestionAnswer;

@end

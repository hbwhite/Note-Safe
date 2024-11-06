//
//  PasscodeSettingsViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/17/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"

@interface PasscodeSettingsViewController : UITableViewController <LoginViewDelegate> {
	
}

- (void)switchValueChanged:(id)sender;

@end

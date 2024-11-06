//
//  SettingsViewController.h
//  Note Safe
//
//  Created by Harrison White on 10/22/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"

@class HUDView;

@interface SettingsViewController : UITableViewController <LoginViewDelegate> {
	BOOL isAccessingPasscodeSettings;
	NSMutableArray *originalFilesArray;
	NSInteger currentItem;
	HUDView *hudView;
}

@property (readwrite) BOOL isAccessingPasscodeSettings;
@property (nonatomic, assign) NSMutableArray *originalFilesArray;
@property (nonatomic) NSInteger currentItem;
@property (nonatomic, assign) HUDView *hudView;

- (void)modifyCell:(UITableViewCell *)cell setEnabled:(BOOL)enabled;
- (BOOL)isWirelessPrintingSupported;
- (void)pushPasscodeSettingsViewControllerAnimated:(BOOL)animated;
- (void)pushForgotPasscodeSettingsViewControllerAnimated:(BOOL)animated;
- (NSString *)temporaryDirectory;
- (NSString *)filePathForNoteWithTitle:(NSString *)title copyNumber:(NSInteger)copyNumber;
- (void)_showHUD;
- (void)fadeOutHUD;
- (void)_updateElements;

@end

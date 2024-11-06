//
//  LoginViewController.h
//  Note Safe
//
//  Created by Harrison White on 2/3/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginTypes.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	IBOutlet UIScrollView *loginScrollView;
	IBOutlet UIView *forgotPasscodeView;
	IBOutlet UIButton *forgotPasscodeButton;
	IBOutlet UILabel *forgotPasscodeLabel;
	IBOutlet UIView *failedPasscodeAttemptsView;
	IBOutlet UILabel *failedPasscodeAttemptsLabel;
	IBOutlet UIImageView *failedPasscodeAttemptsImageView;
	NSDecimalNumberHandler *decimalNumberHandler;
	kLoginViewType originalFirstSegmentLoginViewType;
	kLoginViewType firstSegmentLoginViewType;
	kLoginViewType secondSegmentLoginViewType;
	kLoginType loginType;
	
	IBOutlet UIView *fourDigitOneSegmentView;
	IBOutlet UIView *fourDigitTwoSegmentView;
	IBOutlet UIView *textFieldOneSegmentView;
	IBOutlet UIView *textFieldTwoSegmentView;
	
	IBOutlet UITableView *fourDigitOneSegmentTableView;
	IBOutlet UITableView *fourDigitTwoSegmentTableView1;
	IBOutlet UITableView *fourDigitTwoSegmentTableView2;
	IBOutlet UITableView *textFieldOneSegmentTableView;
	IBOutlet UITableView *textFieldTwoSegmentTableView1;
	IBOutlet UITableView *textFieldTwoSegmentTableView2;
	
	IBOutlet UITextField *fourDigitOneSegmentTextField;
	IBOutlet UITextField *fourDigitTwoSegmentTextField1;
	IBOutlet UITextField *fourDigitTwoSegmentTextField2;
	
	IBOutlet UIImageView *imageView1;
	IBOutlet UIImageView *imageView2;
	IBOutlet UIImageView *imageView3;
	IBOutlet UIImageView *imageView4;
	IBOutlet UIImageView *imageView5;
	IBOutlet UIImageView *imageView6;
	IBOutlet UIImageView *imageView7;
	IBOutlet UIImageView *imageView8;
	IBOutlet UIImageView *imageView9;
	IBOutlet UIImageView *imageView10;
	IBOutlet UIImageView *imageView11;
	IBOutlet UIImageView *imageView12;
	
	NSTimer *lockoutModeStatusTimer;
	NSMutableString *updatedPasscode;
	NSInteger currentBlock;
	BOOL didEnterIncorrectPasscode;
	BOOL noMatchViewEnabled;
	BOOL passcodeIsNotDifferent;
	BOOL passcodesDidNotMatch;
	BOOL isInLockoutMode;
}

@property (nonatomic, retain) IBOutlet UIScrollView *loginScrollView;
@property (nonatomic, retain) IBOutlet UIView *forgotPasscodeView;
@property (nonatomic, retain) IBOutlet UIButton *forgotPasscodeButton;
@property (nonatomic, retain) IBOutlet UILabel *forgotPasscodeLabel;
@property (nonatomic, retain) IBOutlet UIView *failedPasscodeAttemptsView;
@property (nonatomic, retain) IBOutlet UILabel *failedPasscodeAttemptsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *failedPasscodeAttemptsImageView;
@property (nonatomic, assign) NSDecimalNumberHandler *decimalNumberHandler;
@property (nonatomic, assign) kLoginViewType firstSegmentLoginViewType;
@property (nonatomic, assign) kLoginViewType secondSegmentLoginViewType;
@property (nonatomic, assign) kLoginType loginType;

@property (nonatomic, retain) IBOutlet UIView *fourDigitOneSegmentView;
@property (nonatomic, retain) IBOutlet UIView *fourDigitTwoSegmentView;
@property (nonatomic, retain) IBOutlet UIView *textFieldOneSegmentView;
@property (nonatomic, retain) IBOutlet UIView *textFieldTwoSegmentView;

@property (nonatomic, assign) IBOutlet UITableView *fourDigitOneSegmentTableView;
@property (nonatomic, assign) IBOutlet UITableView *fourDigitTwoSegmentTableView1;
@property (nonatomic, assign) IBOutlet UITableView *fourDigitTwoSegmentTableView2;
@property (nonatomic, assign) IBOutlet UITableView *textFieldOneSegmentTableView;
@property (nonatomic, assign) IBOutlet UITableView *textFieldTwoSegmentTableView1;
@property (nonatomic, assign) IBOutlet UITableView *textFieldTwoSegmentTableView2;

@property (nonatomic, retain) IBOutlet UITextField *fourDigitOneSegmentTextField;
@property (nonatomic, retain) IBOutlet UITextField *fourDigitTwoSegmentTextField1;
@property (nonatomic, retain) IBOutlet UITextField *fourDigitTwoSegmentTextField2;

@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (nonatomic, retain) IBOutlet UIImageView *imageView2;
@property (nonatomic, retain) IBOutlet UIImageView *imageView3;
@property (nonatomic, retain) IBOutlet UIImageView *imageView4;
@property (nonatomic, retain) IBOutlet UIImageView *imageView5;
@property (nonatomic, retain) IBOutlet UIImageView *imageView6;
@property (nonatomic, retain) IBOutlet UIImageView *imageView7;
@property (nonatomic, retain) IBOutlet UIImageView *imageView8;
@property (nonatomic, retain) IBOutlet UIImageView *imageView9;
@property (nonatomic, retain) IBOutlet UIImageView *imageView10;
@property (nonatomic, retain) IBOutlet UIImageView *imageView11;
@property (nonatomic, retain) IBOutlet UIImageView *imageView12;

@property (nonatomic, assign) NSTimer *lockoutModeStatusTimer;
@property (nonatomic, assign) NSMutableString *updatedPasscode;
@property (nonatomic) NSInteger currentBlock;

@property (readwrite) BOOL didEnterIncorrectPasscode;
@property (readwrite) BOOL noMatchViewEnabled;
@property (readwrite) BOOL passcodeIsNotDifferent;
@property (readwrite) BOOL passcodesDidNotMatch;
@property (readwrite) BOOL isInLockoutMode;

- (IBAction)forgotPasscodeButtonPressed;
- (void)backButtonPressed;
- (IBAction)textFieldEditingChanged;
- (void)textFieldEditingChangedAction;
- (void)updatePasscodeBoxes:(NSArray *)passcodeBoxes;
- (void)textFieldDidFinishEditing;
- (BOOL)passcodeExists;
- (BOOL)passcodeIsCorrect:(NSString *)passcode;
- (NSString *)applicationDataStorageDirectory;
- (void)authenticationDidFail;
- (void)authenticationDidSucceed;
- (void)setUpNextButton;
- (void)setUpDoneButton;
- (void)updateFailedPasscodeAttemptsLabel;
- (void)enterLockoutMode;
- (void)updateLockoutModeStatus;
- (void)dismiss;
- (void)addFirstSegmentSubview;
- (void)addBothSegmentSubviews;
- (UITableView *)currentTableView;
- (UITextField *)currentTextField;
- (UITableView *)tableViewForBlock:(NSInteger)block;
- (UITextField *)textFieldForBlock:(NSInteger)block;
- (void)reloadTableViews;
- (NSString *)permittedAccessTimeKey;
- (NSInteger)minutesBeforeLogin;
- (NSInteger)absoluteTimeInteger;

@end

//
//  LoginViewController.m
//  Note Safe
//
//  Created by Harrison White on 2/3/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginNavigationController.h"
#import "ForgotPasscodeViewController.h"
#import "Note_SafeAppDelegate.h"
#import "TextFieldCell.h"

// Below delegate protocol declaration (and, thus, the following header import) is not necessary if declaring the protocol in LoginNavigationController.h, as stated below.
#import "LoginView.h"

#define MAXIMUM_LOGIN_ATTEMPTS							5
#define ERASE_DATA_LOGIN_ATTEMPT_COUNT					10
#define LOCKOUT_SECONDS_ARRAY							[NSArray arrayWithObjects:@"60", @"300", @"900", @"1800", @"3600", nil]

#define FIRST_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView1, imageView2, imageView3, imageView4, nil]
#define SECOND_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView5, imageView6, imageView7, imageView8, nil]
#define THIRD_IMAGE_VIEW_BLOCK							[NSArray arrayWithObjects:imageView9, imageView10, imageView11, imageView12, nil]

static NSString *kEraseDataKey							= @"Erase Data";
static NSString *kFailedPasscodeAttemptsKey				= @"Failed Passcode Attempts";
static NSString *kPasscodeKey							= @"Passcode";
static NSString *kForgotPasscodeOptionEnabledKey		= @"Forgot Passcode Option Enabled";
static NSString *kPasscodeRequirementDelayIndexKey		= @"Passcode Requirement Delay Index";
static NSString *kPermittedLoginAccessTimeKey			= @"Permitted Login Access Time";
static NSString *kPermittedAuthenticationAccessTimeKey	= @"Permitted Authentication Access Time";
static NSString *kSimplePasscodeKey						= @"Simple Passcode";
static NSString *kNumericPasscodeKey					= @"Numeric Passcode";

static NSString *kBoxEmptyImageName						= @"Box-Empty";
static NSString *kBoxFullImageName						= @"Box-Full";

static NSString *kNumericCharacterSetStr				= @"1234567890";

static NSString *kFloatFormatSpecifierStr				= @"%f";
static NSString *kIntegerFormatSpecifierStr				= @"%i";
static NSString *kNullStr								= @"";

@implementation LoginViewController

@synthesize loginScrollView;
@synthesize forgotPasscodeView;
@synthesize forgotPasscodeButton;
@synthesize forgotPasscodeLabel;
@synthesize failedPasscodeAttemptsView;
@synthesize failedPasscodeAttemptsLabel;
@synthesize failedPasscodeAttemptsImageView;
@synthesize decimalNumberHandler;
@synthesize firstSegmentLoginViewType;
@synthesize secondSegmentLoginViewType;
@synthesize loginType;

@synthesize fourDigitOneSegmentView;
@synthesize fourDigitTwoSegmentView;
@synthesize textFieldOneSegmentView;
@synthesize textFieldTwoSegmentView;

@synthesize fourDigitOneSegmentTableView;
@synthesize fourDigitTwoSegmentTableView1;
@synthesize fourDigitTwoSegmentTableView2;
@synthesize textFieldOneSegmentTableView;
@synthesize textFieldTwoSegmentTableView1;
@synthesize textFieldTwoSegmentTableView2;

@synthesize fourDigitOneSegmentTextField;
@synthesize fourDigitTwoSegmentTextField1;
@synthesize fourDigitTwoSegmentTextField2;

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize imageView6;
@synthesize imageView7;
@synthesize imageView8;
@synthesize imageView9;
@synthesize imageView10;
@synthesize imageView11;
@synthesize imageView12;

@synthesize lockoutModeStatusTimer;
@synthesize updatedPasscode;
@synthesize currentBlock;

@synthesize didEnterIncorrectPasscode;
@synthesize noMatchViewEnabled;
@synthesize passcodeIsNotDifferent;
@synthesize passcodesDidNotMatch;
@synthesize isInLockoutMode;

- (IBAction)forgotPasscodeButtonPressed {
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	ForgotPasscodeViewController *forgotPasscodeViewController = [[ForgotPasscodeViewController alloc]initWithNibName:@"ForgotPasscodeViewController" bundle:nil];
	forgotPasscodeViewController.title = @"Forgot Passcode";
	[[self currentTextField]setText:nil];
	[self.navigationController pushViewController:forgotPasscodeViewController animated:YES];
	[forgotPasscodeViewController release];
}

- (void)backButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)textFieldEditingChanged {
	[self textFieldEditingChangedAction];
}

- (void)textFieldEditingChangedAction {
	UIBarButtonItem *rightBarButtonItem = self.navigationItem.rightBarButtonItem;
	if ([[[self currentTextField]text]length] > 0) {
		if (!rightBarButtonItem.enabled) {
			rightBarButtonItem.enabled = YES;
		}
	}
	else if (rightBarButtonItem.enabled) {
		rightBarButtonItem.enabled = NO;
	}
	if (currentBlock == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			[self updatePasscodeBoxes:FIRST_IMAGE_VIEW_BLOCK];
		}
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		if (currentBlock == 1) {
			[self updatePasscodeBoxes:SECOND_IMAGE_VIEW_BLOCK];
		}
		else {
			[self updatePasscodeBoxes:THIRD_IMAGE_VIEW_BLOCK];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self textFieldDidFinishEditing];
	return NO;
}

- (void)textFieldDidFinishEditing {
	if (currentBlock == 0) {
		if ((loginType == kLoginTypeCreatePasscode) || ((loginType != kLoginTypeCreatePasscode) && ([self passcodeIsCorrect:[[self currentTextField]text]]))) {
			[self authenticationDidSucceed];
		}
		else {
			[self authenticationDidFail];
		}
	}
	else if (currentBlock == 1) {
		NSString *passcode = [[self currentTextField]text];
		if ([self passcodeIsCorrect:passcode]) {
			if (!passcodeIsNotDifferent) {
				passcodeIsNotDifferent = YES;
				[[self currentTableView]reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					[currentTextField becomeFirstResponder];
				}
			}
		}
		else {
			[updatedPasscode setString:passcode];
			if (passcodeIsNotDifferent) {
				passcodeIsNotDifferent = NO;
			}
			currentBlock = 2;
			if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
				[self setUpDoneButton];
			}
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
				[currentTextField becomeFirstResponder];
			}
			[loginScrollView setContentOffset:CGPointMake(640, 0) animated:YES];
		}
	}
	else {
		if ([updatedPasscode isEqualToString:[[self textFieldForBlock:2]text]]) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			if ([updatedPasscode rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:kNumericCharacterSetStr]invertedSet]].length > 0) {
				if ([defaults boolForKey:kNumericPasscodeKey]) {
					[defaults setBool:NO forKey:kNumericPasscodeKey];
				}
			}
			else if (![defaults boolForKey:kNumericPasscodeKey]) {
				[defaults setBool:YES forKey:kNumericPasscodeKey];
			}
			[defaults synchronize];
			
			Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
			if (loginType == kLoginTypeChangePasscode) {
				[delegate updateKeychainValue:updatedPasscode forIdentifier:kPasscodeKey];
				if (originalFirstSegmentLoginViewType == kLoginViewTypeFourDigit) {
					NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
					[defaults setBool:NO forKey:kSimplePasscodeKey];
					[defaults synchronize];
				}
			}
			else {
				[delegate createKeychainValue:updatedPasscode forIdentifier:kPasscodeKey];
			}
			[self dismiss];
		}
		else {
			currentBlock = 1;
			passcodesDidNotMatch = YES;
			if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
				firstSegmentLoginViewType = kLoginViewTypeTextField;
				[fourDigitOneSegmentView removeFromSuperview];
				textFieldOneSegmentView.frame = CGRectMake(0, 0, 320, 416);
				[loginScrollView insertSubview:textFieldOneSegmentView atIndex:0];
				[self setUpNextButton];
			}
			[[self tableViewForBlock:0]reloadData];
			[[self tableViewForBlock:1]reloadData];
			[[self textFieldForBlock:1]setText:kNullStr];
			
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
				[currentTextField becomeFirstResponder];
			}
			
			[self setUpNextButton];
			
			[loginScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
			[loginScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
			[[self textFieldForBlock:2]setText:kNullStr];
		}
	}
}

- (void)updatePasscodeBoxes:(NSArray *)passcodeBoxes {
	UIImage *boxEmptyImage = [UIImage imageNamed:kBoxEmptyImageName];
	UIImage *boxFullImage = [UIImage imageNamed:kBoxFullImageName];
	for (int i = 0; i < 4; i++) {
		UIImageView *imageView = [passcodeBoxes objectAtIndex:i];
		if ([[[self currentTextField]text]length] > i) {
			if (![imageView.image isEqual:boxFullImage]) {
				imageView.image = boxFullImage;
			}
		}
		else if (![imageView.image isEqual:boxEmptyImage]) {
			imageView.image = boxEmptyImage;
		}
	}
	UITextField *currentTextField = [self currentTextField];
	NSInteger textLength = [currentTextField.text length];
	if (textLength >= 4) {
		if (textLength > 4) {
			currentTextField.text = [currentTextField.text substringToIndex:4];
		}
		if (currentBlock == 0) {
			if ((loginType == kLoginTypeCreatePasscode) || ((loginType != kLoginTypeCreatePasscode) && ([self passcodeIsCorrect:[[self currentTextField]text]]))) {
				[self authenticationDidSucceed];
			}
			else {
				currentTextField.text = kNullStr;
				[self updatePasscodeBoxes:passcodeBoxes];
				[self authenticationDidFail];
			}
		}
		else if (currentBlock == 1) {
			NSString *passcode = [[self currentTextField]text];
			if ([self passcodeIsCorrect:passcode]) {
				if (!passcodeIsNotDifferent) {
					passcodeIsNotDifferent = YES;
					[[self currentTableView]reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
				}
				currentTextField.text = kNullStr;
				[self updatePasscodeBoxes:passcodeBoxes];
			}
			else {
				[updatedPasscode setString:passcode];
				if (passcodeIsNotDifferent) {
					passcodeIsNotDifferent = NO;
				}
				currentBlock = 2;
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					[currentTextField becomeFirstResponder];
				}
				[loginScrollView setContentOffset:CGPointMake(640, 0) animated:YES];
			}
		}
		else {
			if ([updatedPasscode isEqualToString:[[self textFieldForBlock:2]text]]) {
				Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
				if (loginType == kLoginTypeChangePasscode) {
					[delegate updateKeychainValue:updatedPasscode forIdentifier:kPasscodeKey];
					if (originalFirstSegmentLoginViewType == kLoginViewTypeTextField) {
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[defaults setBool:YES forKey:kSimplePasscodeKey];
						[defaults synchronize];
					}
				}
				else if (loginType == kLoginTypeCreatePasscode) {
					[delegate createKeychainValue:updatedPasscode forIdentifier:kPasscodeKey];
					
				}
				[self dismiss];
			}
			else {
				currentBlock = 1;
				if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
					firstSegmentLoginViewType = kLoginViewTypeFourDigit;
					[textFieldOneSegmentView removeFromSuperview];
					fourDigitOneSegmentView.frame = CGRectMake(0, 0, 320, 416);
					[loginScrollView insertSubview:fourDigitOneSegmentView atIndex:0];
				}
				UITextField *currentTextField = [self currentTextField];
				if (![currentTextField isFirstResponder]) {
					[currentTextField becomeFirstResponder];
				}
				passcodesDidNotMatch = YES;
				[[self tableViewForBlock:0]reloadData];
				[[self tableViewForBlock:1]reloadData];
				[[self textFieldForBlock:1]setText:kNullStr];
				[self updatePasscodeBoxes:SECOND_IMAGE_VIEW_BLOCK];
				[loginScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
				[loginScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
				[[self textFieldForBlock:2]setText:kNullStr];
				[self updatePasscodeBoxes:THIRD_IMAGE_VIEW_BLOCK];
			}
		}
	}
}

- (BOOL)passcodeExists {
	return ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]searchKeychainCopyMatching:kPasscodeKey] != nil);
}

- (BOOL)passcodeIsCorrect:(NSString *)passcode {
	return [passcode isEqualToString:[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey]];
}

- (NSString *)applicationDataStorageDirectory {
	return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Documents"];
}

- (void)authenticationDidFail {
	if (!didEnterIncorrectPasscode) {
		didEnterIncorrectPasscode = YES;
	}
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSInteger failedPasscodeAttempts = 0;
	NSString *failedPasscodeAttemptsString = [delegate stringForKey:kFailedPasscodeAttemptsKey];
	if (failedPasscodeAttemptsString) {
		failedPasscodeAttempts = ([failedPasscodeAttemptsString integerValue] + 1);
		[delegate updateKeychainValue:[NSString stringWithFormat:kIntegerFormatSpecifierStr, failedPasscodeAttempts] forIdentifier:kFailedPasscodeAttemptsKey];
	}
	else {
		[delegate createKeychainValue:[NSString stringWithFormat:kIntegerFormatSpecifierStr, 1] forIdentifier:kFailedPasscodeAttemptsKey];
	}
	if (failedPasscodeAttempts > MAXIMUM_LOGIN_ATTEMPTS) {
		NSInteger index = (failedPasscodeAttempts - (MAXIMUM_LOGIN_ATTEMPTS + 1));
		NSString *timeIntervalString = nil;
		if (index < [LOCKOUT_SECONDS_ARRAY count]) {
			timeIntervalString = [LOCKOUT_SECONDS_ARRAY objectAtIndex:index];
		}
		else {
			timeIntervalString = [LOCKOUT_SECONDS_ARRAY lastObject];
		}
		NSString *permittedAccessTimeString = [NSString stringWithFormat:kIntegerFormatSpecifierStr, ([self absoluteTimeInteger] + [timeIntervalString integerValue])];
		NSString *permittedAccessTimeKey = [self permittedAccessTimeKey];
		if ([delegate stringForKey:permittedAccessTimeKey]) {
			[delegate updateKeychainValue:permittedAccessTimeString forIdentifier:permittedAccessTimeKey];
		}
		else {
			[delegate createKeychainValue:permittedAccessTimeString forIdentifier:permittedAccessTimeKey];
		}
		[self enterLockoutMode];
	}
	if (failedPasscodeAttempts >= ERASE_DATA_LOGIN_ATTEMPT_COUNT) {
		if ([[NSUserDefaults standardUserDefaults]boolForKey:kEraseDataKey]) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *dataFilePath = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]applicationPersistentStorePath];
			if ([fileManager fileExistsAtPath:dataFilePath]) {
				[fileManager removeItemAtPath:dataFilePath error:nil];
			}
		}
	}
	[self updateFailedPasscodeAttemptsLabel];
	[[self currentTableView]reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		[currentTextField becomeFirstResponder];
	}
}

- (void)authenticationDidSucceed {
	if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
		Note_SafeAppDelegate *appDelegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
		[appDelegate deleteKeychainValue:[self permittedAccessTimeKey]];
		[appDelegate deleteKeychainValue:kFailedPasscodeAttemptsKey];
		
		// Delegate protocol declaration is not necessary if declaring in LoginNavigationController.h
		id <LoginViewDelegate> delegate = ((LoginNavigationController *)self.navigationController).delegate;
		if (delegate) {
			if ([delegate respondsToSelector:@selector(loginViewDidAuthenticate)]) {
				[delegate loginViewDidAuthenticate];
			}
		}
		[self dismiss];
	}
	else {
		if (didEnterIncorrectPasscode) {
			[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]deleteKeychainValue:kFailedPasscodeAttemptsKey];
			didEnterIncorrectPasscode = NO;
			failedPasscodeAttemptsView.hidden = YES;
		}
		forgotPasscodeView.hidden = YES;
		currentBlock = 1;
		if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
			[self setUpNextButton];
		}
		else if (self.navigationItem.rightBarButtonItem) {
			self.navigationItem.rightBarButtonItem = nil;
		}
		UITextField *currentTextField = [self currentTextField];
		if (![currentTextField isFirstResponder]) {
			[currentTextField becomeFirstResponder];
		}
		[loginScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
	}
}

- (void)setUpNextButton {
	UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(textFieldDidFinishEditing)];
	nextButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = nextButton;
	[nextButton release];
}

- (void)setUpDoneButton {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldDidFinishEditing)];
	doneButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)updateFailedPasscodeAttemptsLabel {
	NSString *failedPasscodeAttemptsString = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kFailedPasscodeAttemptsKey];
	if (failedPasscodeAttemptsString) {
		NSInteger failedPasscodeAttemptsInteger = [failedPasscodeAttemptsString integerValue];
		failedPasscodeAttemptsLabel.text = [NSString stringWithFormat:@"%i Failed Passcode Attempt%@", failedPasscodeAttemptsInteger, (failedPasscodeAttemptsInteger > 1) ? @"s" : kNullStr];
		if (failedPasscodeAttemptsView.hidden) {
			failedPasscodeAttemptsView.hidden = NO;
		}
	}
	else if (!failedPasscodeAttemptsView.hidden) {
		failedPasscodeAttemptsView.hidden = YES;
	}
}

- (void)enterLockoutMode {
	if (!isInLockoutMode) {
		isInLockoutMode = YES;
	}
	didEnterIncorrectPasscode = NO;
	[[self currentTextField]setText:kNullStr];
	forgotPasscodeButton.enabled = NO;
	forgotPasscodeLabel.alpha = 0.5;
	[self updateLockoutModeStatus];
	if (lockoutModeStatusTimer) {
		[lockoutModeStatusTimer invalidate];
		lockoutModeStatusTimer = nil;
	}
	lockoutModeStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLockoutModeStatus) userInfo:nil repeats:YES];
}

- (void)updateLockoutModeStatus {
	if ([self minutesBeforeLogin] <= 0) {
		if (lockoutModeStatusTimer) {
			[lockoutModeStatusTimer invalidate];
			lockoutModeStatusTimer = nil;
		}
		if (!forgotPasscodeButton.enabled) {
			forgotPasscodeButton.enabled = YES;
		}
		if (forgotPasscodeLabel.alpha != 1) {
			forgotPasscodeLabel.alpha = 1;
		}
		if (isInLockoutMode) {
			isInLockoutMode = NO;
		}
	}
	[[self currentTableView]reloadData];
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		[currentTextField becomeFirstResponder];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.x == 320) {
		if (currentBlock != 1) {
			currentBlock = 1;
		}
	}
	else if (scrollView.contentOffset.x == 640) {
		if (currentBlock != 2) {
			currentBlock = 2;
		}
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return !isInLockoutMode;
}

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)dismiss {
	[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	decimalNumberHandler = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode:NSRoundUp
							scale:0
							raiseOnExactness:YES
							raiseOnOverflow:YES
							raiseOnUnderflow:YES
							raiseOnDivideByZero:YES];
	updatedPasscode = [[NSMutableString alloc]init];
	failedPasscodeAttemptsImageView.image = [[UIImage imageNamed:@"Failed_Passcode_Attempts"]stretchableImageWithLeftCapWidth:13 topCapHeight:0];
}

- (void)viewWillAppear:(BOOL)animated {
	LoginNavigationController *loginNavigationController = (LoginNavigationController *)[self navigationController];
	kLoginViewType firstLoginViewType = loginNavigationController.firstSegmentLoginViewType;
	originalFirstSegmentLoginViewType = firstLoginViewType;
	firstSegmentLoginViewType = firstLoginViewType;
	secondSegmentLoginViewType = loginNavigationController.secondSegmentLoginViewType;
	loginType = loginNavigationController.loginType;
	if (loginType != kLoginTypeLogin) {
		if (!self.navigationItem.leftBarButtonItem) {
			UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
			self.navigationItem.leftBarButtonItem = cancelButton;
			[cancelButton release];
		}
	}
	if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
		if (!self.navigationItem.rightBarButtonItem) {
			if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
				[self setUpDoneButton];
			}
			else {
				[self setUpNextButton];
			}
		}
	}
	if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
		loginScrollView.contentSize = CGSizeMake(320, 416);
		[self addFirstSegmentSubview];
	}
	else {
		loginScrollView.contentSize = CGSizeMake(960, 416);
		[self addBothSegmentSubviews];
		if (loginType == kLoginTypeCreatePasscode) {
			[loginScrollView setContentOffset:CGPointMake(320, 0) animated:NO];
			for (int i = 0; i < 4; i++) {
				[[FIRST_IMAGE_VIEW_BLOCK objectAtIndex:i]setImage:[UIImage imageNamed:kBoxFullImageName]];
			}
			currentBlock = 1;
			UITextField *currentTextField = [self currentTextField];
			if (![currentTextField isFirstResponder]) {
				[currentTextField becomeFirstResponder];
			}
		}
	}
	
	if (loginType != kLoginTypeCreatePasscode) {
		forgotPasscodeView.hidden = ![[NSUserDefaults standardUserDefaults]boolForKey:kForgotPasscodeOptionEnabledKey];
	}
	[self updateFailedPasscodeAttemptsLabel];
	
	[self reloadTableViews];
	if ([[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kFailedPasscodeAttemptsKey]integerValue] > MAXIMUM_LOGIN_ATTEMPTS) {
		[self enterLockoutMode];
	}
	UITextField *currentTextField = [self currentTextField];
	if (![currentTextField isFirstResponder]) {
		[currentTextField becomeFirstResponder];
	}
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	if (lockoutModeStatusTimer) {
		[lockoutModeStatusTimer invalidate];
		lockoutModeStatusTimer = nil;
	}
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/

- (void)addFirstSegmentSubview {
	[loginScrollView setContentSize:CGSizeMake(320, 416)];
	if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
		fourDigitOneSegmentView.frame = CGRectMake(0, 0, 320, 416);
		[loginScrollView insertSubview:fourDigitOneSegmentView atIndex:0];
	}
	else if (firstSegmentLoginViewType == kLoginViewTypeTextField) {
		textFieldOneSegmentView.frame = CGRectMake(0, 0, 320, 416);
		[loginScrollView insertSubview:textFieldOneSegmentView atIndex:0];
	}
}

- (void)addBothSegmentSubviews {
	[self addFirstSegmentSubview];
	CGRect frame = CGRectMake(320, 0, 640, 416);
	if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		fourDigitTwoSegmentView.frame = frame;
		[loginScrollView insertSubview:fourDigitTwoSegmentView atIndex:0];
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
		textFieldTwoSegmentView.frame = frame;
		[loginScrollView insertSubview:textFieldTwoSegmentView atIndex:0];
	}
}

#pragma mark -

- (UITableView *)currentTableView {
	return [self tableViewForBlock:currentBlock];
}

- (UITextField *)currentTextField {
	return [self textFieldForBlock:currentBlock];
}

- (UITableView *)tableViewForBlock:(NSInteger)block {
	if (block == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			return fourDigitOneSegmentTableView;
		}
		else {
			return textFieldOneSegmentTableView;
		}
	}
	else {
		if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
			if (block == 1) {
				return fourDigitTwoSegmentTableView1;
			}
			else {
				return fourDigitTwoSegmentTableView2;
			}
		}
		else {
			if (block == 1) {
				return textFieldTwoSegmentTableView1;
			}
			else {
				return textFieldTwoSegmentTableView2;
			}
		}
	}
	return nil;
}

- (UITextField *)textFieldForBlock:(NSInteger)block {
	if (block == 0) {
		if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
			return fourDigitOneSegmentTextField;
		}
		else {
			return [(TextFieldCell *)[textFieldOneSegmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
	}
	else if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
		if (block == 1) {
			return fourDigitTwoSegmentTextField1;
		}
		else {
			return fourDigitTwoSegmentTextField2;
		}
	}
	else {
		if (block == 1) {
			return [(TextFieldCell *)[textFieldTwoSegmentTableView1 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
		else {
			return [(TextFieldCell *)[textFieldTwoSegmentTableView2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField];
		}
	}
}

- (void)reloadTableViews {
	for (int i = 0; i < 3; i++) {
		[[self tableViewForBlock:i]reloadData];
	}
}

- (NSString *)permittedAccessTimeKey {
	if (loginType == kLoginTypeLogin) {
		return kPermittedLoginAccessTimeKey;
	}
	else if ((loginType == kLoginTypeAuthenticate) || (loginType == kLoginTypeChangePasscode)) {
		return kPermittedAuthenticationAccessTimeKey;
	}
	return nil;
}

- (NSInteger)minutesBeforeLogin {
	if (loginType != kLoginTypeCreatePasscode) {
		NSString *permittedAccessTimeString = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:[self permittedAccessTimeKey]];
		if (permittedAccessTimeString) {
			NSInteger secondsBeforeLogin = ([permittedAccessTimeString integerValue] - [self absoluteTimeInteger]);
			if (secondsBeforeLogin > 0) {
				return [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, (secondsBeforeLogin / 60.0)]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler]integerValue];
			}
		}
	}
	return 0;
}

- (NSInteger)absoluteTimeInteger {
	return [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:kFloatFormatSpecifierStr, CFAbsoluteTimeGetCurrent()]]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler]integerValue];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		if (tableView.tag == 0) {
			if ((firstSegmentLoginViewType == kLoginViewTypeTextField) || ((firstSegmentLoginViewType == kLoginViewTypeFourDigit) && (secondSegmentLoginViewType == kLoginViewTypeTextField) && (passcodesDidNotMatch))) {
				return 1;
			}
		}
		else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
			return 1;
		}
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		if (tableView.tag == 0) {
			NSString *prefix = kNullStr;
			NSString *suffix = kNullStr;
			if (firstSegmentLoginViewType == kLoginViewTypeFourDigit) {
				prefix = @"\n";
			}
			else {
				suffix = @"\n ";
			}
			if (([[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kFailedPasscodeAttemptsKey]integerValue] > MAXIMUM_LOGIN_ATTEMPTS) && ([self minutesBeforeLogin] > 0)) {
				NSMutableString *tryAgainLaterString = nil;
				
				if (loginType == kLoginTypeLogin) {
					tryAgainLaterString = [NSMutableString stringWithString:@"                App is disabled,\n"];
				}
				else {
					tryAgainLaterString = [NSMutableString stringWithString:prefix];
				}
				
				if ([self minutesBeforeLogin] == 1) {
					[tryAgainLaterString appendString:@"           Try again in 1 minute"];
				}
				else if ([self minutesBeforeLogin] == 60) {
					[tryAgainLaterString appendString:@"             Try again in 1 hour"];
				}
				else {
					[tryAgainLaterString appendFormat:@"          Try again in %i minutes", [self minutesBeforeLogin]];
				}
				
				if (loginType == kLoginTypeLogin) {
					return tryAgainLaterString;
				}
				else {
					return [tryAgainLaterString stringByAppendingString:suffix];
				}
			}
			else {
				if (didEnterIncorrectPasscode) {
					return @"             Incorrect passcode\n                     Try again";
				}
				else {
					if (loginType == kLoginTypeLogin) {
						return [[prefix stringByAppendingString:@"                Enter passcode"]stringByAppendingString:suffix];
					}
					else if (loginType == kLoginTypeAuthenticate) {
						return [[prefix stringByAppendingString:@"            Enter your passcode"]stringByAppendingString:suffix];
					}
					else if (loginType == kLoginTypeCreatePasscode) {
						return [[prefix stringByAppendingString:@"         Re-enter your passcode"]stringByAppendingString:suffix];
					}
					else {
						if (passcodesDidNotMatch) {
							return [[prefix stringByAppendingString:@"     Re-enter your new passcode"]stringByAppendingString:suffix];
						}
						else {
							return [[prefix stringByAppendingString:@"            Enter your passcode"]stringByAppendingString:suffix];
						}
					}
				}
			}
		}
		else {
			NSString *prefix = kNullStr;
			NSString *suffix = kNullStr;
			if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
				prefix = @"\n";
			}
			else {
				suffix = @"\n ";
			}
			if (tableView.tag == 1) {
				if (loginType == kLoginTypeCreatePasscode) {
					return [[prefix stringByAppendingString:@"              Enter a passcode"]stringByAppendingString:suffix];
				}
				else {
					return [[prefix stringByAppendingString:@"       Enter your new passcode"]stringByAppendingString:suffix];
				}
			}
			else {
				if (loginType == kLoginTypeCreatePasscode) {
					return [[prefix stringByAppendingString:@"         Re-enter your passcode"]stringByAppendingString:suffix];
				}
				else {
					return [[prefix stringByAppendingString:@"     Re-enter your new passcode"]stringByAppendingString:suffix];
				}
			}
		}
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		if (tableView.tag == 1) {
			if ((passcodeIsNotDifferent) || (passcodesDidNotMatch)) {
				NSString *prefix = kNullStr;
				if (secondSegmentLoginViewType == kLoginViewTypeFourDigit) {
					prefix = @"\n\n";
				}
				if (passcodeIsNotDifferent) {
					return [prefix stringByAppendingString:@"Please enter a different passcode.\nYou cannot re-use the same passcode."];
				}
				else {
					return [prefix stringByAppendingString:@"The two passcodes did not match. Please try again."];
				}
			}
			else if (secondSegmentLoginViewType == kLoginViewTypeTextField) {
				return @"If the passcode you enter is numeric, a numeric keypad will be shown instead of a full keyboard when you log in.";
			}
		}
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    // Configure the cell...
	
	cell.textField.delegate = self;
	cell.textField.text = kNullStr;
	[cell.textField setSecureTextEntry:YES];
	[cell.textField addTarget:self action:@selector(textFieldEditingChangedAction) forControlEvents:UIControlEventEditingChanged];
	if (tableView.tag == 0) {
		if ([[NSUserDefaults standardUserDefaults]boolForKey:kNumericPasscodeKey]) {
			cell.textField.keyboardType = UIKeyboardTypeNumberPad;
		}
		if ((loginType == kLoginTypeLogin) || (loginType == kLoginTypeAuthenticate)) {
			cell.textField.returnKeyType = UIReturnKeyDone;
		}
		else {
			cell.textField.returnKeyType = UIReturnKeyNext;
		}
	}
	else if (tableView.tag == 1) {
		cell.textField.returnKeyType = UIReturnKeyNext;
	}
	else {
		cell.textField.returnKeyType = UIReturnKeyDone;
	}
	cell.textField.enablesReturnKeyAutomatically = YES;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.loginScrollView = nil;
	self.forgotPasscodeView = nil;
	self.forgotPasscodeButton = nil;
	self.forgotPasscodeLabel = nil;
	self.failedPasscodeAttemptsView = nil;
	self.failedPasscodeAttemptsLabel = nil;
	self.failedPasscodeAttemptsImageView = nil;
	self.decimalNumberHandler = nil;
	
	self.fourDigitOneSegmentView = nil;
	self.fourDigitTwoSegmentView = nil;
	self.textFieldOneSegmentView = nil;
	self.textFieldTwoSegmentView = nil;
	
	self.fourDigitOneSegmentTextField = nil;
	self.fourDigitTwoSegmentTextField1 = nil;
	self.fourDigitTwoSegmentTextField2 = nil;
	
	self.imageView1 = nil;
	self.imageView2 = nil;
	self.imageView3 = nil;
	self.imageView4 = nil;
	self.imageView5 = nil;
	self.imageView6 = nil;
	self.imageView7 = nil;
	self.imageView8 = nil;
	self.imageView9 = nil;
	self.imageView10 = nil;
	self.imageView11 = nil;
	self.imageView12 = nil;
	
	self.updatedPasscode = nil;
}

- (void)dealloc {
	[loginScrollView release];
	[forgotPasscodeView release];
	[forgotPasscodeButton release];
	[forgotPasscodeLabel release];
	[failedPasscodeAttemptsView release];
	[failedPasscodeAttemptsLabel release];
	[failedPasscodeAttemptsImageView release];
	[decimalNumberHandler release];
	
	[fourDigitOneSegmentView release];
	[fourDigitTwoSegmentView release];
	[textFieldOneSegmentView release];
	[textFieldTwoSegmentView release];
	
	[fourDigitOneSegmentTextField release];
	[fourDigitTwoSegmentTextField1 release];
	[fourDigitTwoSegmentTextField2 release];
	
	[imageView1 release];
	[imageView2 release];
	[imageView3 release];
	[imageView4 release];
	[imageView5 release];
	[imageView6 release];
	[imageView7 release];
	[imageView8 release];
	[imageView9 release];
	[imageView10 release];
	[imageView11 release];
	[imageView12 release];
	
	[updatedPasscode release];
    [super dealloc];
}

@end


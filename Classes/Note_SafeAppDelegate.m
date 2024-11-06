//
//  Note_SafeAppDelegate.m
//  Note Safe
//
//  Created by Harrison White on 7/15/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "Note_SafeAppDelegate.h"
#import "ContainerViewController.h"
#import "NotesViewController.h"
#import "NotesDetailViewController.h"
#import "SettingsViewController.h"
#import "ApplicationStrings.h"
#import "LoginView.h"
#import "SA_OAuthTwitterEngine.h"
#import "NetworkStatusChangeNotifier.h"

#define ALPHABETICAL_ORDER_SEGMENT_INDEX			0
#define RECENT_ORDER_SEGMENT_INDEX					1
#define CUSTOM_ORDER_SEGMENT_INDEX					2
#define STARRED_ORDER_SEGMENT_INDEX					3

#define NOTE_TITLE_SCOPE_SEGMENT_INDEX				0
#define ENTIRE_NOTE_SCOPE_SEGMENT_INDEX				1

#define PASSCODE_REQUIREMENT_DELAY_SECONDS_ARRAY	[NSArray arrayWithObjects:@"60", @"300", @"900", @"3600", @"14400", nil]

#define REQUEST_TO_RATE_LAUNCH_COUNT				5

// getgid()
// #import <unistd.h>

// WARNING: Simulator Test Mode only tests for items that are applicable to the iPhone
// Simulator. It should NOT be used as a replacement for a device test in case certain
// functionality is changed.
// #define SIMULATOR_TEST_MODE							NO

#define kOAuthConsumerKey							@"MNRfCgE72sRpQ8eVqwj8dw"
#define kOAuthConsumerSecret						@"cZY8WtaIiPU9AAZnmM8Q3UyH5I6G1aXoT1VJzQjNM"

static NSString *kFacebookAppIDStr					= @"181011791986071";
static NSString *kTwitterAuthenticationDataKey		= @"Twitter Authentication Data";

static NSString *kCannotSendMailOpenURLStr			= @"mailto:";

static NSString *kWelcomeMessageShownKey			= @"Welcome Message Shown";
static NSString *kRequestToRateKey					= @"Request to Rate";
static NSString *kRemindToRateKey					= @"Remind to Rate";
static NSString *kRatingLaunchCountKey				= @"Rating Launch Count";

static NSString *kLastAccessedPrefixStr				= @"Last Accessed: ";
static NSString *kNewlineStr						= @"\n";
static NSString *kSpaceStr							= @" ";
static NSString *kNullStr							= @"";
static NSString *kWelcomeHeaderStr					= @"First Launch • Welcome to Note Safe!";

static NSString *kAppIconBadgeKey					= @"App Icon Badge";
static NSString *kDefaultsSetKey					= @"Defaults Set";
static NSString *kLastAccessedDateKey				= @"Last Accessed Date";
static NSString *kLastAccessedTimeKey				= @"Last Accessed Time";
static NSString *kNotesSectionBadgeKey				= @"Notes Section Badge";
static NSString *kPasscodeKey						= @"Passcode";
static NSString *kSecureNoteImportingEnabledKey		= @"Secure Note Importing Enabled";
static NSString *kSimplePasscodeKey					= @"Simple Passcode";

static NSString *kPasscodeRequirementDelayIndexKey	= @"Passcode Requirement Delay Index";

static NSString *kBodyKey							= @"body";
static NSString *kCustomIndexKey					= @"customIndex";
static NSString *kSectionTitleKey					= @"sectionTitle";
static NSString *kLastModifiedKey					= @"lastModified";
static NSString *kStarredKey						= @"starred";
static NSString *kTitleKey							= @"title";

// WARNING: DO NOT CHANGE THIS STRING
// It should be identical to the object in the array for the keychain-access-groups key in the Entitlements.plist file.
static NSString *kKeychainServiceName				= @"BAVT58695N.NoteSafeAppFamily";

@interface NSManagedObject (Note)

- (NSString *)sectionTitle;

@end

@implementation NSManagedObject (Note)

- (NSString *)sectionTitle {
	[self willAccessValueForKey:kTitleKey];
	NSString *uppercaseTitle = [[self valueForKey:kTitleKey]uppercaseString];
	NSString *sectionTitle = [uppercaseTitle substringWithRange:[uppercaseTitle rangeOfComposedCharacterSequenceAtIndex:0]];
	if ([sectionTitle rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet]invertedSet]].length > 0) {
		sectionTitle = @"#";
	}
	[self didAccessValueForKey:kTitleKey];
	return sectionTitle;
}

@end

@implementation Note_SafeAppDelegate

@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;

@synthesize window;
@synthesize tabBarController;
@synthesize noteCountLabel;
@synthesize lastAccessedDateLabel;
@synthesize landscapeNoteCountLabel;
@synthesize notesViewController;
@synthesize rootViewController;

@synthesize pendingNoteImport;
@synthesize showAlertCalled;

@synthesize networkStatusChangeNotifier;

@synthesize facebook;
@synthesize twitterEngine;
@synthesize pendingTwitterPostRequest;
@synthesize pendingTweet;

@synthesize pendingEmailSubject;
@synthesize pendingEmailBody;
@synthesize pendingEmailBodyIsHTML;

// Notes

@synthesize fetchedResultsController;

@synthesize theTableView;
@synthesize theToolbar;
@synthesize sortOrderSegmentedControl;
@synthesize searchBarScrollDelayTimer;
@synthesize tableViewEditDelayTimer;
@synthesize pendingDeleteIndexPath;
@synthesize willBeginEditing;
@synthesize searching;
@synthesize isReordering;

#pragma mark -
#pragma mark Application lifecycle

- (void)updateLastAccessedDate {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults objectForKey:kLastAccessedDateKey]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		lastAccessedDateLabel.text = [kLastAccessedPrefixStr stringByAppendingString:[dateFormatter stringFromDate:[defaults objectForKey:kLastAccessedDateKey]]];
		[dateFormatter release];
	}
	else {
		lastAccessedDateLabel.text = kWelcomeHeaderStr;
	}
}

- (void)logLastAccessedDate {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastAccessedDateKey];
	[defaults synchronize];
	NSString *lastAccessedTime = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
	if ([self stringForKey:kLastAccessedTimeKey]) {
		[self updateKeychainValue:lastAccessedTime forIdentifier:kLastAccessedTimeKey];
	}
	else {
		[self createKeychainValue:lastAccessedTime forIdentifier:kLastAccessedTimeKey];
	}
}

- (void)configureStatusBar {
	[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Override point for customization after application launch.
	
	/*
#warning Implementation of the anti-piracy code also requires the anti-piracy "App Store Page Restriced" alert ((tag == 1) && (tag == 2)) to be implemented.
	// SignerIdentity
	NSMutableString *defaults = [[NSMutableString alloc]init];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(0, 2)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(34, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(17, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(167, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(63, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(1, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	[defaults appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(14, 1)]];
	// _CodeSignature
	NSMutableString *path1 = [[NSMutableString alloc]init];
	[path1 appendString:@"_"];
	[path1 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]uppercaseString]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(63, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(0, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(1, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(34, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(40, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(16, 2)]];
	[path1 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	// CodeResources
	NSMutableString *path2 = [[NSMutableString alloc]init];
	[path2 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]uppercaseString]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(63, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path2 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(17, 1)]uppercaseString]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 3)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path2 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	// ResourceRules.plist
	NSMutableString *path3 = [[NSMutableString alloc]init];
	[path3 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(17, 1)]uppercaseString]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 3)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 2)]];
	[path3 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(17, 1)]uppercaseString]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(16, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(43, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(90, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(41, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(43, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(1, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	[path3 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	// Info.plist
	NSMutableString *path4 = [[NSMutableString alloc]init];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(167, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(19, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(90, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(41, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(43, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(1, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(9, 1)]];
	[path4 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	// PkgInfo
	NSMutableString *path5 = [[NSMutableString alloc]init];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(92, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(69, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(34, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(167, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(19, 1)]];
	[path5 appendString:[WELCOME_MESSAGE substringWithRange:NSMakeRange(15, 1)]];
	// CFBundleExecutable
	NSMutableString *path6 = [[NSMutableString alloc]init];
	[path6 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]uppercaseString]];
	[path6 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(19, 1)]uppercaseString]];
	[path6 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(86, 1)]uppercaseString]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(16, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(2, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(63, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(43, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path6 appendString:[[WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]uppercaseString]];
	[path6 appendString:												   @"x"];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(3, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(16, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(6, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(40, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(86, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(43, 1)]];
	[path6 appendString: [WELCOME_MESSAGE substringWithRange:NSMakeRange(4, 1)]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *bundlePath = [[NSBundle mainBundle]bundlePath];
	if (
		(!didSaveDefaults) ||
		(!didReadDefaults) ||
		(((SIMULATOR_TEST_MODE) || (!TARGET_IPHONE_SIMULATOR)) && (getgid() <= 10)) ||
		([[[NSBundle mainBundle]infoDictionary]objectForKey:defaults] != nil) ||
		(![defaults isEqualToString:@"SignerIdentity"]) ||
		((!TARGET_IPHONE_SIMULATOR) && (![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:path1]])) ||
		((!TARGET_IPHONE_SIMULATOR) && (![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:path2]])) ||
		((!TARGET_IPHONE_SIMULATOR) && (![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:path3]])) ||
		(![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:path4]]) ||
		(![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:path5]]) ||
		(![fileManager fileExistsAtPath:[bundlePath stringByAppendingPathComponent:[[[NSBundle mainBundle]infoDictionary]objectForKey:path6]]]) ||
		(![path1 isEqualToString:@"_CodeSignature"]) ||
		(![path2 isEqualToString:@"CodeResources"]) ||
		(![path3 isEqualToString:@"ResourceRules.plist"]) ||
		(![path4 isEqualToString:@"Info.plist"]) ||
		(![path5 isEqualToString:@"PkgInfo"]) ||
		(![path6 isEqualToString:@"CFBundleExecutable"]) ||
		(![[[NSBundle mainBundle]infoDictionary]objectForKey:path6]) ||
		(fabs([[[fileManager attributesOfItemAtPath:path4 error:nil]fileModificationDate]timeIntervalSinceReferenceDate] -
			  [[[fileManager attributesOfItemAtPath:path5 error:nil]fileModificationDate]timeIntervalSinceReferenceDate])
		 > MAX_ALLOWED_TIME_DIFFERENCE_IN_SECONDS) ||
		(fabs([[[fileManager attributesOfItemAtPath:path6 error:nil]fileModificationDate]timeIntervalSinceReferenceDate] -
			  [[[fileManager attributesOfItemAtPath:path5 error:nil]fileModificationDate]timeIntervalSinceReferenceDate])
		 > MAX_ALLOWED_TIME_DIFFERENCE_IN_SECONDS)
		) {
		UIAlertView *piratedApplicationAlert = [[UIAlertView alloc]
												initWithTitle:@"Pirated Application"
												message:@"You are running a pirated version of this application, and are therefore guilty of software piracy. Software piracy is a federal crime that is punishable by a fine of up to $100,000 for each pirated work, and may also result in up to 5 years jail time. In addition, reimbursement costs can be millions of dollars.\nWe may or may not choose to report you. Please purchase the official version of this application now."
												delegate:self
												cancelButtonTitle:nil
												otherButtonTitles:@"Purchase", nil];
		piratedApplicationAlert.tag = 0;
		[piratedApplicationAlert show];
		[piratedApplicationAlert release];
	}
	else {
	*/
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (![defaults boolForKey:kDefaultsSetKey]) {
			[defaults setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Defaults" ofType:@"plist"]]];
		}
		
		[self configureStatusBar];
	
		networkStatusChangeNotifier = [[NetworkStatusChangeNotifier defaultNotifier]retain];
		facebook = [[Facebook alloc]initWithAppId:kFacebookAppIDStr];
		
		twitterEngine = [[SA_OAuthTwitterEngine alloc]initOAuthWithDelegate:self];
		twitterEngine.consumerKey = kOAuthConsumerKey;
		twitterEngine.consumerSecret = kOAuthConsumerSecret;
		
		application.applicationSupportsShakeToEdit = YES;
		
		notesViewController = [[[tabBarController.viewControllers objectAtIndex:0]viewControllers]objectAtIndex:0];
		
		rootViewController = [[ContainerViewController alloc]init];
		rootViewController.parent = tabBarController;
		[window addSubview:rootViewController.view];
		tabBarController.view.frame = CGRectMake(0, 0, 320, 460);
		
		/*
		NSArray *viewControllers = tabBarController.viewControllers;
		
		UINavigationBar *notesNavigationBar = [[viewControllers objectAtIndex:0]navigationBar];
		[notesNavigationBar setBackgroundImage:[UIImage imageNamed:@"Navigation_Bar-Notes-Background"] forBarMetrics:UIBarMetricsDefault];
		notesNavigationBar.tintColor = [UIColor colorWithRed:(216.0 / 255.0) green:(170.0 / 255.0) blue:(120.0 / 255.0) alpha:1];
		
		UINavigationBar *settingsNavigationBar = [[viewControllers objectAtIndex:1]navigationBar];
		[settingsNavigationBar setBackgroundImage:[UIImage imageNamed:@"Navigation_Bar-Settings-Background"] forBarMetrics:UIBarMetricsDefault];
		settingsNavigationBar.tintColor = [UIColor darkGrayColor];
		*/
		
		[self updateLastAccessedDate];
	
		[rootViewController.view addSubview:tabBarController.view];
	/* }
	[defaults release];
	[path1 release];
	[path2 release];
	[path3 release];
	[path4 release];
	[path5 release];
	[path6 release];
	*/
	
	// Substitute implementation for code originally called through -applicationDidBecomeActive and related methods
	[self configureStatusBar];
	// [self updateLastAccessedDate];
	if ([self stringForKey:kPasscodeKey]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSInteger passcodeRequirementDelayIndex = [defaults integerForKey:kPasscodeRequirementDelayIndexKey];
		if ((passcodeRequirementDelayIndex == 0) || ((CFAbsoluteTimeGetCurrent() - [[self stringForKey:kLastAccessedTimeKey]floatValue]) >= [[PASSCODE_REQUIREMENT_DELAY_SECONDS_ARRAY objectAtIndex:(passcodeRequirementDelayIndex - 1)]integerValue])) {
			LoginView *loginView = [[LoginView alloc]initWithNibName:@"LoginView" bundle:nil];
			loginView.loginType = kLoginTypeLogin;
			if ([defaults boolForKey:kSimplePasscodeKey]) {
				loginView.firstSegmentLoginViewType = kLoginViewTypeFourDigit;
			}
			else {
				loginView.firstSegmentLoginViewType = kLoginViewTypeTextField;
			}
			[rootViewController presentModalViewController:loginView animated:NO];
			[loginView release];
		}
	}
	else {
		[self showAlertIfApplicable];
	}
	
	// End substitute implementation
	
	[self logLastAccessedDate];
	
	// [self handleFileAtURLIfApplicable:[NSURL URLWithString:[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey]]];
	
	[window makeKeyAndVisible];
	
	return YES;
}

- (void)showAlertIfApplicable {
	if (!showAlertCalled) {
		showAlertCalled = YES;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:kWelcomeMessageShownKey]) {
			if ([defaults boolForKey:kRequestToRateKey]) {
				BOOL showAlert = NO;
				if ([defaults boolForKey:kRemindToRateKey]) {
					showAlert = YES;
				}
				else {
					NSInteger ratingLaunchCount = [defaults integerForKey:kRatingLaunchCountKey];
					ratingLaunchCount += 1;
					[defaults setInteger:ratingLaunchCount forKey:kRatingLaunchCountKey];
					[defaults synchronize];
					if (ratingLaunchCount >= REQUEST_TO_RATE_LAUNCH_COUNT) {
						showAlert = YES;
					}
				}
				if (showAlert) {
					UIAlertView *requestToRateAlert = [[UIAlertView alloc]
													   initWithTitle:@"If you like Note Safe, please rate it!"
													   message:nil
													   delegate:self
													   cancelButtonTitle:@"No Thanks"
													   otherButtonTitles:@"Rate Now", @"Remind Me Later", nil];
					requestToRateAlert.tag = 5;
					[requestToRateAlert show];
					[requestToRateAlert release];
				}
			}
		}
		else {
			UIAlertView *welcomeAlert = [[UIAlertView alloc]
										 initWithTitle:@"Welcome to Note Safe!"
										 message:WELCOME_MESSAGE
										 delegate:self
										 cancelButtonTitle:@"Dismiss"
										 otherButtonTitles:@"Passcode", nil];
			welcomeAlert.tag = 2;
			[welcomeAlert show];
			[welcomeAlert release];
		}
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[facebook handleOpenURL:url];
	return (url != nil);
}

- (void)fbDidLogout {
	UIAlertView *signOutSuccessfulAlert = [[UIAlertView alloc]
										   initWithTitle:@"Signed Out"
										   message:@"You are signed out of Facebook."
										   delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[signOutSuccessfulAlert show];
	[signOutSuccessfulAlert release];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if (![self handleFileAtURLIfApplicable:url]) {
		if (url) {
			NSRange range = [[url absoluteString]rangeOfString:@":"];
			
			NSStringEncoding contentStringEncoding = NSUTF8StringEncoding;
			[NSString stringWithContentsOfURL:url usedEncoding:&contentStringEncoding error:nil];
			
			[self importNote:[[[url absoluteString]substringFromIndex:(range.location + 1)]stringByReplacingPercentEscapesUsingEncoding:contentStringEncoding]];
			return YES;
		}
		return NO;
	}
	return YES;
}

- (BOOL)handleFileAtURLIfApplicable:(NSURL *)url {
	if (url) {
		if ([url isFileURL]) {
			NSError *error = nil;
			
			NSStringEncoding contentStringEncoding = NSUTF8StringEncoding;
			[NSString stringWithContentsOfURL:url usedEncoding:&contentStringEncoding error:&error];
			NSString *contentString = nil;
			if (!error) {
				contentString = [NSString stringWithContentsOfURL:url encoding:contentStringEncoding error:&error];
			}
			if (error) {
				UIAlertView *improperFormatAlert = [[UIAlertView alloc]
													initWithTitle:@"Improper Format"
													message:@"Note Safe cannot import this note because it is not written in plain text. For more information about encoding text files, please visit the Settings section and select \"USB Import Help\"."
													delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles:nil];
				[improperFormatAlert show];
				[improperFormatAlert release];
				return YES;
			}
			else if ([contentString length] > 0) {
				[self importNote:contentString];
				[self performSelectorInBackground:@selector(_deleteFiles) withObject:nil];
				return YES;
			}
		}
	}
	return NO;
}

- (void)_deleteFiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	for (NSString *file in [fileManager contentsOfDirectoryAtPath:applicationDocumentsDirectory error:nil]) {
		[fileManager removeItemAtPath:[applicationDocumentsDirectory stringByAppendingPathComponent:file] error:nil];
	}
	
	[pool release];
}

- (void)importNote:(NSString *)note {
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kSecureNoteImportingEnabledKey]) {
		pendingNoteImport = [[NSString alloc]initWithString:note];
		tabBarController.selectedIndex = 0;
		UIAlertView *confirmImportAlert = [[UIAlertView alloc]
										   initWithTitle:@"Import Note"
										   message:[@"Are you sure you want to import the following note?\n\n" stringByAppendingString:note]
										   delegate:self
										   cancelButtonTitle:@"Cancel"
										   otherButtonTitles:@"Import", nil];
		confirmImportAlert.tag = 3;
		[confirmImportAlert show];
		[confirmImportAlert release];
	}
	else {
		UIAlertView *secureNoteImportingDisabledAlert = [[UIAlertView alloc]
														 initWithTitle:@"Secure Note Importing Disabled"
														 message:@"You cannot import this note\nbecause the Secure Note\nImporting feature is disabled.\nYou can enable this feature in the Settings section of the app."
														 delegate:nil
														 cancelButtonTitle:@"OK"
														 otherButtonTitles:nil];
		[secureNoteImportingDisabledAlert show];
		[secureNoteImportingDisabledAlert release];
	}
}

- (NSManagedObject *)createNewNoteWithProperties:(NSDictionary *)properties {
	// Create a new instance of the entity managed by the fetched results controller.
	NSEntityDescription *entity = [[[self fetchedResultsController]fetchRequest]entity];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:[[self fetchedResultsController]managedObjectContext]];
	
	// If appropriate, configure the new managed object.
	[newManagedObject setValuesForKeysWithDictionary:properties];
	
	[self saveContext];
	
	return newManagedObject;
}

- (void)saveContext {
	// Save the context.
	NSError *error = nil;
	if (![[[self fetchedResultsController]managedObjectContext]save:&error]) {
		[self abortWithError:error];
	}
}

- (NSString *)titleForNoteWithBody:(NSString *)body {
	NSMutableString *revisedText = [NSMutableString stringWithString:body];
	while (([[revisedText substringToIndex:1]isEqualToString:kSpaceStr]) || ([[revisedText substringToIndex:1]isEqualToString:kNewlineStr])) {
		if ([revisedText length] > 1) {
			[revisedText setString:[revisedText substringFromIndex:1]];
		}
		else {
			return revisedText;
			break;
		}
	}
	if ([[revisedText componentsSeparatedByString:kNewlineStr]count] > 1) {
		return [[revisedText componentsSeparatedByString:kNewlineStr]objectAtIndex:0];
	}
	else {
		return revisedText;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	/*
	if (alertView.tag == 0) {
		if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:APPLICATION_URL]]) {
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPLICATION_URL]];
		}
		else {
			UIAlertView *cannotLaunchAppStoreAlert = [[UIAlertView alloc]
													  initWithTitle:@"Cannot Launch App Store"
													  message:@"Your request could not be completed due to the restrictions on your device. Please enable the App Store application and try again.\n(Launch the Settings app, select General > Restrictions, and turn on the \"Installing Apps\" switch.)"
													  delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			cannotLaunchAppStoreAlert.tag = 1;
			[cannotLaunchAppStoreAlert show];
			[cannotLaunchAppStoreAlert release];
		}
	}
	else if (alertView.tag == 1) {
		exit(0);
	}
	else */ if (alertView.tag == 2) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:kWelcomeMessageShownKey];
		[defaults synchronize];
		if (buttonIndex == 1) {
			[self openPasscodeSettings];
		}
	}
	else if (alertView.tag == 3) {
		if (buttonIndex == 1) {
			[self createNewNoteWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
											   [self titleForNoteWithBody:pendingNoteImport], kTitleKey,
											   pendingNoteImport, kBodyKey,
											   [NSNumber numberWithInteger:[self totalNumberOfNotes:NO]], kCustomIndexKey,
											   [NSDate date], kLastModifiedKey,
											   [NSNumber numberWithBool:NO], kStarredKey,
											   nil]];
		}
		[pendingNoteImport release];
	}
	else if (alertView.tag == 4) {
		if (buttonIndex == 1) {
			[self openPasscodeSettings];
		}
	}
	else if (alertView.tag == 5) {
		if (buttonIndex == 0) {
            [self removeRatingData];
        }
        else if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:kAppStoreURLStr];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [self removeRatingData];
                [[UIApplication sharedApplication]openURL:url];
            }
            else {
                [self displayCannotLaunchAppStoreAlert];
            }
        }
        else if (buttonIndex == 2) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:0 forKey:kRatingLaunchCountKey];
            [defaults setBool:YES forKey:kRemindToRateKey];
            [defaults synchronize];
        }
	}
	else if (buttonIndex != alertView.cancelButtonIndex) {
		if (alertView.tag == 6) {
			NSURL *request = [NSURL URLWithString:kCannotSendMailOpenURLStr];
			if ([[UIApplication sharedApplication]canOpenURL:request]) {
				[[UIApplication sharedApplication]openURL:request];
			}
			else {
				UIAlertView *cannotLaunchMailAlert = [[UIAlertView alloc]
													  initWithTitle:@"Cannot Launch Mail"
													  message:@"Your request could not be completed due to the restrictions on your device. Please allow changes to accounts in the Mail application (launch the Settings app and select General > Restrictions > Accounts > Allow Changes) and try again."
													  delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[cannotLaunchMailAlert show];
				[cannotLaunchMailAlert release];
			}
		}
		else if (alertView.tag == 7) {
			[self sendEmail];
		}
	}
}

- (void)removeRatingData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:0 forKey:kRatingLaunchCountKey];
	[defaults setBool:NO forKey:kRemindToRateKey];
	[defaults setBool:NO forKey:kRequestToRateKey];
	[defaults synchronize];
}

- (void)openPasscodeSettings {
	[tabBarController setSelectedIndex:1];
	[(SettingsViewController *)[[[tabBarController.viewControllers objectAtIndex:1]viewControllers]objectAtIndex:0]pushPasscodeSettingsViewControllerAnimated:NO];
}

- (void)showPasscodeResetAlert {
	UIAlertView *passcodeResetAlert = [[UIAlertView alloc]
									   initWithTitle:@"Passcode Reset"
									   message:@"You have answered your security question correctly and your passcode has been reset. For your security, we recommend creating a new passcode as soon as possible. To do this now, please press the Passcode button below."
									   delegate:self
									   cancelButtonTitle:@"Dismiss"
									   otherButtonTitles:@"Passcode", nil];
	passcodeResetAlert.tag = 4;
	[passcodeResetAlert show];
	[passcodeResetAlert release];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	
	[self logLastAccessedDate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	 */
	
	/*
	[self logLastAccessedDate];
	if (tabBarController.selectedIndex == 1) {
		UINavigationController *navigationController = [tabBarController.viewControllers objectAtIndex:1];
		if ([navigationController.viewControllers count] > 1) {
			[navigationController popToRootViewControllerAnimated:NO];
		}
	}
	*/
	
	[self logLastAccessedDate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	 */
	
	
	[self logLastAccessedDate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
	
	[self logLastAccessedDate];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	 Called when the application is about to terminate.
	 See also applicationDidEnterBackground:.
	 */
	
	[self logLastAccessedDate];
	
	NSError *error = nil;
	if (managedObjectContext != nil) {
		if (([managedObjectContext hasChanges]) && (![managedObjectContext save:&error])) {
			[self abortWithError:error];
		} 
	}
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

#pragma mark -
#pragma mark Notes

- (IBAction)sortOrderSegmentedControlValueChanged {
	[self setUpFetchedResultsControllerWithCache:YES];
	[self performFetch];
	[self updateElements:NO];
}

- (void)editButtonPressed {
	willBeginEditing = YES;
	notesViewController.navigationItem.rightBarButtonItem = nil;
	[[self currentTableView]reloadData];
	if (tableViewEditDelayTimer) {
		[tableViewEditDelayTimer invalidate];
		tableViewEditDelayTimer = nil;
	}
	tableViewEditDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(editButtonAction) userInfo:nil repeats:NO];
}

- (void)editButtonAction {
	if (tableViewEditDelayTimer) {
		[tableViewEditDelayTimer invalidate];
		tableViewEditDelayTimer = nil;
	}
	[[self currentTableView]setEditing:YES animated:YES];
	[self setEditButtonDefaultTitle:NO];
}

- (void)doneButtonPressed {
	willBeginEditing = NO;
	[self setUpAddButton];
	[[self currentTableView]reloadData];
	if (tableViewEditDelayTimer) {
		[tableViewEditDelayTimer invalidate];
		tableViewEditDelayTimer = nil;
	}
	tableViewEditDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(doneButtonAction) userInfo:nil repeats:NO];
}

- (void)doneButtonAction {
	if (tableViewEditDelayTimer) {
		[tableViewEditDelayTimer invalidate];
		tableViewEditDelayTimer = nil;
	}
	[[self currentTableView]setEditing:NO animated:YES];
	[self setEditButtonDefaultTitle:YES];
}

- (void)setUpAddButton {
	// Set up the add button.
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote)];
	notesViewController.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}

- (void)setUpEditButton {
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
	notesViewController.navigationItem.leftBarButtonItem = editButton;
	[editButton release];
}

- (void)setUpDoneButton {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	notesViewController.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)updateElements:(BOOL)updatingIndexBar {
	UISearchBar *searchBar = notesViewController.searchDisplayController.searchBar;
	if (sortOrderSegmentedControl.selectedSegmentIndex == STARRED_ORDER_SEGMENT_INDEX) {
		NSString *searchStarredNotesString = @"Search Starred Notes";
		if (![searchBar.placeholder isEqualToString:searchStarredNotesString]) {
			searchBar.placeholder = searchStarredNotesString;
		}
		if (notesViewController.navigationItem.leftBarButtonItem) {
			notesViewController.navigationItem.leftBarButtonItem = nil;
		}
		if (notesViewController.navigationItem.rightBarButtonItem) {
			notesViewController.navigationItem.rightBarButtonItem = nil;
		}
	}
	else {
		NSString *searchNotesString = @"Search Notes";
		if (![searchBar.placeholder isEqualToString:searchNotesString]) {
			searchBar.placeholder = searchNotesString;
		}
		if ([[[self fetchedResultsController]fetchedObjects]count] > 0) {
			if (!notesViewController.navigationItem.leftBarButtonItem) {
				if ([[self currentTableView]isEditing]) {
					[self setUpDoneButton];
				}
				else {
					[self setUpEditButton];
				}
			}
		}
		else if (notesViewController.navigationItem.leftBarButtonItem) {
			notesViewController.navigationItem.leftBarButtonItem = nil;
			[[self currentTableView]setEditing:NO animated:NO];
		}
		if (!notesViewController.navigationItem.rightBarButtonItem) {
			if (!theTableView.editing) {
				[self setUpAddButton];
			}
		}
	}
	
	NSInteger noteCount = [self totalNumberOfNotes:NO];
	
	NSString *noteCountString = nil;
	if (noteCount > 0) {
		noteCountString = [NSString stringWithFormat:@"Notes (%i)", noteCount];
	}
	else {
		noteCountString = @"Notes (None)";
	}
	noteCountLabel.text = noteCountString;
	landscapeNoteCountLabel.text = noteCountString;
	
	[self updateBadges];
	
	if (updatingIndexBar) {
		[self performSelector:@selector(updateIndexBar) withObject:nil afterDelay:0.3];
	}
	else {
		[[self currentTableView]reloadData];
	}
}

- (void)updateBadges {
	[self updateNotesSectionBadge];
	[self updateAppIconBadgeNumber];
}

- (void)updateNotesSectionBadge {
	NSInteger noteCount = [self totalNumberOfNotes:YES];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	UITabBarItem *tabBarItem = [[tabBarController.viewControllers objectAtIndex:0]tabBarItem];
	if (([defaults boolForKey:kNotesSectionBadgeKey]) && (noteCount > 0)) {
		tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", noteCount];
	}
	else if (tabBarItem.badgeValue) {
		tabBarItem.badgeValue = nil;
	}
}

- (void)updateAppIconBadgeNumber {
	NSInteger noteCount = [self totalNumberOfNotes:YES];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	UIApplication *application = [UIApplication sharedApplication];
	if ([defaults boolForKey:kAppIconBadgeKey]) {
		application.applicationIconBadgeNumber = noteCount;
	}
	else if (application.applicationIconBadgeNumber > 0) {
		application.applicationIconBadgeNumber = 0;
	}
}

- (void)updateIndexBar {
	[[self currentTableView]reloadData];
	if ([notesViewController.searchDisplayController.searchBar isFirstResponder]) {
		[[UIApplication sharedApplication]endIgnoringInteractionEvents];
	}
	else if (!theTableView.userInteractionEnabled) {
		[theTableView setUserInteractionEnabled:YES];
	}
}

- (NSArray *)notesArray:(BOOL)starredNotesOnly {
	NSManagedObjectContext *context = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:context]];
	if (starredNotesOnly) {
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == %@", kStarredKey, [NSNumber numberWithBool:YES]]]];
	}
	NSError *error = nil;
	NSArray *fetchedObjectsArray = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
		[self abortWithError:error];
	}
	return fetchedObjectsArray;
}

- (NSInteger)totalNumberOfNotes:(BOOL)isStarredNoteCount {
	return [[self notesArray:isStarredNoteCount]count];
}

- (void)setEditButtonDefaultTitle:(BOOL)editButtonDefaultTitle {
	if (editButtonDefaultTitle) {
		[self setUpEditButton];
	}
	else {
		[self setUpDoneButton];
	}
}

- (void)createNewNote {
	[self pushNotesDetailViewControllerForNoteAtIndexPath:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (actionSheet.tag == 0) {
			[self createNewNote];
		}
		else if (actionSheet.tag == 1) {
			[self deleteNoteAtIndexPath:pendingDeleteIndexPath];
			pendingDeleteIndexPath = nil;
		}
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return [[[self fetchedResultsController]sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (sortOrderSegmentedControl.selectedSegmentIndex == ALPHABETICAL_ORDER_SEGMENT_INDEX) {
		NSMutableArray *sectionIndexTitlesArray = [NSMutableArray arrayWithObject:@"{search}"];
		[sectionIndexTitlesArray addObjectsFromArray:[[self fetchedResultsController]sectionIndexTitles]];
		return sectionIndexTitlesArray;
	}
	else {
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if (index == 0) {
		if (searchBarScrollDelayTimer) {
			[searchBarScrollDelayTimer invalidate];
			searchBarScrollDelayTimer = nil;
		}
		searchBarScrollDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(scrollToSearchBar) userInfo:nil repeats:NO];
		return -1;
	}
	else {
		return [[self fetchedResultsController]sectionForSectionIndexTitle:title atIndex:(index - 1)];
	}
}

- (void)scrollToSearchBar {
	if (searchBarScrollDelayTimer) {
		[searchBarScrollDelayTimer invalidate];
		searchBarScrollDelayTimer = nil;
	}
	[[self currentTableView]scrollRectToVisible:[[[self currentTableView]tableHeaderView]frame] animated:NO];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ((notesViewController.sortOrderSegmentedControl.selectedSegmentIndex != ALPHABETICAL_ORDER_SEGMENT_INDEX) && ([notesViewController.searchDisplayController.searchBar.text length] > 0)) {
		NSInteger fetchedObjectsCount = [[[self fetchedResultsController]fetchedObjects]count];
		if (fetchedObjectsCount > 0) {
			return [NSString stringWithFormat:@"Search Results (%i)", fetchedObjectsCount];
		}
		else {
			return @"Search Results (None)";
		}
	}
	else {
		switch (sortOrderSegmentedControl.selectedSegmentIndex) {
			case ALPHABETICAL_ORDER_SEGMENT_INDEX:
			{
				id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
				return [sectionInfo name];
			}
				break;
			case RECENT_ORDER_SEGMENT_INDEX:
				return @"Recent Notes";
				break;
			case CUSTOM_ORDER_SEGMENT_INDEX:
				return @"Custom Order";
				break;
			case STARRED_ORDER_SEGMENT_INDEX:
			{
				NSInteger starredNotesCount = [self totalNumberOfNotes:YES];
				if (starredNotesCount > 0) {
					return [NSString stringWithFormat:@"Starred Notes (%i)", starredNotesCount];
				}
				else {
					return @"Starred Notes (None)";
				}
			}
				break;
			default:
				return nil;
				break;
		}
	}
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!searching) {
		[self setEditButtonDefaultTitle:NO];
	}
	notesViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!searching) {
		[self setEditButtonDefaultTitle:YES];
	}
	[self setUpAddButton];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Configure the cell...
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [[self fetchedResultsController]objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:kTitleKey];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	cell.detailTextLabel.text = [dateFormatter stringFromDate:[managedObject valueForKey:kLastModifiedKey]];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	[dateFormatter release];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if ([[managedObject valueForKey:kStarredKey]isEqual:[NSNumber numberWithBool:YES]]) {
		if (willBeginEditing) {
			/*
			 for (UIView *backgroundColorView in cell.contentView.subviews) {
			 if ([backgroundColorView isKindOfClass:[UIView class]]) {
			 if (backgroundColorView.tag == 1) {
			 [backgroundColorView removeFromSuperview];
			 }
			 }
			 }
			 */
			BOOL doesContainBackgroundColorView = NO;
			for (UIImageView *backgroundColorView in cell.contentView.subviews) {
				if ([backgroundColorView isKindOfClass:[UIImageView class]]) {
					if (backgroundColorView.tag == 2) {
						doesContainBackgroundColorView = YES;
						break;
					}
				}
			}
			if (!doesContainBackgroundColorView) {
				UIImageView *backgroundColorView = [[UIImageView alloc]initWithFrame:CGRectMake(-32, 0, 512, 44)];
				backgroundColorView.tag = 2;
				backgroundColorView.image = [UIImage imageNamed:@"Cell_Background"];
				[cell.contentView insertSubview:backgroundColorView atIndex:0];
				[backgroundColorView release];
			}
		}
		else {
			for (UIImageView *backgroundColorView in cell.contentView.subviews) {
				if ([backgroundColorView isKindOfClass:[UIImageView class]]) {
					if (backgroundColorView.tag == 2) {
						[backgroundColorView removeFromSuperview];
					}
				}
			}
			BOOL doesContainBackgroundColorView = NO;
			for (UIView *backgroundColorView in cell.contentView.subviews) {
				if ([backgroundColorView isKindOfClass:[UIView class]]) {
					if (backgroundColorView.tag == 1) {
						doesContainBackgroundColorView = YES;
						break;
					}
				}
			}
			if (!doesContainBackgroundColorView) {
				UIView *backgroundColorView = [[UIView alloc]initWithFrame:CGRectMake(-32, 0, 512, 44)];
				backgroundColorView.tag = 1;
				backgroundColorView.backgroundColor = [UIColor colorWithRed:0.984314 green:1 blue:0.572549 alpha:1];
				[cell.contentView insertSubview:backgroundColorView atIndex:0];
				[backgroundColorView release];
			}
		}
	}
	else {
		for (UIView *backgroundColorView in cell.contentView.subviews) {
			if ([backgroundColorView isKindOfClass:[UIView class]]) {
				if (backgroundColorView.tag == 1) {
					[backgroundColorView removeFromSuperview];
				}
			}
		}
		for (UIImageView *backgroundColorView in cell.contentView.subviews) {
			if ([backgroundColorView isKindOfClass:[UIImageView class]]) {
				if (backgroundColorView.tag == 2) {
					[backgroundColorView removeFromSuperview];
				}
			}
		}
	}
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return (sortOrderSegmentedControl.selectedSegmentIndex != STARRED_ORDER_SEGMENT_INDEX);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self deleteNoteAtIndexPath:indexPath];
	}
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}   
}

- (void)deleteNoteAtIndexPath:(NSIndexPath *)indexPath {
	if ([notesViewController.searchDisplayController.searchBar isFirstResponder]) {
		[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
	}
	else if (theTableView.userInteractionEnabled) {
		[theTableView setUserInteractionEnabled:NO];
	}
	
	// Delete the managed object for the given index path
	NSManagedObjectContext *context = [[self fetchedResultsController]managedObjectContext];
	[context deleteObject:[[self fetchedResultsController]objectAtIndexPath:indexPath]];
	
	[self saveContext];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (![fromIndexPath isEqual:toIndexPath]) {
		isReordering = YES;
		
		BOOL didInsertRow = NO;
		NSArray *fetchedObjects = [[self fetchedResultsController]fetchedObjects];
		if (fromIndexPath.row < toIndexPath.row) {
			for (int i = 0; i <= (toIndexPath.row - fromIndexPath.row); i++) {
				NSInteger index = (fromIndexPath.row + i);
				NSManagedObject *note = [fetchedObjects objectAtIndex:index];
				if (didInsertRow) {
					[note setValue:[NSNumber numberWithInteger:(index - 1)] forKey:kCustomIndexKey];
				}
				else /* if (i == 0) */ {
					[note setValue:[NSNumber numberWithInteger:toIndexPath.row] forKey:kCustomIndexKey];
					didInsertRow = YES;
				}
				/*
				else {
					// Only if looping throught the entire array.
					[note setValue:[NSNumber numberWithInteger:index] forKey:kCustomIndexKey];
				}
				*/
			}
		}
		else {
			for (int i = fromIndexPath.row; i >= toIndexPath.row; i--) {
				NSManagedObject *note = [fetchedObjects objectAtIndex:i];
				if (didInsertRow) {
					[note setValue:[NSNumber numberWithInteger:(i + 1)] forKey:kCustomIndexKey];
				}
				else /* if (i == fromIndexPath.row) */ {
					[note setValue:[NSNumber numberWithInteger:toIndexPath.row] forKey:kCustomIndexKey];
					didInsertRow = YES;
				}
				/*
				else {
					// Only if looping throught the entire array.
					[note setValue:[NSNumber numberWithInteger:i] forKey:kCustomIndexKey];
				}
				*/
			}
		}
		
		[self saveContext];
	}
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the item to be re-orderable.
	return (sortOrderSegmentedControl.selectedSegmentIndex == CUSTOM_ORDER_SEGMENT_INDEX);
}

#pragma mark -
#pragma mark Fetched results controller

- (void)setUpFetchedResultsControllerWithCache:(BOOL)cache {
	// Set up the fetched results controller.
	
	// The equivalent of this would go in the app delegate if this was a navigation based application.
	managedObjectContext = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	[self updateFiltersWithFetchRequest:fetchRequest];
	
	// Edit the sort key as appropriate.
	// NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:[self sortDescriptorKey] ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc]initWithArray:[self theSortDescriptors]];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
															 initWithFetchRequest:fetchRequest
															 managedObjectContext:managedObjectContext
															 sectionNameKeyPath:
															 sortOrderSegmentedControl.selectedSegmentIndex == ALPHABETICAL_ORDER_SEGMENT_INDEX ?
															 kSectionTitleKey : nil
															 cacheName:cache ? @"Root" : nil
															 ];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	// [sortDescriptor release];
	[sortDescriptors release];
}

- (void)performFetch {
	NSError *error = nil;
	if (![[self fetchedResultsController]performFetch:&error]) {
		[self abortWithError:error];
	}
}

- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
	
	[self setUpFetchedResultsControllerWithCache:!searching];
	
	return fetchedResultsController;
}

- (NSArray *)theSortDescriptors {
	switch (sortOrderSegmentedControl.selectedSegmentIndex) {
		case ALPHABETICAL_ORDER_SEGMENT_INDEX:
			return [NSArray arrayWithObjects:
					[NSSortDescriptor sortDescriptorWithKey:kTitleKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
					[NSSortDescriptor sortDescriptorWithKey:kLastModifiedKey ascending:NO],
					nil];
			break;
		case RECENT_ORDER_SEGMENT_INDEX:
			return [NSArray arrayWithObjects:
					[NSSortDescriptor sortDescriptorWithKey:kLastModifiedKey ascending:NO],
					[NSSortDescriptor sortDescriptorWithKey:kTitleKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
					nil];
			break;
		case CUSTOM_ORDER_SEGMENT_INDEX:
			return [NSArray arrayWithObjects:
					[NSSortDescriptor sortDescriptorWithKey:kCustomIndexKey ascending:YES],
					nil];
			break;
		case STARRED_ORDER_SEGMENT_INDEX:
			return [NSArray arrayWithObjects:
					[NSSortDescriptor sortDescriptorWithKey:kStarredKey ascending:YES],
					[NSSortDescriptor sortDescriptorWithKey:kLastModifiedKey ascending:NO],
					nil];
			break;
		default:
			return [NSArray arrayWithObjects:
					[NSSortDescriptor sortDescriptorWithKey:kTitleKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
					[NSSortDescriptor sortDescriptorWithKey:kLastModifiedKey ascending:NO],
					nil];
			break;
	}
}

- (void)abortWithError:(NSError *)error {
	// Replace this implementation with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	abort();
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (UITableView *)currentTableView {
	if (searching) {
		if ([notesViewController.searchDisplayController.searchBar.text length] > 0) {
			return notesViewController.searchDisplayController.searchResultsTableView;
		}
		else {
			return theTableView;
		}
	}
	else {
		return theTableView;
	}
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (!isReordering) {
		[[self currentTableView]beginUpdates];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableView *currentTableView = [self currentTableView];
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[currentTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
			break;
		case NSFetchedResultsChangeDelete:
			[currentTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
			break;
	}
	[self updateElements:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *currentTableView = [self currentTableView];
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[currentTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[self updateElements:YES];
			break;
		case NSFetchedResultsChangeDelete:
			[currentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
			[self updateElements:YES];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[currentTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
		{
			if (!currentTableView.editing) {
				[currentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[currentTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (isReordering) {
		isReordering = NO;
	}
	[[self currentTableView]endUpdates];
}

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
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self pushNotesDetailViewControllerForNoteAtIndexPath:indexPath];
}

- (void)pushNotesDetailViewControllerForNoteAtIndexPath:(NSIndexPath *)indexPath {
	NotesDetailViewController *notesDetailViewController = [[NotesDetailViewController alloc]initWithNibName:@"NotesDetailViewController" bundle:nil];
	notesDetailViewController.isNewNote = (!indexPath);
	if (indexPath == nil) {
		notesDetailViewController.title = @"New Note";
		notesDetailViewController.noteIndexPath = [[[self fetchedResultsController]indexPathForObject:[self createNewNoteWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[self totalNumberOfNotes:NO]], kCustomIndexKey, [NSDate date], kLastModifiedKey, [NSNumber numberWithBool:NO], kStarredKey, nil]]]retain];
	}
	else {
		NSManagedObject *note = [[self fetchedResultsController]objectAtIndexPath:indexPath];
		notesDetailViewController.title = [note valueForKey:kTitleKey];
		notesDetailViewController.noteIndexPath = [indexPath retain];
	}
	[notesViewController.navigationController pushViewController:notesDetailViewController animated:YES];
	[notesDetailViewController release];
}

#pragma mark -
#pragma mark Search bar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[self setUpFetchedResultsControllerWithCache:NO];
	[self performFetch];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self didFinishSearching];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	if ([searchBar.text length] <= 0) {
		[self didFinishSearching];
	}
}

- (void)didFinishSearching {
	if (searching) {
		searching = NO;
	}
	[self setUpFetchedResultsControllerWithCache:YES];
	[self performFetch];
	[[self currentTableView]reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([searchText length] > 0) {
		if (!searching) {
			searching = YES;
		}
	}
	else if (searching) {
		searching = NO;
	}
	[self updateFiltersWithFetchRequest:[[self fetchedResultsController]fetchRequest]];
	[self performFetch];
	[self updateElements:NO];
	[[self currentTableView]reloadData];
}

- (void)updateFiltersWithFetchRequest:(NSFetchRequest *)fetchRequest {
	NSPredicate *starredPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == %@", kStarredKey, [NSNumber numberWithBool:YES]]];
	NSString *searchText = notesViewController.searchDisplayController.searchBar.text;
	BOOL isSearchingStarredNotes = (sortOrderSegmentedControl.selectedSegmentIndex == STARRED_ORDER_SEGMENT_INDEX);
	if ((searching) && ([searchText length] > 0)) {
		NSPredicate *predicate = nil;
		NSPredicate *titlePredicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:kTitleKey]
																		 rightExpression:[NSExpression expressionForConstantValue:searchText]
																				modifier:NSDirectPredicateModifier
																					type:NSContainsPredicateOperatorType
																				 options:NSCaseInsensitivePredicateOption];
		NSPredicate *bodyPredicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:kBodyKey]
																		rightExpression:[NSExpression expressionForConstantValue:searchText]
																			   modifier:NSDirectPredicateModifier
																				   type:NSContainsPredicateOperatorType
																				options:NSCaseInsensitivePredicateOption];
		
		if (notesViewController.searchDisplayController.searchBar.selectedScopeButtonIndex == NOTE_TITLE_SCOPE_SEGMENT_INDEX) {
			if (isSearchingStarredNotes) {
				predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:titlePredicate, starredPredicate, nil]];
			}
			else {
				predicate = titlePredicate;
			}
		}
		else {
			NSPredicate *titleOrBodyPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:titlePredicate, bodyPredicate, nil]];
			if (isSearchingStarredNotes) {
				predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:titleOrBodyPredicate, starredPredicate, nil]];
			}
			else {
				predicate = titleOrBodyPredicate;
			}
		}
		[fetchRequest setPredicate:predicate];
	}
	else {
		if (isSearchingStarredNotes) {
			[fetchRequest setPredicate:starredPredicate];
		}
		else {
			[fetchRequest setPredicate:nil];
		}
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	[self updateFiltersWithFetchRequest:[[self fetchedResultsController]fetchRequest]];
	[self performFetch];
	[[self currentTableView]reloadData];
}

#pragma mark -
#pragma mark Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc]init];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil]retain];	
	return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
	
	if (![[NSFileManager defaultManager]fileExistsAtPath:[self applicationDataStorageDirectory]]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager]createDirectoryAtPath:[self applicationDataStorageDirectory] withIntermediateDirectories:NO attributes:nil error:&error]) {
			[self abortWithError:error];
		}
	}
	NSURL *storeUrl = [NSURL fileURLWithPath:[self applicationPersistentStorePath]];

	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		Typical reasons for an error here include:
		* The persistent store is not accessible
		* The schema for the persistent store is incompatible with current managed object model
		Check the error message to determine what the actual problem was.
		*/
		[self abortWithError:error];
	}
	
	if ([[[UIDevice currentDevice]systemVersion]compare:@"4.0"] != NSOrderedAscending) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[self applicationPersistentStorePath]]) {
			if (![fileManager setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:[self applicationPersistentStorePath] error:&error]) {
				[self abortWithError:error];
			}
		}
	}
	 
	return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Library directory

// Returns the path to the application's Library directory.
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationDataStorageDirectory {
	return [[self applicationLibraryDirectory]stringByAppendingPathComponent:@"Documents"];
}

- (NSString *)applicationPersistentStorePath {
	return [[self applicationDataStorageDirectory]stringByAppendingPathComponent:@"Data.sqlite"];
}

#pragma mark -
#pragma mark Security

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
	NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc]init];
	
	[searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	NSData *encodedIdentifier = [identifier dataUsingEncoding:NSASCIIStringEncoding];
	[searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
	[searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
	[searchDictionary setObject:kKeychainServiceName forKey:(id)kSecAttrService];
	
	return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
	NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
	
	// Add search attributes
	[searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	
	// Add search return types
	[searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSData *result = nil;
	SecItemCopyMatching((CFDictionaryRef)searchDictionary,
						(CFTypeRef *)&result);
	
	/*
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDictionary,
										  (CFTypeRef *)&result);
	*/
	
	[searchDictionary release];

	return result;
}

- (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
	NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
	
	// This is used as a safety net in case the item already exists.
	SecItemDelete((CFDictionaryRef)dictionary);
	
	NSData *data = [value dataUsingEncoding:NSASCIIStringEncoding];
	[dictionary setObject:data forKey:(id)kSecValueData];
	
	OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
	[dictionary release];
	
	if (status == errSecSuccess) {
		return YES;
	}
	return NO;
}

- (BOOL)updateKeychainValue:(NSString *)updatedValue forIdentifier:(NSString *)identifier {
	NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
	NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc]init];
	NSData *updatedData = [updatedValue dataUsingEncoding:NSASCIIStringEncoding];
	[updateDictionary setObject:updatedData forKey:(id)kSecValueData];
	
	OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,
									(CFDictionaryRef)updateDictionary);
	
	[searchDictionary release];
	[updateDictionary release];
	
	if (status == errSecSuccess) {
		return YES;
	}
	return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier {
	NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
	SecItemDelete((CFDictionaryRef)searchDictionary);
	[searchDictionary release];
}

- (NSString *)stringForKey:(NSString *)key {
	NSData *stringData = [self searchKeychainCopyMatching:key];
	if (stringData) {
		NSString *string = [[NSString alloc]initWithData:stringData encoding:NSASCIIStringEncoding];
		[stringData release];
		NSString *stringCopy = [NSString stringWithString:string];
		[string release];
		return stringCopy;
	}
	[stringData release];
	return nil;
}

#pragma mark -
#pragma mark Social Networking

- (void)displayCannotLaunchAppStoreAlert {
	UIAlertView *cannotLaunchAppStoreAlert = [[UIAlertView alloc]
											  initWithTitle:@"Cannot Launch App Store"
											  message:@"Your request could not be completed due to the restrictions on your device. Please enable the App Store application and try again.\n(Launch the Settings app, select General > Restrictions, and turn on the \"Installing Apps\" switch.)"
											  delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[cannotLaunchAppStoreAlert show];
	[cannotLaunchAppStoreAlert release];
}

- (void)presentTwitterViewWithMessage:(NSString *)message {
	if (([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) && (NSClassFromString(@"TWTweetComposeViewController"))) {
		if ([TWTweetComposeViewController canSendTweet]) {
			TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc]init];
			[tweetComposeViewController setInitialText:message];
			[rootViewController presentModalViewController:tweetComposeViewController animated:YES];
			[tweetComposeViewController release];
		}
		else {
			UIAlertView *twitterAccountNotConfiguredAlert = [[UIAlertView alloc]
															 initWithTitle:@"Twitter Account Not Configured"
															 message:@"You must configure your device to work with your Twitter account in order to send tweets. You can do this in the Settings app."
															 delegate:nil
															 cancelButtonTitle:@"OK"
															 otherButtonTitles:nil];
			[twitterAccountNotConfiguredAlert show];
			[twitterAccountNotConfiguredAlert release];
		}
	}
	else {
		if (pendingTweet){
			[pendingTweet release];
			pendingTweet = nil;
		}
		if (message) {
			pendingTweet = [[NSString alloc]initWithString:message];
		}
		
		// if (!twitterEngine) return;
		
		[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:twitterEngine delegate:self];
		if (controller) {
			pendingTwitterPostRequest = YES;
			[rootViewController presentModalViewController:controller animated:YES];
		}
		else {
			[rootViewController presentTwitterPostView];
		}
		/*
		 else {
		 [twitterEngine sendUpdate:[NSString stringWithFormat:@"Already Updated. %@", [NSDate date]]];
		 }
		 */
	}
}

- (void)sendEmail {
    [self presentMailComposeControllerWithSubject:pendingEmailSubject message:pendingEmailBody isHTML:pendingEmailBodyIsHTML attachedFilePath:nil attachedFileMIMEType:nil];
}

- (void)presentMailComposeControllerWithSubject:(NSString *)subject message:(NSString *)message isHTML:(BOOL)isHTML attachedFilePath:(NSString *)attachedFilePath attachedFileMIMEType:(NSString *)attachedFileMIMEType {
	if ([MFMailComposeViewController canSendMail]) {
        pendingEmailSubject = subject;
        pendingEmailBody = message;
        pendingEmailBodyIsHTML = isHTML;
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setSubject:subject];
		[mailComposeViewController setMessageBody:message isHTML:isHTML];
		if (attachedFilePath) {
			[mailComposeViewController addAttachmentData:[NSData dataWithContentsOfFile:attachedFilePath] mimeType:attachedFileMIMEType fileName:[[attachedFilePath pathComponents]lastObject]];
		}
		[rootViewController presentModalViewController:mailComposeViewController animated:YES];
		[mailComposeViewController release];
	}
	else {
		[self displayCannotSendMailAlert];
	}
}

- (void)displayCannotSendMailAlert {
	UIAlertView *cannotSendMailAlert = [[UIAlertView alloc]
										initWithTitle:@"Cannot Send Mail"
										message:@"You must configure your device to work with your email account in order to send email. Would you like to do this now?"
										delegate:self
										cancelButtonTitle:@"No Thanks"
										otherButtonTitles:@"Sure", nil];
	cannotSendMailAlert.tag = 6;
	[cannotSendMailAlert show];
	[cannotSendMailAlert release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[rootViewController dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultFailed) {
		UIAlertView *sendFailedAlert = [[UIAlertView alloc]
										initWithTitle:@"Send Failed"
										message:@"Your message could not be sent. This could be due to little or no Internet connectivity."
										delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"Retry", nil];
		sendFailedAlert.tag = 7;
		[sendFailedAlert show];
		[sendFailedAlert release];
	}
}

#pragma mark SA_OAuthTwitterEngineDelegate

- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:kTwitterAuthenticationDataKey];
	[defaults synchronize];
}

- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username {
	return [[NSUserDefaults standardUserDefaults]objectForKey:kTwitterAuthenticationDataKey];
}

#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
	[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
	// NSLog(@"Authenicated for %@", username);
}

/*
 - (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller {
 NSLog(@"Authentication Failed!");
 }
 */

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller {
	pendingTwitterPostRequest = NO;
	// NSLog(@"Authentication Canceled.");
}

#pragma mark -
#pragma mark TwitterEngineDelegate

/*
 - (void)requestSucceeded:(NSString *)requestIdentifier {
 NSLog(@"Request %@ succeeded", requestIdentifier);
 }
 
 - (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error {
 NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
 }
 */

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	/*
	 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	 */
}

- (void)dealloc {
	[managedObjectModel release];
	[managedObjectContext release];
	[persistentStoreCoordinator release];
	
    [window release];
	[tabBarController release];
    [noteCountLabel release];
	[lastAccessedDateLabel release];
	[landscapeNoteCountLabel release];
	[notesViewController release];
	[rootViewController release];
	
	[networkStatusChangeNotifier release];
	
	[facebook release];
	[twitterEngine release];
	
	// Notes
	
	[fetchedResultsController release];
	
	[super dealloc];
}

@end


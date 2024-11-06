//
//  TwitterPostViewController.m
//  MyTube
//
//  Created by Harrison White on 5/30/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "TwitterPostViewController.h"
#import "Note_SafeAppDelegate.h"
#import "SA_OAuthTwitterEngine.h"
#import "NetworkStatusChangeNotifier.h"

#define MAXIMUM_CHARACTER_COUNT 140

static NSString *kIntegerFormatSpecifierStr		= @"%i";
static NSString *kNegativeCharactersPrefixStr	= @"-";

@implementation TwitterPostViewController

@synthesize theNavigationBar;
@synthesize cancelButton;
@synthesize postButton;
@synthesize postTextView;
@synthesize charactersRemainingLabel;
@synthesize message;

- (IBAction)cancelButtonPressed {
	[self dismiss];
}

- (IBAction)postButtonPressed {
	[self postTweet];
}

- (void)dismiss {
	[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]dismissModalViewControllerAnimated:YES];
}

- (void)postTweet {
	if ([postTextView.text length] > 0) {
		if ([postTextView.text length] > MAXIMUM_CHARACTER_COUNT) {
			UIAlertView *tweetExceedsLimitAlert = [[UIAlertView alloc]
												   initWithTitle:@"Cannot Post Tweet"
												   message:[NSString stringWithFormat:@"This tweet exceeds Twitter's limit of %i characters. Please shorten your message and try again.", MAXIMUM_CHARACTER_COUNT]
												   delegate:nil
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
			[tweetExceedsLimitAlert show];
			[tweetExceedsLimitAlert release];
		}
		else {
			if ([[NetworkStatusChangeNotifier defaultNotifier]currentNetworkStatus] == kNetworkStatusNotConnected) {
				UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
												   initWithTitle:@"Cannot Connect to Twitter"
												   message:@"Please check your Internet connection status and try again."
												   delegate:nil
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
				[cannotConnectAlert show];
				[cannotConnectAlert release];
			}
			else {
				[(SA_OAuthTwitterEngine *)[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]twitterEngine]sendUpdate:postTextView.text];
				[self dismiss];
			}
		}
	}
	else {
		UIAlertView *nullTweetAlert = [[UIAlertView alloc]
										initWithTitle:@"No Text Entered"
										message:@"You must enter text in order to post a tweet."
										delegate:nil
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil];
		[nullTweetAlert show];
		[nullTweetAlert release];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textViewDidChange:(UITextView *)textView {
	[self updateCharactersRemainingLabel];
}

- (void)updateCharactersRemainingLabel {
	if ([postTextView.text length] > 0) {
		postButton.enabled = YES;
	}
	else {
		postButton.enabled = NO;
	}
	if ([postTextView.text length] > MAXIMUM_CHARACTER_COUNT) {
		// charactersRemainingLabel.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
		charactersRemainingLabel.text = [NSString stringWithFormat:[kNegativeCharactersPrefixStr stringByAppendingString:kIntegerFormatSpecifierStr], ([postTextView.text length] - MAXIMUM_CHARACTER_COUNT)];
	}
	else {
		// charactersRemainingLabel.textColor = [UIColor colorWithRed:0 green:0.35 blue:0 alpha:1];
		charactersRemainingLabel.text = [NSString stringWithFormat:kIntegerFormatSpecifierStr, (MAXIMUM_CHARACTER_COUNT - [postTextView.text length])];
	}
}

- (void)keyboardDidShow:(NSNotification *)notification {
	CGRect keyboardFrame;
	[[[notification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey]getValue:&keyboardFrame];
	CGRect frame = CGRectMake(0, theNavigationBar.frame.size.height, 0, 0);
	if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
		frame.size = CGSizeMake(keyboardFrame.size.width, ((self.view.frame.size.height - (keyboardFrame.size.height + theNavigationBar.frame.size.height)) - 40));
	}
	else {
		frame.size = CGSizeMake(keyboardFrame.size.height, ((self.view.frame.size.width - (keyboardFrame.size.width + theNavigationBar.frame.size.height)) - 30));
	}
	charactersRemainingLabel.frame = CGRectMake(20, (frame.origin.y + frame.size.height), (frame.size.width - 40), 21);
	postTextView.frame = frame;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	postTextView.text = message;
	[self updateCharactersRemainingLabel];
	[postTextView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	CGSize navigationBarSize = [theNavigationBar sizeThatFits:self.view.bounds.size];
	theNavigationBar.frame = CGRectMake(0, 0, navigationBarSize.width, navigationBarSize.height);
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.theNavigationBar = nil;
	self.cancelButton = nil;
	self.postButton = nil;
	self.postTextView = nil;
	self.charactersRemainingLabel = nil;
}

- (void)dealloc {
	[theNavigationBar release];
	[cancelButton release];
	[postButton release];
	[postTextView release];
	[charactersRemainingLabel release];
    [super dealloc];
}

@end

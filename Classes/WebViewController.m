//
//  WebViewController.m
//  Note Safe
//
//  Created by Harrison White on 7/7/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "WebViewController.h"
#import "NetworkStatusChangeNotifier.h"

static NSString *kFacebookPageURL	= @"http://www.facebook.com/harrisonapps";
static NSString *kTwitterPageURL	= @"http://www.twitter.com/harrisonapps";

@implementation WebViewController

@synthesize theWebView;
@synthesize toolbar;
@synthesize backButton;
@synthesize forwardButton;
@synthesize loadingActivityIndicatorView;
@synthesize isFacebookPage;
@synthesize networkStatusChangeNotifier;

- (IBAction)refreshButtonPressed {
	if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
		[self displayCannotConnectAlert];
	}
	else {
		[theWebView reload];
	}
}

- (void)adDidLoad {
	toolbar.frame = CGRectMake(0, 273, 320, 44);
	theWebView.frame = CGRectMake(0, 0, 320, 273);
}

- (void)adDidFailLoad {
	theWebView.frame = CGRectMake(0, 0, 320, 323);
	toolbar.frame = CGRectMake(0, 323, 320, 44);
}

- (void)attemptToLoadRequest:(NSURLRequest *)request {
	if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
		[self displayCannotConnectAlert];
	}
	else {
		[theWebView loadRequest:request];
	}
}

- (NSURLRequest *)applicableURLRequest {
	return [NSURLRequest requestWithURL:[NSURL URLWithString:isFacebookPage ? kFacebookPageURL : kTwitterPageURL]];
}

- (void)displayCannotConnectAlert {
	UIAlertView *cannotConnectAlert = [[UIAlertView alloc]
									   initWithTitle:[@"Cannot Connect to " stringByAppendingString:isFacebookPage ? @"Facebook" : @"Twitter"]
									   message:@"Please check your Internet connection status and try again."
									   delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[cannotConnectAlert show];
	[cannotConnectAlert release];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	UIBarButtonItem *stopLoadingButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:theWebView action:@selector(stopLoading)];
	UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceBarButtonItem, backButton, flexibleSpaceBarButtonItem, forwardButton, flexibleSpaceBarButtonItem, stopLoadingButton, flexibleSpaceBarButtonItem, nil]];
	[flexibleSpaceBarButtonItem release];
	[stopLoadingButton release];
	[loadingActivityIndicatorView startAnimating];
	// [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
	[self updateNavigationButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self didFinishLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self didFinishLoading];
}

- (void)didFinishLoading {
	UIBarButtonItem *newRefreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:theWebView	action:@selector(reload)];
	UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceBarButtonItem, backButton, flexibleSpaceBarButtonItem, forwardButton, flexibleSpaceBarButtonItem, newRefreshButton, flexibleSpaceBarButtonItem, nil]];
	[flexibleSpaceBarButtonItem release];
	[newRefreshButton release];
	[loadingActivityIndicatorView stopAnimating];
	// [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	[self updateNavigationButtons];
}

- (void)updateNavigationButtons {
	backButton.enabled = theWebView.canGoBack;
	forwardButton.enabled = theWebView.canGoForward;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	loadingActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
	loadingActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	loadingActivityIndicatorView.hidesWhenStopped = YES;
	
	UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 27, 20)];
	loadingView.backgroundColor = [UIColor clearColor];
	[loadingView addSubview:loadingActivityIndicatorView];
	
	UIBarButtonItem *loadingBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:loadingView];
	loadingBarButtonItem.style = UIBarButtonItemStyleBordered;
	
	self.navigationItem.rightBarButtonItem = loadingBarButtonItem;
	
	[loadingView release];
	[loadingBarButtonItem release];
	
	networkStatusChangeNotifier = [[NetworkStatusChangeNotifier defaultNotifier]retain];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusDidChange) name:kNetworkStatusDidChangeNotification object:networkStatusChangeNotifier];
	[networkStatusChangeNotifier startNotifier];
	[self attemptToLoadRequest:[self applicableURLRequest]];
}

- (void)networkStatusDidChange {
	if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
		[self displayCannotConnectAlert];
	}
	else {
		if (theWebView.request) {
			[theWebView reload];
		}
		else {
			[theWebView loadRequest:[self applicableURLRequest]];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	CGSize boundsSize = self.view.bounds.size;
	CGFloat height = [toolbar sizeThatFits:boundsSize].height;
	toolbar.frame = CGRectMake(toolbar.frame.origin.x, (boundsSize.height - height), boundsSize.width, height);
	theWebView.frame = CGRectMake(theWebView.frame.origin.x, theWebView.frame.origin.y, boundsSize.width, (boundsSize.height - height));
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.theWebView = nil;
	self.toolbar = nil;
	self.backButton = nil;
	self.forwardButton = nil;
	self.networkStatusChangeNotifier = nil;
}

- (void)dealloc {
	[theWebView release];
	[toolbar release];
	[backButton release];
	[forwardButton release];
	[networkStatusChangeNotifier release];
    [super dealloc];
}

@end

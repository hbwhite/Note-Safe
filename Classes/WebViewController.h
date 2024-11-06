//
//  WebViewController.h
//  Note Safe
//
//  Created by Harrison White on 7/7/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetworkStatusChangeNotifier;

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *theWebView;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;
	UIActivityIndicatorView *loadingActivityIndicatorView;
	BOOL isFacebookPage;
	NetworkStatusChangeNotifier *networkStatusChangeNotifier;
}

@property (nonatomic, retain) IBOutlet UIWebView *theWebView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, assign) UIActivityIndicatorView *loadingActivityIndicatorView;
@property (readwrite) BOOL isFacebookPage;
@property (nonatomic, assign) NetworkStatusChangeNotifier *networkStatusChangeNotifier;

- (IBAction)refreshButtonPressed;
- (void)attemptToLoadRequest:(NSURLRequest *)request;
- (NSURLRequest *)applicableURLRequest;
- (void)displayCannotConnectAlert;
- (void)didFinishLoading;
- (void)updateNavigationButtons;

@end

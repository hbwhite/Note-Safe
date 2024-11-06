//
//  LoginView.m
//  Note Safe
//
//  Created by Harrison White on 2/1/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "LoginView.h"
#import "LoginNavigationController.h"

@implementation LoginView

@synthesize delegate;
@synthesize loginNavigationController;
@synthesize firstSegmentLoginViewType;
@synthesize secondSegmentLoginViewType;
@synthesize loginType;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	LoginNavigationController *theLoginNavigationController = (LoginNavigationController *)loginNavigationController;
	theLoginNavigationController.delegate = delegate;
	theLoginNavigationController.firstSegmentLoginViewType = firstSegmentLoginViewType;
	theLoginNavigationController.secondSegmentLoginViewType = secondSegmentLoginViewType;
	theLoginNavigationController.loginType = loginType;
	UINavigationItem *topItem = loginNavigationController.navigationBar.topItem;
	switch (loginType) {
		case kLoginTypeLogin:
			topItem.title = @"Note Safe";
			break;
		case kLoginTypeAuthenticate:
			topItem.title = @"Enter Passcode";
			break;
		case kLoginTypeChangePasscode:
			topItem.title = @"Change Passcode";
			break;
		case kLoginTypeCreatePasscode:
			topItem.title = @"Create Passcode";
			break;
	}
	[[loginNavigationController view]setFrame:CGRectMake(0, 0, 320, 460)];
	[self.view addSubview:[loginNavigationController view]];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[loginNavigationController viewWillAppear:animated];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[loginNavigationController viewDidAppear:animated];
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[loginNavigationController viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[loginNavigationController viewDidDisappear:animated];
	[super viewDidDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.loginNavigationController = nil;
}


- (void)dealloc {
	[loginNavigationController release];
    [super dealloc];
}


@end

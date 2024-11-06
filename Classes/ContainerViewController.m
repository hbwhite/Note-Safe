//
//  ContainerViewController.m
//  Note Safe
//
//  Created by Harrison White on 10/30/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "ContainerViewController.h"
#import "Note_SafeAppDelegate.h"
#import "TwitterPostViewController.h"

@implementation ContainerViewController

@synthesize parent;

- (void)viewWillAppear:(BOOL)animated {
	if (animated) {
		[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]showAlertIfApplicable];
	}
	[parent viewWillAppear:animated];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (delegate.pendingTwitterPostRequest) {
		delegate.pendingTwitterPostRequest = NO;
		[self presentTwitterPostView];
	}
	else {
		[parent viewDidAppear:animated];
	}
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[parent viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if (self.modalViewController) {
		if ([[UIApplication sharedApplication]isIgnoringInteractionEvents]) {
			[[UIApplication sharedApplication]endIgnoringInteractionEvents];
		}
	}
	[parent viewDidDisappear:animated];
	[super viewDidDisappear:animated];
}

- (void)presentTwitterPostView {
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	TwitterPostViewController *twitterPostViewController = [[TwitterPostViewController alloc]initWithNibName:@"TwitterPostViewController" bundle:nil];
	if (delegate.pendingTweet) {
		twitterPostViewController.message = [NSString stringWithString:delegate.pendingTweet];
		[delegate.pendingTweet release];
		delegate.pendingTweet = nil;
	}
	[self presentModalViewController:twitterPostViewController animated:YES];
	[twitterPostViewController release];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if ([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] == NSOrderedAscending) {
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			[parent shouldAutorotateToInterfaceOrientation:interfaceOrientation];
			return YES;
		}
		else {
			return NO;
		}
	}
	else {
		[parent shouldAutorotateToInterfaceOrientation:interfaceOrientation];
		for (UINavigationController *navigationController in parent.viewControllers) {
			UINavigationBar *navigationBar = navigationController.navigationBar;
			CGSize boundsSize = navigationController.topViewController.view.bounds.size;
			navigationBar.frame = CGRectMake(0, 0, boundsSize.width, [navigationBar sizeThatFits:boundsSize].height);
		}
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
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
}


- (void)dealloc {
    [super dealloc];
}


@end

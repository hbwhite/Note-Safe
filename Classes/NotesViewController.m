//
//  NotesViewController.m
//  Note Safe
//
//  Created by Harrison White on 1/12/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "NotesViewController.h"
#import "Note_SafeAppDelegate.h"

@implementation NotesViewController

@synthesize delegate;

@synthesize theTableView;
@synthesize theToolbar;
@synthesize sortOrderSegmentedControl;

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

- (IBAction)sortOrderSegmentedControlValueChanged {
	[delegate setUpFetchedResultsControllerWithCache:YES];
	[delegate performFetch];
	[delegate updateElements:NO];
}

- (void)backButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Notes" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
	[backBarButtonItem release];
	
	delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	theTableView.dataSource = delegate;
	theTableView.delegate = delegate;
	
	UISearchDisplayController *searchDisplayController = self.searchDisplayController;
	searchDisplayController.searchBar.delegate = delegate;
	searchDisplayController.delegate = delegate;
	searchDisplayController.searchResultsDataSource = delegate;
	searchDisplayController.searchResultsDelegate = delegate;
	
	
	delegate.notesViewController = self;
	delegate.theTableView = theTableView;
	delegate.theToolbar = theToolbar;
	delegate.sortOrderSegmentedControl = sortOrderSegmentedControl;
	
	[delegate performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
	[delegate performFetch];
	[delegate updateElements:NO];
	[self orientationDidChangeAction];
	[super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	[self orientationDidChangeAction];
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)orientationDidChangeAction {
	UIToolbar *toolbar = delegate.theToolbar;
	CGSize boundsSize = delegate.notesViewController.view.bounds.size;
	CGFloat height = [toolbar sizeThatFits:boundsSize].height;
	toolbar.frame = CGRectMake(0, (boundsSize.height - height), boundsSize.width, height);
	theTableView.frame = CGRectMake(0, 0, boundsSize.width, (boundsSize.height - height));
	if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
		delegate.landscapeNoteCountLabel.hidden = YES;
		delegate.noteCountLabel.hidden = NO;
		delegate.lastAccessedDateLabel.hidden = NO;
	}
	else {
		delegate.noteCountLabel.hidden = YES;
		delegate.lastAccessedDateLabel.hidden = YES;
		delegate.landscapeNoteCountLabel.hidden = NO;
	}
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
	
	self.theTableView = nil;
	self.theToolbar = nil;
	self.sortOrderSegmentedControl = nil;
}

- (void)dealloc {
	[theTableView release];
	[theToolbar release];
	[sortOrderSegmentedControl release];
	[super dealloc];
}

@end


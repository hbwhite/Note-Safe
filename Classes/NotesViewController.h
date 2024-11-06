//
//  NotesViewController.h
//  Note Safe
//
//  Created by Harrison White on 1/12/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Note_SafeAppDelegate;

@interface NotesViewController : UIViewController {
	Note_SafeAppDelegate *delegate;
	
	IBOutlet UITableView *theTableView;
	IBOutlet UIToolbar *theToolbar;
	IBOutlet UISegmentedControl *sortOrderSegmentedControl;
}

@property (nonatomic, assign) Note_SafeAppDelegate *delegate;

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UIToolbar *theToolbar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sortOrderSegmentedControl;

- (IBAction)sortOrderSegmentedControlValueChanged;
- (void)backButtonPressed;
- (void)orientationDidChangeAction;

@end

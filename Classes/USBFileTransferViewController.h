//
//  USBFileTransferViewController.h
//  Note Safe
//
//  Created by Harrison White on 8/1/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class HUDView;

@interface USBFileTransferViewController : UIViewController {
	IBOutlet UITableView *theTableView;
	IBOutlet UINavigationBar *searchStatusNavigationBar;
	IBOutlet UIToolbar *searchStatusToolbar;
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	NSMutableArray *filesArray;
	NSMutableArray *originalFilesArray;
	NSTimer *refreshTimer;
	NSInteger section;
	NSInteger index;
	NSInteger currentItem;
	BOOL isImporting;
	BOOL indexIsRelevant;
	HUDView *hudView;
}

@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *searchStatusNavigationBar;
@property (nonatomic, retain) IBOutlet UIToolbar *searchStatusToolbar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) NSMutableArray *filesArray;
@property (nonatomic, assign) NSMutableArray *originalFilesArray;
@property (nonatomic, assign) NSTimer *refreshTimer;
@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger currentItem;
@property (readwrite) BOOL isImporting;
@property (readwrite) BOOL indexIsRelevant;
@property (nonatomic, assign) HUDView *hudView;

- (void)importButtonPressed;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)filePathForNoteWithTitle:(NSString *)title copyNumber:(NSInteger)copyNumber;
- (void)setUpRefreshTimer;
- (void)_showHUD;
- (void)fadeOutHUD;
- (void)_updateElements;
- (void)refreshList;
- (void)importNotes;
- (void)importNoteAtPath:(NSString *)path;
- (void)_deleteFiles;

@end

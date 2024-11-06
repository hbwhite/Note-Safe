//
//  Note_SafeAppDelegate.h
//  Note Safe
//
//  Created by Harrison White on 7/15/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Security/Security.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

#import "FBConnect.h"
#import "SA_OAuthTwitterController.h"

@class ContainerViewController;
@class NotesViewController;
@class NetworkStatusChangeNotifier;

#define kAppTitleStr	@"Note Safe"
#define kAppStoreURLStr	@"http://itunes.apple.com/us/app/note-safe/id480357969?mt=8"

@interface Note_SafeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, FBSessionDelegate, FBDialogDelegate, SA_OAuthTwitterControllerDelegate> {
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UILabel *noteCountLabel;
	IBOutlet UILabel *lastAccessedDateLabel;
	IBOutlet UILabel *landscapeNoteCountLabel;
	IBOutlet NotesViewController *notesViewController;
	ContainerViewController *rootViewController;
	
	NSString *pendingNoteImport;
	BOOL showAlertCalled;
	
	NetworkStatusChangeNotifier *networkStatusChangeNotifier;
	
	Facebook *facebook;
	SA_OAuthTwitterEngine *twitterEngine;
	BOOL pendingTwitterPostRequest;
	NSString *pendingTweet;
	
	NSString *pendingEmailSubject;
	NSString *pendingEmailBody;
	BOOL pendingEmailBodyIsHTML;
	
	// Notes
	
	NSFetchedResultsController *fetchedResultsController;
	
	UITableView *theTableView;
	UIToolbar *theToolbar;
	UISegmentedControl *sortOrderSegmentedControl;
	NSTimer *searchBarScrollDelayTimer;
	NSTimer *tableViewEditDelayTimer;
	NSIndexPath *pendingDeleteIndexPath;
	BOOL willBeginEditing;
	BOOL searching;
	BOOL isReordering;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UILabel *noteCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastAccessedDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *landscapeNoteCountLabel;
@property (nonatomic, retain) IBOutlet NotesViewController *notesViewController;
@property (nonatomic, assign) ContainerViewController *rootViewController;

@property (nonatomic, assign) NSString *pendingNoteImport;
@property (readwrite) BOOL showAlertCalled;

@property (nonatomic, assign) NetworkStatusChangeNotifier *networkStatusChangeNotifier;

@property (nonatomic, assign) Facebook *facebook;
@property (nonatomic, assign) SA_OAuthTwitterEngine *twitterEngine;
@property (readwrite) BOOL pendingTwitterPostRequest;
@property (nonatomic, assign) NSString *pendingTweet;

@property (nonatomic, assign) NSString *pendingEmailSubject;
@property (nonatomic, assign) NSString *pendingEmailBody;
@property (readwrite) BOOL pendingEmailBodyIsHTML;

// Notes

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, assign) UITableView *theTableView;
@property (nonatomic, assign) UIToolbar *theToolbar;
@property (nonatomic, assign) UISegmentedControl *sortOrderSegmentedControl;
@property (nonatomic, assign) NSTimer *searchBarScrollDelayTimer;
@property (nonatomic, assign) NSTimer *tableViewEditDelayTimer;
@property (nonatomic, assign) NSIndexPath *pendingDeleteIndexPath;
@property (readwrite) BOOL willBeginEditing;
@property (readwrite) BOOL searching;
@property (readwrite) BOOL isReordering;

- (void)showAlertIfApplicable;
- (void)updateLastAccessedDate;
- (void)logLastAccessedDate;
- (void)configureStatusBar;
- (BOOL)handleFileAtURLIfApplicable:(NSURL *)url;
- (void)_deleteFiles;
- (void)importNote:(NSString *)note;
- (NSManagedObject *)createNewNoteWithProperties:(NSDictionary *)properties;
- (void)saveContext;
- (NSString *)titleForNoteWithBody:(NSString *)body;
- (void)removeRatingData;
- (void)openPasscodeSettings;
- (void)showPasscodeResetAlert;

// Core Data
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSString *)applicationLibraryDirectory;
- (NSString *)applicationDataStorageDirectory;
- (NSString *)applicationPersistentStorePath;

// Notes

- (void)editButtonPressed;
- (void)editButtonAction;
- (void)doneButtonPressed;
- (void)doneButtonAction;

- (void)setUpAddButton;
- (void)setUpEditButton;
- (void)setUpDoneButton;
- (void)updateElements:(BOOL)updatingIndexBar;
- (void)updateBadges;
- (void)updateNotesSectionBadge;
- (void)updateAppIconBadgeNumber;
- (void)updateIndexBar;
- (NSArray *)notesArray:(BOOL)starredNotesOnly;
- (NSInteger)totalNumberOfNotes:(BOOL)isStarredObjectCount;
- (void)setEditButtonDefaultTitle:(BOOL)editButtonDefaultTitle;
- (void)createNewNote;
- (void)scrollToSearchBar;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)deleteNoteAtIndexPath:(NSIndexPath *)indexPath;
- (void)setUpFetchedResultsControllerWithCache:(BOOL)cache;
- (void)performFetch;
- (NSArray *)theSortDescriptors;
- (void)abortWithError:(NSError *)error;
- (UITableView *)currentTableView;
- (void)pushNotesDetailViewControllerForNoteAtIndexPath:(NSIndexPath *)indexPath;
- (void)didFinishSearching;
- (void)updateFiltersWithFetchRequest:(NSFetchRequest *)fetchRequest;

// Error Handling
- (void)abortWithError:(NSError *)error;

// Security
- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
- (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;
- (BOOL)updateKeychainValue:(NSString *)updatedValue forIdentifier:(NSString *)identifier;
- (void)deleteKeychainValue:(NSString *)identifier;
- (NSString *)stringForKey:(NSString *)key;

// Social Networking
- (void)displayCannotLaunchAppStoreAlert;
- (void)presentTwitterViewWithMessage:(NSString *)message;
- (void)sendEmail;
- (void)presentMailComposeControllerWithSubject:(NSString *)subject message:(NSString *)message isHTML:(BOOL)isHTML attachedFilePath:(NSString *)attachedFilePath attachedFileMIMEType:(NSString *)attachedFileMIMEType;
- (void)displayCannotSendMailAlert;

@end

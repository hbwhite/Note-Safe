//
//  NotesDetailViewController.h
//  Note Safe
//
//  Created by Harrison White on 7/14/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "FBConnect.h"

@class DualTextFieldAlert;

@interface NotesDetailViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UIPrintInteractionControllerDelegate, GKPeerPickerControllerDelegate, FBDialogDelegate> {
	NSIndexPath *noteIndexPath;
	
	IBOutlet UITextView *contentTextView;
	IBOutlet UIToolbar *theToolbar;
	IBOutlet UIBarButtonItem *showActionSheetButton;
	IBOutlet UIBarButtonItem *trashButton;
	IBOutlet UIButton *starButton;
	IBOutlet UIBarButtonItem *topButton;
	IBOutlet UIBarButtonItem *bottomButton;
	IBOutlet UIBarButtonItem *composeMailButton;
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	NSUndoManager *undoManager;
	NSTimer *autosaveTimer;
	BOOL isNewNote;
	BOOL shouldNotSave;
	DualTextFieldAlert *dualTextFieldAlert;
}

@property (nonatomic, assign) NSIndexPath *noteIndexPath;

@property (nonatomic, retain) IBOutlet UITextView *contentTextView;
@property (nonatomic, retain) IBOutlet UIToolbar *theToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showActionSheetButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, retain) IBOutlet UIButton *starButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *topButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bottomButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeMailButton;
@property (nonatomic, assign) UIBarButtonItem *editButton;
@property (nonatomic, assign) UIBarButtonItem *doneButton;
@property (nonatomic, assign) NSUndoManager *undoManager;
@property (nonatomic, assign) NSTimer *autosaveTimer;
@property (nonatomic) NSInteger index;
@property (readwrite) BOOL isNewNote;
@property (readwrite) BOOL shouldNotSave;
@property (nonatomic, assign) DualTextFieldAlert *dualTextFieldAlert;

- (IBAction)showActionSheetButtonPressed;
- (IBAction)trashButtonPressed;
- (IBAction)starButtonPressed;
- (IBAction)topButtonPressed;
- (IBAction)bottomButtonPressed;
- (void)showScrollButtonHelpAlertIfApplicable;
- (IBAction)composeMailButtonPressed;

- (void)editButtonPressed;
- (void)doneButtonPressed;
- (NSManagedObject *)note;
- (void)presentFindAndReplaceAlert;
- (void)undoFindAndReplace:(NSString *)previousText;
- (void)saveNoteIfApplicable;
- (void)saveNote;
- (void)updateStarButtonTitle;
- (void)deleteNote;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)textViewDidChangeAction;
- (CGRect)defaultTextViewFrame;
- (void)abortWithError:(NSError *)error;

@end

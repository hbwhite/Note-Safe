//
//  NotesDetailViewController.m
//  Note Safe
//
//  Created by Harrison White on 7/14/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "NotesViewController.h"
#import "NotesDetailViewController.h"
#import "Note_SafeAppDelegate.h"
#import "LoginView.h"
#import "DualTextFieldAlert.h"
#import "PrintObjects.h"

#define AUTOSAVE_TIME_PERIOD						30

static NSString *kNewNoteStr						= @"New Note";
static NSString *kSpaceStr							= @" ";
static NSString *kNewlineStr						= @"\n";
static NSString *kNullStr							= @"";

static NSString *kAutocorrectionEnabledKey			= @"Autocorrection Enabled";
static NSString *kAutocapitalizationEnabledKey		= @"Autocapitalization Enabled";
static NSString *kFontNameKey						= @"Font Name";
static NSString *kFontSizeKey						= @"Font Size";
static NSString *kScrollButtonHelpAlertShownKey		= @"Scroll Button Help Alert Shown";

static NSString *kTextColorRedRGBValueKey			= @"Text Color Red RGB Value";
static NSString *kTextColorGreenRGBValueKey			= @"Text Color Green RGB Value";
static NSString *kTextColorBlueRGBValueKey			= @"Text Color Blue RGB Value";

static NSString *kBackgroundColorRedRGBValueKey		= @"Background Color Red RGB Value";
static NSString *kBackgroundColorGreenRGBValueKey	= @"Background Color Green RGB Value";
static NSString *kBackgroundColorBlueRGBValueKey	= @"Background Color Blue RGB Value";

static NSString *kBodyKey							= @"body";
static NSString *kLastModifiedKey					= @"lastModified";
static NSString *kStarredKey						= @"starred";
static NSString *kTitleKey							= @"title";

@implementation NotesDetailViewController

@synthesize noteIndexPath;

@synthesize contentTextView;
@synthesize theToolbar;
@synthesize showActionSheetButton;
@synthesize trashButton;
@synthesize starButton;
@synthesize topButton;
@synthesize bottomButton;
@synthesize composeMailButton;
@synthesize editButton;
@synthesize doneButton;
@synthesize undoManager;
@synthesize autosaveTimer;
@synthesize index;
@synthesize isNewNote;
@synthesize shouldNotSave;
@synthesize dualTextFieldAlert;

- (IBAction)showActionSheetButtonPressed {
	BOOL printingSupported = NO;
	if (NSClassFromString(@"UIPrintInteractionController")) {
		UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
		if (printInteractionController) {
			if ([UIPrintInteractionController isPrintingAvailable]) {
				printingSupported = YES;
			}
		}
	}
	UIActionSheet *actionSheet = nil;
	if (printingSupported) {
		actionSheet = [[UIActionSheet alloc]
					   initWithTitle:nil
					   delegate:self
					   cancelButtonTitle:@"Cancel"
					   destructiveButtonTitle:nil
					   otherButtonTitles:@"Find & Replace", @"Copy Note to Pasteboard", @"Send Note via Bluetooth", @"Print Note", nil];
		actionSheet.tag = 1;
	}
	else {
		actionSheet = [[UIActionSheet alloc]
					   initWithTitle:nil
					   delegate:self
					   cancelButtonTitle:@"Cancel"
					   destructiveButtonTitle:nil
					   otherButtonTitles:@"Find & Replace", @"Copy Note to Pasteboard", @"Send Note via Bluetooth", nil];
		actionSheet.tag = 0;
	}
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}

- (IBAction)trashButtonPressed {
	UIActionSheet *confirmDeleteActionSheet = [[UIActionSheet alloc]
											   initWithTitle:nil
											   delegate:self
											   cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Delete Note"
											   otherButtonTitles:nil];
	confirmDeleteActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	confirmDeleteActionSheet.tag = 2;
	[confirmDeleteActionSheet showInView:self.tabBarController.view];
	[confirmDeleteActionSheet release];
}

- (IBAction)starButtonPressed {
	NSManagedObject *note = [self note];
	if ([[note valueForKey:kStarredKey]isEqual:[NSNumber numberWithBool:YES]]) {
		[note setValue:[NSNumber numberWithBool:NO] forKey:kStarredKey];
	}
	else {
		[note setValue:[NSNumber numberWithBool:YES] forKey:kStarredKey];
	}
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	[delegate saveContext];
	[delegate updateBadges];
	[self updateStarButtonTitle];
}

- (IBAction)topButtonPressed {
	[self showScrollButtonHelpAlertIfApplicable];
	[contentTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)bottomButtonPressed {
	[self showScrollButtonHelpAlertIfApplicable];
	[contentTextView scrollRectToVisible:CGRectMake(0, (contentTextView.contentSize.height - 1), 1, 1) animated:YES];
}

- (void)showScrollButtonHelpAlertIfApplicable {
	if (![[NSUserDefaults standardUserDefaults]boolForKey:kScrollButtonHelpAlertShownKey]) {
		UIAlertView *scrollButtonHelpAlert = [[UIAlertView alloc]
											  initWithTitle:@"Scroll Buttons"
											  message:@"The scroll buttons provide a quick and easy way to scroll to the top or bottom of your notes.\nTo try them out, create a note long enough to scroll through and press the up or down arrow to scroll to the top or bottom."
											  delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		scrollButtonHelpAlert.tag = 3;
		[scrollButtonHelpAlert show];
		[scrollButtonHelpAlert release];
	}
}

- (IBAction)composeMailButtonPressed {
	[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]presentMailComposeControllerWithSubject:self.title message:contentTextView.text isHTML:NO attachedFilePath:nil attachedFileMIMEType:nil];
}

- (void)editButtonPressed {
	[contentTextView becomeFirstResponder];
}

- (void)doneButtonPressed {
	if (isNewNote) {
		isNewNote = NO;
	}
	if ([[[contentTextView.text stringByReplacingOccurrencesOfString:kSpaceStr withString:kNullStr]stringByReplacingOccurrencesOfString:kNewlineStr withString:kNullStr]length] > 0) {
		[self saveNote];
		contentTextView.frame = [self defaultTextViewFrame];
	}
	else {
		[self deleteNote];
	}
	[contentTextView resignFirstResponder];
	self.navigationItem.rightBarButtonItem = editButton;
}

- (NSManagedObject *)note {
	return [[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]fetchedResultsController]objectAtIndexPath:noteIndexPath];
}

- (void)presentFindAndReplaceAlert {
	[undoManager registerUndoWithTarget:self selector:@selector(undoFindAndReplace:) object:contentTextView.text];
	[undoManager setActionName:@"Find & Replace"];
	dualTextFieldAlert = [[DualTextFieldAlert alloc]
						  initWithTitle:@"Find & Replace"
						  message:@"Fields are case sensitive."
						  delegate:self
						  tag:1
						  textFieldPlaceholder:@"Find"
						  textField2Placeholder:@"Replace With"
						  textFieldKeyboardType:UIKeyboardTypeDefault
						  textFieldTextAlignment:UITextAlignmentLeft
						  textFieldAutocapitalizationType:UITextAutocapitalizationTypeNone
						  textFieldAutocorrectionType:UITextAutocorrectionTypeDefault
						  textFieldSecureTextEntry:NO];
}

- (void)undoFindAndReplace:(NSString *)previousText {
	[undoManager registerUndoWithTarget:self selector:@selector(undoFindAndReplace:) object:contentTextView.text];
	contentTextView.text = previousText;
	[self textViewDidChangeAction];
}

- (void)saveNoteIfApplicable {
	if (!shouldNotSave) {
		if ([[[contentTextView.text stringByReplacingOccurrencesOfString:kSpaceStr withString:kNullStr]stringByReplacingOccurrencesOfString:kNewlineStr withString:kNullStr]length] > 0) {
			[self saveNote];
		}
	}
}

- (void)saveNote {
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *body = contentTextView.text;
	NSManagedObject *note = [self note];
	[note setValue:[delegate titleForNoteWithBody:body] forKey:kTitleKey];
	[note setValue:body forKey:kBodyKey];
	[note setValue:[NSDate date] forKey:kLastModifiedKey];
	[delegate saveContext];
	noteIndexPath = [[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]fetchedResultsController]indexPathForObject:note]retain];
}

- (void)updateStarButtonTitle {
	if ([[[self note]valueForKey:kStarredKey]isEqual:[NSNumber numberWithBool:YES]]) {
		[starButton setTitle:@"★" forState:UIControlStateNormal];
	}
	else {
		[starButton setTitle:@"☆" forState:UIControlStateNormal];
	}
}

- (void)deleteNote {
	if (autosaveTimer) {
		[autosaveTimer invalidate];
		autosaveTimer = nil;
	}
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	[delegate deleteNoteAtIndexPath:noteIndexPath];
	shouldNotSave = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto:"]];
		}
	}
	else if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			if ([dualTextFieldAlert.textField1.text length] > 0) {
				NSString *replacementText = nil;
				NSString *originalReplacementText = dualTextFieldAlert.textField2.text;
				if ([originalReplacementText length] > 0) {
					replacementText = originalReplacementText;
				}
				else {
					replacementText = kNullStr;
				}
				contentTextView.text = [contentTextView.text stringByReplacingOccurrencesOfString:dualTextFieldAlert.textField1.text withString:replacementText];
				[self textViewDidChangeAction];
			}
			else {
				UIAlertView *findFieldCannotBeEmptyAlert = [[UIAlertView alloc]
															initWithTitle:@"Find Field Empty"
															message:@"The \"Find\" field cannot be empty."
															delegate:self
															cancelButtonTitle:@"Cancel"
															otherButtonTitles:@"Retry", nil];
				findFieldCannotBeEmptyAlert.tag = 2;
				[findFieldCannotBeEmptyAlert show];
				[findFieldCannotBeEmptyAlert release];
			}
		}
		[dualTextFieldAlert.textFieldAlert setHidden:YES];
		if ([dualTextFieldAlert.textField1 isFirstResponder]) {
			[dualTextFieldAlert.textField1 resignFirstResponder];
		}
		if ([dualTextFieldAlert.textField2 isFirstResponder]) { 
			[dualTextFieldAlert.textField2 resignFirstResponder];
		}
		[dualTextFieldAlert release];
	}
	else if (alertView.tag == 2) {
		if (buttonIndex == 1) {
			[self presentFindAndReplaceAlert];
		}
	}
	else if (alertView.tag == 3) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:kScrollButtonHelpAlertShownKey];
		[defaults synchronize];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((actionSheet.tag == 0) || (actionSheet.tag == 1)) {
		if (buttonIndex == 0) {
			[self presentFindAndReplaceAlert];
		}
		else if (buttonIndex == 1) {
			[[UIPasteboard generalPasteboard]setString:contentTextView.text];
			UIAlertView *noteCopiedToPasteboardAlert = [[UIAlertView alloc]
														initWithTitle:@"Note Copied to Pasteboard"
														message:@"This note was successfully copied to the pasteboard."
														delegate:nil
														cancelButtonTitle:@"OK"
														otherButtonTitles:nil];
			[noteCopiedToPasteboardAlert show];
			[noteCopiedToPasteboardAlert release];
		}
		else if (buttonIndex == 2) {
			GKPeerPickerController *controller = [[GKPeerPickerController alloc]init];
			controller.delegate = self;
			controller.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
			[controller show];
		}
		else if (buttonIndex == 3) {
			if (actionSheet.tag == 1) {
				UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
				printInteractionController.delegate = self;
				printInteractionController.showsPageRange = YES;
				
				UIPrintInfo *printInfo = [UIPrintInfo printInfo];
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				printInfo.outputType = UIPrintInfoOutputGeneral;
				if ([defaults integerForKey:kPrintOrientationKey] == PRINT_ORIENTATION_PORTRAIT_INDEX) {
					printInfo.orientation = UIPrintInfoOrientationPortrait;
				}
				else {
					printInfo.orientation = UIPrintInfoOrientationLandscape;
				}
				printInfo.jobName = self.title;
				NSInteger printDuplexSetting = [defaults integerForKey:kPrintDuplexKey];
				if (printDuplexSetting == PRINT_DUPLEX_NONE_INDEX) {
					printInfo.duplex = UIPrintInfoDuplexNone;
				}
				else if (printDuplexSetting == PRINT_DUPLEX_SHORT_EDGE_INDEX) {
					printInfo.duplex = UIPrintInfoDuplexShortEdge;
				}
				else {
					printInfo.duplex = UIPrintInfoDuplexLongEdge;
				}
				printInteractionController.printInfo = printInfo;
				
				UIPrintPageRenderer *printPageRenderer = [[UIPrintPageRenderer alloc]init];
				
				UISimpleTextPrintFormatter *simpleTextPrintFormatter = [[UISimpleTextPrintFormatter alloc]initWithText:contentTextView.text];
				simpleTextPrintFormatter.color = [UIColor colorWithRed:[defaults floatForKey:kPrintedTextColorRedRGBValueKey] green:[defaults floatForKey:kPrintedTextColorGreenRGBValueKey] blue:[defaults floatForKey:kPrintedTextColorBlueRGBValueKey] alpha:1];
				simpleTextPrintFormatter.contentInsets = UIEdgeInsetsMake([defaults floatForKey:kTopPrintMarginSizeKey], [defaults floatForKey:kLeftPrintMarginSizeKey], 0, [defaults floatForKey:kRightPrintMarginSizeKey]);
				simpleTextPrintFormatter.font = [UIFont fontWithName:[defaults objectForKey:kPrintedFontNameKey] size:[defaults integerForKey:kPrintedFontSizeKey]];
				simpleTextPrintFormatter.startPage = 0;
				NSInteger printTextAlignmentSetting = [defaults integerForKey:kPrintTextAlignmentKey];
				if (printTextAlignmentSetting == PRINT_TEXT_ALIGNMENT_LEFT_INDEX) {
					simpleTextPrintFormatter.textAlignment = UITextAlignmentLeft;
				}
				else if (printTextAlignmentSetting == PRINT_TEXT_ALIGNMENT_CENTER_INDEX) {
					simpleTextPrintFormatter.textAlignment = UITextAlignmentCenter;
				}
				else {
					simpleTextPrintFormatter.textAlignment = UITextAlignmentRight;
				}
				
				[printPageRenderer addPrintFormatter:simpleTextPrintFormatter startingAtPageAtIndex:0];
				
				[simpleTextPrintFormatter release];
				
				[printInteractionController setPrintPageRenderer:printPageRenderer];
				
				[printPageRenderer release];
				
				void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
					if ((!completed) && (error)) {
						UIAlertView *errorAlert = [[UIAlertView alloc]
												   initWithTitle:@"Print Error"
												   message:[NSString stringWithFormat:@"The print job failed due to an error in the domain: %@\n\nError code: %u", [error domain], [error code]]
												   delegate:nil
												   cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
						[errorAlert show];
						[errorAlert release];
					}
				};
				
				[printInteractionController presentFromRect:CGRectMake(0, 0, 320, 460) inView:[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]view] animated:YES completionHandler:completionHandler];
			}
		}
	}
	else if (actionSheet.tag == 2) {
		if (buttonIndex == 0) {
			[self deleteNote];
		}
	}
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem = doneButton;
	return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {
	CGRect keyboardFrame;
	[[[notification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey]getValue:&keyboardFrame];
	CGRect frame = CGRectZero;
	if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
		frame.size = CGSizeMake(keyboardFrame.size.width, ((self.view.frame.size.height - (keyboardFrame.size.height - self.tabBarController.tabBar.frame.size.height)) - 10));
	}
	else {
		frame.size = CGSizeMake(keyboardFrame.size.height, ((self.view.frame.size.height - (keyboardFrame.size.width - self.tabBarController.tabBar.frame.size.height)) - 10));
	}
	contentTextView.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)notification {
	contentTextView.frame = [self defaultTextViewFrame];
}

- (void)textViewDidChange:(UITextView *)textView {
	[self textViewDidChangeAction];
}

- (void)textViewDidChangeAction {
	NSMutableString *revisedText = [NSMutableString stringWithString:contentTextView.text];
	if ([revisedText length] > 0) {
		BOOL isValidTitle = YES;
		while (([[revisedText substringToIndex:1]isEqualToString:kSpaceStr]) || ([[revisedText substringToIndex:1]isEqualToString:kNewlineStr])) {
			if ([revisedText length] > 1) {
				[revisedText setString:[revisedText substringFromIndex:1]];
			}
			else {
				isValidTitle = NO;
				if (isNewNote) {
					self.title = kNewNoteStr;
				}
				else {
					self.title = kNullStr;
				}
				break;
			}
		}
		if (isValidTitle) {
			if ([[revisedText componentsSeparatedByString:kNewlineStr]count] > 1) {
				self.title = [[revisedText componentsSeparatedByString:kNewlineStr]objectAtIndex:0];
			}
			else {
				self.title = revisedText;
			}
		}
	}
	else {
		if (isNewNote) {
			self.title = kNewNoteStr;
		}
		else {
			self.title = kNullStr;
		}
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem = editButton;
	return YES;
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
	GKSession *session = [[[GKSession alloc]initWithSessionID:@"com.harrisonapps.Note-Safe" displayName:nil sessionMode:GKSessionModePeer]autorelease];
	return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	NSError *error = nil;
	[session sendData:[contentTextView.text dataUsingEncoding:NSASCIIStringEncoding] toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:&error];
	if (error) {
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:@"Error"
								   message:[NSString stringWithFormat:@"An error occurred while sending your note to the device \"%@\". Please make sure your devices are within range of each other and try again.", [session displayNameForPeer:peerID]]
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	else {
		UIAlertView *noteSentAlert = [[UIAlertView alloc]
									  initWithTitle:@"Note Successfully Sent"
									  message:[NSString stringWithFormat:@"This note has been successfully sent to the device \"%@\".", [session displayNameForPeer:peerID]]
									  delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
		[noteSentAlert show];
		[noteSentAlert release];
	}
	
	picker.delegate = nil;
	[picker dismiss];
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

- (BOOL)canBecomeFirstResponder {
	return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
	self.navigationItem.rightBarButtonItem = editButton;
	doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	undoManager = [[NSUndoManager alloc]init];
	undoManager.levelsOfUndo = 5;
	[super viewDidLoad];
}

- (CGRect)defaultTextViewFrame {
	CGRect frame = self.view.frame;
	frame.size.height -= theToolbar.frame.size.height;
	return frame;
}

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	contentTextView.textColor = [UIColor colorWithRed:[defaults floatForKey:kTextColorRedRGBValueKey]
												green:[defaults floatForKey:kTextColorGreenRGBValueKey]
												 blue:[defaults floatForKey:kTextColorBlueRGBValueKey]
												alpha:1];
	self.view.backgroundColor = [UIColor colorWithRed:[defaults floatForKey:kBackgroundColorRedRGBValueKey]
												green:[defaults floatForKey:kBackgroundColorGreenRGBValueKey]
												 blue:[defaults floatForKey:kBackgroundColorBlueRGBValueKey]
												alpha:1];
	contentTextView.font = [UIFont fontWithName:[defaults objectForKey:kFontNameKey] size:[defaults integerForKey:kFontSizeKey]];
	if ([defaults boolForKey:kAutocorrectionEnabledKey]) {
		contentTextView.autocorrectionType = UITextAutocorrectionTypeYes;
	}
	else {
		contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	}
	if ([defaults boolForKey:kAutocapitalizationEnabledKey]) {
		contentTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	}
	else {
		contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	}
	[self updateStarButtonTitle];
	[theToolbar setUserInteractionEnabled:YES];
	if (isNewNote) {
		[contentTextView becomeFirstResponder];
	}
	else {
		contentTextView.text = [[self note]valueForKey:kBodyKey];
		[self textViewDidChangeAction];
	}
	if (autosaveTimer) {
		[autosaveTimer invalidate];
		autosaveTimer = nil;
	}
	autosaveTimer = [NSTimer scheduledTimerWithTimeInterval:AUTOSAVE_TIME_PERIOD target:self selector:@selector(saveNoteIfApplicable) userInfo:nil repeats:YES];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[theToolbar setUserInteractionEnabled:NO];
	if (shouldNotSave) {
		shouldNotSave = NO;
	}
	else {
		if (autosaveTimer) {
			[autosaveTimer invalidate];
			autosaveTimer = nil;
		}
		if ([[[contentTextView.text stringByReplacingOccurrencesOfString:kSpaceStr withString:kNullStr]stringByReplacingOccurrencesOfString:kNewlineStr withString:kNullStr]length] > 0) {
			if (!shouldNotSave) {
				[self saveNote];
			}
		}
		else {
			[self deleteNote];
		}
		contentTextView.frame = [self defaultTextViewFrame];
	}
	[contentTextView resignFirstResponder];
	[super viewWillDisappear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	CGSize boundsSize = self.view.bounds.size;
	CGFloat height = [theToolbar sizeThatFits:boundsSize].height;
	theToolbar.frame = CGRectMake(0, (boundsSize.height - height), boundsSize.width, height);
	contentTextView.frame = CGRectMake(0, 0, boundsSize.width, (boundsSize.height - height));
    return YES;
}


- (void)abortWithError:(NSError *)error {
	// Replace this implementation with code to handle the error appropriately.
	// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	abort();
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
	
	self.noteIndexPath = nil;
	
	self.contentTextView = nil;
	self.theToolbar = nil;
	self.showActionSheetButton = nil;
	self.trashButton = nil;
	self.starButton = nil;
	self.topButton = nil;
	self.bottomButton = nil;
	self.editButton = nil;
	self.doneButton = nil;
	self.undoManager = nil;
}


- (void)dealloc {
	[noteIndexPath release];
	
	[contentTextView release];
	[theToolbar release];
	[showActionSheetButton release];
	[trashButton release];
	[starButton release];
	[topButton release];
	[bottomButton release];
	[editButton release];
	[doneButton release];
	[undoManager release];
    [super dealloc];
}


@end

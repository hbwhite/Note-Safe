//
//  USBFileTransferViewController.m
//  Note Safe
//
//  Created by Harrison White on 8/1/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "USBFileTransferViewController.h"
#import "Note_SafeAppDelegate.h"
#import "HUDView.h"

static NSString *kBodyKey				= @"body";
static NSString *kCustomIndexKey		= @"customIndex";
static NSString *kLastModifiedKey		= @"lastModified";
static NSString *kStarredKey			= @"starred";
static NSString *kTitleKey				= @"title";

static NSString *kHiddenFilePrefixStr	= @".";
static NSString *kPathExtensionStr		= @"txt";

@implementation USBFileTransferViewController

@synthesize theTableView;
@synthesize searchStatusNavigationBar;
@synthesize searchStatusToolbar;
@synthesize activityIndicatorView;
@synthesize filesArray;
@synthesize originalFilesArray;
@synthesize refreshTimer;
@synthesize section;
@synthesize index;
@synthesize currentItem;
@synthesize isImporting;
@synthesize indexIsRelevant;
@synthesize hudView;

#pragma mark -
#pragma mark View lifecycle

- (void)importButtonPressed {
	[self refreshList];
	if ([filesArray count] > 0) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
		if (refreshTimer) {
			[refreshTimer invalidate];
			refreshTimer = nil;
		}
		[self refreshList];
		[originalFilesArray setArray:filesArray];
		
		[self performSelectorInBackground:@selector(_showHUD) withObject:nil];
		
		searchStatusNavigationBar.topItem.title = @"Please Wait...";
		
		[self importNotes];
	}
	else {
		UIAlertView *noFilesFoundAlert = [[UIAlertView alloc]
										  initWithTitle:@"No Files Found"
										  message:@"No files were found. If you need help, please follow the instructions on the import screen."
										  delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
		[noFilesFoundAlert show];
		[noFilesFoundAlert release];
	}
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)filePathForNoteWithTitle:(NSString *)title copyNumber:(NSInteger)copyNumber {
	NSString *fileName = nil;
	if (copyNumber > 1) {
		fileName = [title stringByAppendingFormat:@" (%i)", copyNumber];
	}
	else {
		fileName = title;
	}
	return [[[self applicationDocumentsDirectory]stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:kPathExtensionStr];
}

- (void)setUpRefreshTimer {
	[self refreshList];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshList) userInfo:nil repeats:YES];
}

- (void)_showHUD {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	hudView = [[HUDView alloc]initWithFrame:CGRectMake(35, 96, 250, 175)];
	hudView.hudLabel.text = [isImporting ? @"Importing Files" : @"Exporting Notes" stringByAppendingString:@"..."];
	[self _updateElements];
	
	UIView *view = [[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]view];
	CGPoint center = view.center;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
		NSInteger x = center.x;
		center.x = center.y;
		center.y = x;
	}
	center.y -= (self.navigationController.navigationBar.frame.size.height / 2.0);
	hudView.center = center;
	[view addSubview:hudView];
	
	[pool release];
}

- (void)fadeOutHUD {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	[UIView beginAnimations:@"Fade Out HUD" context:nil];
	[UIView setAnimationDuration:0.5];
	hudView.alpha = 0;
	[UIView commitAnimations];
	[hudView release];
	
	[pool release];
}

- (void)_updateElements {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSInteger importIndex = currentItem;
	NSInteger totalCount = [originalFilesArray count];
	if (importIndex < totalCount) {
		importIndex += 1;
	}
	hudView.hudSubscript.text = [isImporting ? @"Importing Item" : @"Exporting Note" stringByAppendingFormat:@" %i of %i", importIndex, totalCount];
	hudView.hudProgressView.progress = ((CGFloat)currentItem / (CGFloat)totalCount);
	if (isImporting) {
		[self refreshList];
	}
	
	[pool release];
}

- (void)refreshList {
	NSMutableArray *updatedFilesArray = [NSMutableArray arrayWithObjects:nil];
	for (NSString *file in [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil]) {
		if (![[file substringToIndex:1]isEqualToString:kHiddenFilePrefixStr]) {
			[updatedFilesArray addObject:file];
		}
	}
	if (![filesArray isEqualToArray:updatedFilesArray]) {
		[filesArray setArray:updatedFilesArray];
		[theTableView reloadData];
	}
}

- (void)importNotes {
	for (currentItem = 0; currentItem < [originalFilesArray count]; currentItem += 1) {
		[self performSelectorInBackground:@selector(_updateElements) withObject:nil];
		
		NSString *file = [originalFilesArray objectAtIndex:currentItem];
		if (![[file substringToIndex:1]isEqualToString:kHiddenFilePrefixStr]) {
			[self importNoteAtPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:file]];
		}
	}
	[self performSelectorInBackground:@selector(fadeOutHUD) withObject:nil];
	
	[self setUpRefreshTimer];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[[UIApplication sharedApplication]endIgnoringInteractionEvents];
	searchStatusNavigationBar.topItem.title = @"Looking for Files...";
	
	UIAlertView *notesImportedAlert = [[UIAlertView alloc]
									   initWithTitle:@"Notes Successfully Imported"
									   message:@"All notes were successfully imported. You can find them in the Notes section of the app."
									   delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[notesImportedAlert show];
	[notesImportedAlert release];
}

- (void)importNoteAtPath:(NSString *)path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	BOOL isDirectory = NO;
	[[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDirectory];
	if (isDirectory) {
		for (NSString *contentFile in [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:nil]) {
			if (![[contentFile substringToIndex:1]isEqualToString:kHiddenFilePrefixStr]) {
				[self importNoteAtPath:[path stringByAppendingPathComponent:contentFile]];
			}
		}
	}
	else {
		NSStringEncoding stringEncoding = NSUTF8StringEncoding;
		[NSString stringWithContentsOfFile:path usedEncoding:&stringEncoding error:nil];
		NSString *noteBody = [NSString stringWithContentsOfFile:path encoding:stringEncoding error:nil];
		if (noteBody) {
			if ([noteBody length] > 0) {
				Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
				[delegate createNewNoteWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:[delegate titleForNoteWithBody:noteBody], kTitleKey, noteBody, kBodyKey, [NSNumber numberWithInteger:[delegate totalNumberOfNotes:NO]], kCustomIndexKey, [NSDate date], kLastModifiedKey, [NSNumber numberWithBool:NO], kStarredKey, nil]];
			}
		}
	}
	[[NSFileManager defaultManager]removeItemAtPath:path error:nil];
	
	[pool release];
}

- (void)_deleteFiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
	for (NSString *file in [fileManager contentsOfDirectoryAtPath:applicationDocumentsDirectory error:nil]) {
		[fileManager removeItemAtPath:[applicationDocumentsDirectory stringByAppendingPathComponent:file] error:nil];
	}
	
	[pool release];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	filesArray = [[NSMutableArray alloc]init];
	originalFilesArray = [[NSMutableArray alloc]init];
	
	if (isImporting) {
		UIBarButtonItem *importButton = [[UIBarButtonItem alloc]initWithTitle:@"Import" style:UIBarButtonItemStyleDone target:self action:@selector(importButtonPressed)];
		self.navigationItem.rightBarButtonItem = importButton;
		[importButton release];
		
		[self setUpRefreshTimer];
	}
	else {
		theTableView.frame = CGRectMake(0, 0, 320, 367);
		[searchStatusNavigationBar removeFromSuperview];
		[searchStatusToolbar removeFromSuperview];
		[activityIndicatorView removeFromSuperview];
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
	if (!isImporting) {
		[originalFilesArray setArray:[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]notesArray:NO]];
		NSInteger noteCount = [originalFilesArray count];
		if (noteCount > 0) {
			[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
			
			[self performSelectorInBackground:@selector(_showHUD) withObject:nil];
			
			for (currentItem = 0; currentItem < noteCount; currentItem += 1) {
				[self performSelectorInBackground:@selector(_updateElements) withObject:nil];
				
				NSManagedObject *note = [originalFilesArray objectAtIndex:currentItem];
				NSString *noteTitle = [note valueForKey:kTitleKey];
				NSString *noteBody = [note valueForKey:kBodyKey];
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSString *originalFilePath = [self filePathForNoteWithTitle:noteTitle copyNumber:1];
				if ([fileManager fileExistsAtPath:originalFilePath]) {
					NSInteger copyNumber = 2;
					while ([fileManager fileExistsAtPath:[self filePathForNoteWithTitle:noteTitle copyNumber:copyNumber]]) {
						copyNumber += 1;
					}
					[noteTitle writeToFile:[self filePathForNoteWithTitle:noteTitle copyNumber:copyNumber] atomically:YES encoding:NSUTF8StringEncoding error:nil];
				}
				else {
					[noteBody writeToFile:originalFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
				}
			}
			
			[self performSelectorInBackground:@selector(fadeOutHUD) withObject:nil];
			
			[[UIApplication sharedApplication]endIgnoringInteractionEvents];
		}
	}
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
	[self performSelectorInBackground:@selector(_deleteFiles) withObject:nil];
	[self.navigationController popViewControllerAnimated:NO];
    [super viewDidDisappear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (isImporting) {
		CGSize boundsSize = self.view.bounds.size;
		CGFloat height = [searchStatusToolbar sizeThatFits:boundsSize].height;
		searchStatusNavigationBar.frame = CGRectMake(theTableView.frame.origin.x, (boundsSize.height - height), boundsSize.width, height);
		searchStatusToolbar.frame = CGRectMake(theTableView.frame.origin.x, (boundsSize.height - height - 1), boundsSize.width, height);
		theTableView.frame = CGRectMake(theTableView.frame.origin.x, theTableView.frame.origin.y, boundsSize.width, (boundsSize.height - height));
	}
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [filesArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSInteger fileCount = [filesArray count];
	if (fileCount > 0) {
		return [NSString stringWithFormat:@"%i Item%@ Found:", fileCount, (fileCount == 1) ? @"" : @"s"];
	}
	else {
		return [NSString stringWithFormat:@"To %@ notes, follow the steps below. For your security, you will only be able to %@ notes while this screen is displayed.%@\n\nStep 1: Open iTunes on your computer. If you do not have the latest version of iTunes installed, you can download it by opening your Internet browser and going to www.itunes.com/download\n\nStep 2: Connect this device to your computer.\n\nStep 3: In iTunes, wait for this device to appear in the menu on the left. When it appears, click on it to select it. This device should show up as \"%@\".\n\nStep 4: There should now be several tabs located near the top of the iTunes window. Click on the \"Apps\" tab.\n\nStep 5: Scroll down until you see the \"File Sharing\" section. Under this you should see two boxes. The \"Note Safe\" app should be listed in the \"Apps\" box on the left (if you don't see it you may have to scroll up or down). Click on it to select it.\n\nStep 6: %@ When you're done, press the %@ button %@", isImporting ? @"import" : @"export", isImporting ? @"import" : @"export", isImporting ? @"\n\nThe notes you are importing should be written in plain text. If you need help with this, please press the back button in the upper left hand corner of the screen and select \"USB Import Help\" from the Settings menu." : @"", [[UIDevice currentDevice]name], isImporting ? @"You may now drag the notes you would like to import into the \"Documents\" box on the right. You can also use the \"Add...\" button under this box to add notes." : @"You should see your notes in the \"Documents\" box on the right. You may drag these notes to a location on your computer (such as your desktop) and open them to view their contents. You can also use the \"Save to...\" button under the \"Documents\" box to save notes to a specific location. Deleting notes in the \"Documents\" box will not delete any notes stored in this app.", isImporting ? @"\"Import\"" : @"back", isImporting ? @"in the upper right hand corner of the screen to import the notes." : @"in the upper left hand corner of the screen."];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	cell.textLabel.text = [filesArray objectAtIndex:indexPath.row];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.searchStatusNavigationBar = nil;
	self.searchStatusToolbar = nil;
	self.activityIndicatorView = nil;
	self.filesArray = nil;
	self.originalFilesArray = nil;
}


- (void)dealloc {
	[searchStatusNavigationBar release];
	[searchStatusToolbar release];
	[activityIndicatorView release];
	[filesArray release];
	[originalFilesArray release];
    [super dealloc];
}


@end


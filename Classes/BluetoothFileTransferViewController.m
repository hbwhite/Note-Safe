//
//  BluetoothFileTransferViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/15/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "BluetoothFileTransferViewController.h"
#import "Note_SafeAppDelegate.h"

static NSString *kBodyKey			= @"body";
static NSString *kCustomIndexKey	= @"customIndex";
static NSString *kLastModifiedKey	= @"lastModified";
static NSString *kStarredKey		= @"starred";
static NSString *kTitleKey			= @"title";

@implementation BluetoothFileTransferViewController

@synthesize pendingNoteImport;
@synthesize isImporting;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	pendingNoteImport = [[NSMutableString alloc]init];
	if (isImporting) {
		/*
		UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicatorView.frame = CGRectMake(265, 168, 20, 20);
		[activityIndicatorView startAnimating];
		[self.view addSubview:activityIndicatorView];
		[activityIndicatorView release];
		*/
		
		GKPeerPickerController *controller = [[GKPeerPickerController alloc]init];
		controller.delegate = self;
		controller.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
		[controller show];
	}
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
	GKSession *session = [[[GKSession alloc]initWithSessionID:@"com.harrisonapps.Note-Safe" displayName:nil sessionMode:GKSessionModePeer]autorelease];
	return session;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	session.delegate = self;
	[session setDataReceiveHandler:self withContext:nil];
	picker.delegate = nil;
	[picker dismiss];
	[picker autorelease];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	NSString *note = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
	
	[pendingNoteImport setString:note];
	UIAlertView *importAlert = [[UIAlertView alloc]
								initWithTitle:@"Import Note"
								message:[@"Would you like to import the following note?\n\n" stringByAppendingString:note]
								delegate:self
								cancelButtonTitle:@"Cancel"
								otherButtonTitles:@"Import", nil];
	[importAlert show];
	[importAlert release];
	
	[note release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
		[delegate createNewNoteWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:[delegate titleForNoteWithBody:pendingNoteImport], kTitleKey, pendingNoteImport, kBodyKey, [NSNumber numberWithInteger:[delegate totalNumberOfNotes:NO]], kCustomIndexKey, [NSDate date], kLastModifiedKey, [NSNumber numberWithBool:NO], kStarredKey, nil]];
		UIAlertView *importSuccessfulAlert = [[UIAlertView alloc]
											  initWithTitle:@"Import Successful"
											  message:@"You have successfully imported this note."
											  delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[importSuccessfulAlert show];
		[importSuccessfulAlert release];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (isImporting) {
		return nil;
	}
	else {
		return @"To export notes via Bluetooth, follow the steps below. In order to transfer notes via Bluetooth, you must have this app installed on two devices. For your security, you will only be able to export notes via Bluetooth while this screen is displayed.\n\nStep 1: Switch to the Notes section of this app and select a note that you would like to export via Bluetooth.\n\nStep 2: Press the action button in the lower left hand corner of the note. A menu will appear.\n\nStep 3: Finally, press the \"Send Note via Bluetooth\" button. The app will display a list of devices within range. Select the device that you would like to transfer the note to.\n\nStep 4: When the transfer is complete, the user of the other device will be asked if they would like to import the note.";
	}
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (isImporting) {
		return @"\n\n\n\n\n\n\n\nWaiting for note imports...";
	}
	else {
		return nil;
	}
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	
	self.pendingNoteImport = nil;
}


- (void)dealloc {
	[pendingNoteImport release];
    [super dealloc];
}


@end


//
//  SettingsViewController.m
//  Note Safe
//
//  Created by Harrison White on 10/22/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "Note_SafeAppDelegate.h"

#import "GeneralSettingsViewController.h"

#import "PasscodeSettingsViewController.h"
#import "ForgotPasscodeSettingsViewController.h"

#import "USBFileTransferViewController.h"
#import "USBImportHelpViewController.h"
#import "BluetoothFileTransferViewController.h"
#import "ZipArchive.h"
#import "SecureNoteImportSettingsViewController.h"
#import "PrintingOptionsViewController.h"
#import "MoreViewController.h"

#import "HUDView.h"

static NSString *kBodyKey				= @"body";
static NSString *kTitleKey				= @"title";

static NSString *kHiddenFilePrefixStr	= @".";
static NSString *kPathExtensionStr		= @"txt";

static NSString *kPasscodeKey			= @"Passcode";
static NSString *kSimplePasscodeKey		= @"Simple Passcode";

@implementation SettingsViewController

@synthesize isAccessingPasscodeSettings;
@synthesize originalFilesArray;
@synthesize currentItem;
@synthesize hudView;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	originalFilesArray = [[NSMutableArray alloc]init];
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
    return 9;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 2;
			break;
		case 3:
			return 1;
			break;
		case 4:
			return 2;
			break;
		case 5:
			return 1;
			break;
		case 6:
			return 1;
			break;
		case 7:
			return 1;
			break;
		case 8:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"General";
			break;
		case 1:
			return @"Security";
			break;
		case 2:
			if ([[[UIDevice currentDevice]systemVersion]compare:@"4.0"] == NSOrderedAscending) {
				return @"USB File Transfer (Not Supported)";
			}
			else {
				return @"USB File Transfer";
			}
			break;
		case 4:
		{
			NSString *model = [[UIDevice currentDevice]model];
			if (([model isEqualToString:@"iPhone1,1"]) || ([model isEqualToString:@"iPod1,1"])) {
				return @"Bluetooth File Transfer (Not Supported)";
			}
			else {
				return @"Bluetooth File Transfer";
			}
		}
			break;
		case 5:
			return @"Email Export";
			break;
		case 6:
			return @"Secure Note Importing";
			break;
		case 7:
		{
			NSString *model = [[UIDevice currentDevice]model];
			if (([model isEqualToString:@"iPhone1,1"]) &&
				([model isEqualToString:@"iPod1,1"]) &&
				([model isEqualToString:@"iPhone1,2"]) &&
				([model isEqualToString:@"iPod2,1"])) {
				return @"Wireless Printing (Not Supported)";
			}
			else {
				return @"AirPrint Wireless Printing";
			}
		}
			break;
		default:
			return nil;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 4) {
		NSString *model = [[UIDevice currentDevice]model];
		if (([model isEqualToString:@"iPhone1,1"]) || ([model isEqualToString:@"iPod1,1"])) {
			return @"First generation devices do not support Bluetooth.";
		}
	}
	else if (section == 6) {
		UIDevice *device = [UIDevice currentDevice];
		NSString *model = device.model;
		if ([device.systemVersion compare:@"4.0"] == NSOrderedAscending) {
			if (([model isEqualToString:@"iPhone1,1"]) || ([model isEqualToString:@"iPod1,1"])) {
				return @"First generation devices do not support iTunes File Sharing.";
			}
			else {
				return @"This feature requires iOS 4.0 or later. Please update your device's firmware.";
			}
		}
	}
	else if (section == 7) {
		UIDevice *device = [UIDevice currentDevice];
		NSString *model = device.model;
		if ((![model isEqualToString:@"iPhone1,1"]) &&
			(![model isEqualToString:@"iPod1,1"]) &&
			(![model isEqualToString:@"iPhone1,2"]) &&
			(![model isEqualToString:@"iPod2,1"])) {
			if ([device.systemVersion compare:@"4.2"] != NSOrderedAscending) {
				if (NSClassFromString(@"UIPrintInteractionController")) {
					UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
					if (printInteractionController) {
						if ([UIPrintInteractionController isPrintingAvailable]) {
							return nil;
						}
					}
				}
				return @"This device does not support AirPrint wireless printing.";
			}
			return @"AirPrint wireless printing requires iOS 4.2 or later. Please update your device's firmware.";
		}
		return @"AirPrint wireless printing is not supported by first and second generation devices.";
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    /* static */ NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %i", (indexPath.section + 1)];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	switch (indexPath.section) {
		case 0:
			cell.textLabel.text = @"General Settings";
			cell.imageView.image = [UIImage imageNamed:@"General_Settings"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"General_Settings-Selected"];
			break;
		case 1:
		{
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Passcode Lock";
				cell.imageView.image = [UIImage imageNamed:@"Passcode"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"Passcode-Selected"];
			}
			else {
				cell.textLabel.text = @"Forgot Passcode Settings";
				cell.imageView.image = [UIImage imageNamed:@"Forgot_Passcode"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"Forgot_Passcode-Selected"];
			}
		}
			break;
		case 2:
		{
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Import Notes via USB";
				cell.imageView.image = [UIImage imageNamed:@"USB_Import"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"USB_Import-Selected"];
			}
			else {
				cell.textLabel.text = @"USB Import Help";
				cell.imageView.image = [UIImage imageNamed:@"Help"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"Help-Selected"];
			}
			[self modifyCell:cell setEnabled:([[[UIDevice currentDevice]systemVersion]compare:@"4.0"] != NSOrderedAscending)];
		}
			break;
		case 3:
			cell.textLabel.text = @"Export Notes via USB";
			cell.imageView.image = [UIImage imageNamed:@"USB_Export"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"USB_Export-Selected"];
			break;
		case 4:
		{
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Import Notes via Bluetooth";
				cell.imageView.image = [UIImage imageNamed:@"Bluetooth_Import"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"Bluetooth_Import-Selected"];
			}
			else {
				cell.textLabel.text = @"Export Notes via Bluetooth";
				cell.imageView.image = [UIImage imageNamed:@"Bluetooth_Export"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"Bluetooth_Export-Selected"];
			}
			[self modifyCell:cell setEnabled:!(([[[UIDevice currentDevice]model]isEqualToString:@"iPhone1,1"]) || ([[[UIDevice currentDevice]model]isEqualToString:@"iPod1,1"]))];
		}
			break;
		case 5:
			cell.textLabel.text = @"Export All Notes via Email";
			cell.imageView.image = [UIImage imageNamed:@"Email"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"Email-Selected"];
			break;
		case 6:
			cell.textLabel.numberOfLines = 2;
			cell.textLabel.text = @"Secure Note\nImport Settings";
			cell.imageView.image = [UIImage imageNamed:@"Import"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"Import-Selected"];
			break;
		case 7:
			cell.textLabel.text = @"Printing Options";
			cell.imageView.image = [UIImage imageNamed:@"Printing_Options"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"Printing_Options-Selected"];
			[self modifyCell:cell setEnabled:[self isWirelessPrintingSupported]];
			break;
		case 8:
			cell.textLabel.text = @"More...";
			break;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)modifyCell:(UITableViewCell *)cell setEnabled:(BOOL)enabled {
	if (enabled) {
		cell.textLabel.textColor = [UIColor blackColor];
		[cell setUserInteractionEnabled:YES];
	}
	else {
		cell.textLabel.textColor = [UIColor grayColor];
		[cell setUserInteractionEnabled:NO];
	}
}

- (BOOL)isWirelessPrintingSupported {
	UIDevice *device = [UIDevice currentDevice];
	NSString *model = device.model;
	if ((![model isEqualToString:@"iPhone1,1"]) &&
		(![model isEqualToString:@"iPod1,1"]) &&
		(![model isEqualToString:@"iPhone1,2"]) &&
		(![model isEqualToString:@"iPod2,1"])) {
		if ([device.systemVersion compare:@"4.2"] != NSOrderedAscending) {
			if (NSClassFromString(@"UIPrintInteractionController")) {
				UIPrintInteractionController *printInteractionController = [UIPrintInteractionController sharedPrintController];
				if (printInteractionController) {
					if ([UIPrintInteractionController isPrintingAvailable]) {
						return YES;
					}
				}
			}
		}
	}
	return NO;
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
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			GeneralSettingsViewController *generalSettingsViewController = [[GeneralSettingsViewController alloc]initWithNibName:@"GeneralSettingsViewController" bundle:nil];
			generalSettingsViewController.title = @"General Settings";
			[self.navigationController pushViewController:generalSettingsViewController animated:YES];
			[generalSettingsViewController release];
		}
		else {
			PrintingOptionsViewController *printingOptionsViewController = [[PrintingOptionsViewController alloc]initWithNibName:@"PrintingOptionsViewController" bundle:nil];
			printingOptionsViewController.title = @"Printing Options";
			[self.navigationController pushViewController:printingOptionsViewController animated:YES];
			[printingOptionsViewController release];
		}
	}
	else if (indexPath.section == 1) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey]) {
			LoginView *loginView = [[LoginView alloc]initWithNibName:@"LoginView" bundle:nil];
			loginView.delegate = self;
			if ([defaults boolForKey:kSimplePasscodeKey]) {
				loginView.firstSegmentLoginViewType = kLoginViewTypeFourDigit;
			}
			else {
				loginView.firstSegmentLoginViewType = kLoginViewTypeTextField;
			}
			loginView.loginType = kLoginTypeAuthenticate;
			isAccessingPasscodeSettings = (indexPath.row == 0);
			[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]presentModalViewController:loginView animated:YES];
			[loginView release];
		}
		else {
			if (indexPath.row == 0) {
				[self pushPasscodeSettingsViewControllerAnimated:YES];
			}
			else {
				[self pushForgotPasscodeSettingsViewControllerAnimated:YES];
			}
		}
	}
	else if (indexPath.section < 4) {
		if ((indexPath.section == 2) && (indexPath.row == 1)) {
			USBImportHelpViewController *usbImportHelpViewController = [[USBImportHelpViewController alloc]initWithNibName:@"USBImportHelpViewController" bundle:nil];
			usbImportHelpViewController.title = @"USB Import Help";
			[self.navigationController pushViewController:usbImportHelpViewController animated:YES];
			[usbImportHelpViewController release];
		}
		else {
			USBFileTransferViewController *usbFileTransferViewController = [[USBFileTransferViewController alloc]initWithNibName:@"USBFileTransferViewController" bundle:nil];
			usbFileTransferViewController.isImporting = (indexPath.section == 2);
			if (indexPath.section == 2) {
				usbFileTransferViewController.title = @"USB Import";
			}
			else {
				usbFileTransferViewController.title = @"USB Export";
			}
			[self.navigationController pushViewController:usbFileTransferViewController animated:YES];
			[usbFileTransferViewController release];
		}
	}
	else if (indexPath.section == 4) {
		BluetoothFileTransferViewController *bluetoothFileTransferViewController = [[BluetoothFileTransferViewController alloc]initWithNibName:@"BluetoothFileTransferViewController" bundle:nil];
		bluetoothFileTransferViewController.title = [@"Bluetooth " stringByAppendingString:(indexPath.row == 0) ? @"Import" : @"Export"];
		bluetoothFileTransferViewController.isImporting = (indexPath.row == 0);
		[self.navigationController pushViewController:bluetoothFileTransferViewController animated:YES];
		[bluetoothFileTransferViewController release];
	}
	else if (indexPath.section == 5) {
		[originalFilesArray setArray:[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]notesArray:NO]];
		NSInteger noteCount = [originalFilesArray count];
		if (noteCount > 0) {
			NSString *zipFilePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"Notes.zip"];
			ZipArchive *zipArchive = [[ZipArchive alloc]init];
			if ([zipArchive CreateZipFile2:zipFilePath]) {
				[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
				
				[self performSelectorInBackground:@selector(_showHUD) withObject:nil];
				
				for (currentItem = 0; currentItem <= noteCount; currentItem += 1) {
					[self performSelectorInBackground:@selector(_updateElements) withObject:nil];
					
					if (currentItem < noteCount) {
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
					else {
						NSFileManager *fileManager = [NSFileManager defaultManager];
						NSString *temporaryDirectory = [self temporaryDirectory];
						for (NSString *file in [fileManager contentsOfDirectoryAtPath:temporaryDirectory error:nil]) {
							if (![[file substringToIndex:1]isEqualToString:kHiddenFilePrefixStr]) {
								[zipArchive addFileToZip:[temporaryDirectory stringByAppendingPathComponent:file] newname:[[file pathComponents]lastObject]];
							}
						}
						[fileManager removeItemAtPath:temporaryDirectory error:nil];
						if ([zipArchive CloseZipFile2]) {
							[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]presentMailComposeControllerWithSubject:@"Notes" message:nil isHTML:NO attachedFilePath:zipFilePath attachedFileMIMEType:@"application/zip"];
						}
						else {
							UIAlertView *couldNotCloseZipFile = [[UIAlertView alloc]
																 initWithTitle:@"Could Not Close Zip file"
																 message:@"The zip file was created but could not be closed. You may need to free up disk space in order for the app to export all of your notes via email. If this problem persists after freeing up disk space, please restart your device and try again."
																 delegate:nil
																 cancelButtonTitle:@"OK"
																 otherButtonTitles:nil];
							[couldNotCloseZipFile show];
							[couldNotCloseZipFile release];
						}
						[zipArchive release];
						[fileManager removeItemAtPath:zipFilePath error:nil];
					}
				}
				
				[self performSelectorInBackground:@selector(fadeOutHUD) withObject:nil];
				
				[[UIApplication sharedApplication]endIgnoringInteractionEvents];
			}
			else {
				UIAlertView *couldNotCreateZipFileAlert = [[UIAlertView alloc]
														   initWithTitle:@"Could Not Create Zip File"
														   message:@"A zip file could not be created. Please restart your device and try again."
														   delegate:nil
														   cancelButtonTitle:@"OK"
														   otherButtonTitles:nil];
				[couldNotCreateZipFileAlert show];
				[couldNotCreateZipFileAlert release];
			}
		}
		else {
			UIAlertView *noNotesToExportAlert = [[UIAlertView alloc]
												 initWithTitle:@"No Notes to Export"
												 message:@"You have no notes to export."
												 delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
			[noNotesToExportAlert show];
			[noNotesToExportAlert release];
		}
	}
	else if (indexPath.section == 6) {
		SecureNoteImportSettingsViewController *secureNoteImportSettingsViewController = [[SecureNoteImportSettingsViewController alloc]initWithNibName:@"SecureNoteImportSettingsViewController" bundle:nil];
		secureNoteImportSettingsViewController.title = @"Secure Note Importing";
		[self.navigationController pushViewController:secureNoteImportSettingsViewController animated:YES];
		[secureNoteImportSettingsViewController release];
	}
	else if (indexPath.section == 7) {
		PrintingOptionsViewController *printingOptionsViewController = [[PrintingOptionsViewController alloc]initWithNibName:@"PrintingOptionsViewController" bundle:nil];
		printingOptionsViewController.title = @"Printing Options";
		[self.navigationController pushViewController:printingOptionsViewController animated:YES];
		[printingOptionsViewController release];
	}
	else {
		MoreViewController *moreViewController = [[MoreViewController alloc]initWithNibName:@"MoreViewController" bundle:nil];
		moreViewController.title = @"More";
		[self.navigationController pushViewController:moreViewController animated:YES];
		[moreViewController release];
	}
}

- (void)loginViewDidAuthenticate {
	if (isAccessingPasscodeSettings) {
		[self pushPasscodeSettingsViewControllerAnimated:NO];
	}
	else {
		[self pushForgotPasscodeSettingsViewControllerAnimated:NO];
	}
}

- (void)pushPasscodeSettingsViewControllerAnimated:(BOOL)animated {
	PasscodeSettingsViewController *passcodeSettingsViewController = [[PasscodeSettingsViewController alloc]initWithNibName:@"PasscodeSettingsViewController" bundle:nil];
	passcodeSettingsViewController.title = @"Passcode Lock";
	[self.navigationController popToRootViewControllerAnimated:NO];
	[self.navigationController pushViewController:passcodeSettingsViewController animated:animated];
	[passcodeSettingsViewController release];
}

- (void)pushForgotPasscodeSettingsViewControllerAnimated:(BOOL)animated {
	ForgotPasscodeSettingsViewController *forgotPasscodeSettingsViewController = [[ForgotPasscodeSettingsViewController alloc]initWithNibName:@"ForgotPasscodeSettingsViewController" bundle:nil];
	forgotPasscodeSettingsViewController.title = @"Forgot Passcode";
	[self.navigationController pushViewController:forgotPasscodeSettingsViewController animated:YES];
	[forgotPasscodeSettingsViewController release];
}

- (NSString *)temporaryDirectory {
	return [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"tmp"];
}

- (NSString *)filePathForNoteWithTitle:(NSString *)title copyNumber:(NSInteger)copyNumber {
	NSString *temporaryDirectory = [self temporaryDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:temporaryDirectory]) {
		[fileManager createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSString *fileName = nil;
	if (copyNumber > 1) {
		fileName = [title stringByAppendingFormat:@" (%i)", copyNumber];
	}
	else {
		fileName = title;
	}
	return [[temporaryDirectory stringByAppendingPathComponent:fileName]stringByAppendingPathExtension:kPathExtensionStr];
}

- (void)_showHUD {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	hudView = [[HUDView alloc]initWithFrame:CGRectMake(0, 0, 250, 175)];
	hudView.hudLabel.text = @"Exporting Notes...";
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
	NSString *subscript = nil;
	if (currentItem < [originalFilesArray count]) {
		subscript = [NSString stringWithFormat:@"Exporting Note %i of %i", importIndex, totalCount];
	}
	else {
		subscript = @"Closing Zip File...";
	}
	hudView.hudSubscript.text = subscript;
	hudView.hudProgressView.progress = ((CGFloat)currentItem / (CGFloat)totalCount);
	
	[pool release];
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
	
	self.originalFilesArray = nil;
}


- (void)dealloc {
	[originalFilesArray release];
    [super dealloc];
}


@end


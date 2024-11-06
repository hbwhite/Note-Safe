//
//  GeneralSettingsViewController.m
//  Note Safe
//
//  Created by Harrison White on 10/31/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "GeneralSettingsViewController.h"
#import "Note_SafeAppDelegate.h"
#import "TextAndBackgroundViewController.h"
#import "FontSelectViewController.h"
#import "SwitchCell.h"
#import "DetailCell.h"
#import "TextFieldCell.h"

#define AUTOCORRECTION_ENABLED_TAG				0
#define AUTOCAPITALIZATION_ENABLED_TAG			1
#define NOTES_SECTION_BADGE_TAG					2
#define APP_ICON_BADGE_TAG						3

#define MAXIMUM_FONT_SIZE						288

static NSString *kAutocorrectionEnabledKey		= @"Autocorrection Enabled";
static NSString *kAutocapitalizationEnabledKey	= @"Autocapitalization Enabled";
static NSString *kNotesSectionBadgeKey			= @"Notes Section Badge";
static NSString *kAppIconBadgeKey				= @"App Icon Badge";
static NSString *kFontNameKey					= @"Font Name";
static NSString *kFontSizeKey					= @"Font Size";

@implementation GeneralSettingsViewController

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	if ([[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]textField]isFirstResponder]) {
		[self doneButtonPressed];
	}
    [super viewWillDisappear:animated];
}

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
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 2;
			break;
		case 3:
			return 2;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return @"Text & Background Color";
			break;
		case 2:
			return @"Font & Font Size";
			break;
		case 3:
			return @"Starred Notes Badge";
			break;
		default:
			return nil;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 3) {
		return @"Enable this feature to have the app automatically badge the Notes section and/or the app icon with the number of starred notes.";
	}
	else {
		return nil;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
		static NSString *CellIdentifier = @"Cell 1";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		
		cell.textLabel.text = @"Change Colors";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			static NSString *CellIdentifier = @"Cell 2";
			
			DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
			}
			
			// Configure the cell...
			
			cell.textLabel.text = @"Font";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
			cell.detailLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:kFontNameKey];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
		else {
			static NSString *CellIdentifier = @"Cell 3";
			
			TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[TextFieldCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
			}
			
			// Configure the cell...
			
			cell.textLabel.text = @"Font Size";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
			cell.detailTextLabel.text = @"Tap to Edit";
			cell.textField.delegate = self;
			cell.textField.textAlignment = UITextAlignmentRight;
			cell.textField.clearButtonMode = UITextFieldViewModeNever;
			cell.textField.keyboardType = UIKeyboardTypeNumberPad;
			cell.textField.returnKeyType = UIReturnKeyDone;
			cell.textField.frame = CGRectMake(110, 10, 180, 22);
			cell.textField.text = [NSString stringWithFormat:@"%i", [[NSUserDefaults standardUserDefaults]integerForKey:kFontSizeKey]];
			
			return cell;
		}
	}
	else {
		static NSString *CellIdentifier = @"Cell 4";
		
		SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (indexPath.section == 0) {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Auto-Correction";
				cell.cellSwitch.tag = AUTOCORRECTION_ENABLED_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kAutocorrectionEnabledKey];
			}
			else {
				cell.textLabel.text = @"Auto-Capitalization";
				cell.cellSwitch.tag = AUTOCAPITALIZATION_ENABLED_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kAutocapitalizationEnabledKey];
			}
		}
		else {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Badge Notes Section";
				cell.cellSwitch.tag = NOTES_SECTION_BADGE_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kNotesSectionBadgeKey];
			}
			else {
				cell.textLabel.text = @"Badge App Icon";
				cell.cellSwitch.tag = APP_ICON_BADGE_TAG;
				cell.cellSwitch.on = [defaults boolForKey:kAppIconBadgeKey];
			}
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		return cell;
	}
}

- (void)switchValueChanged:(id)sender {
	UISwitch *theSwitch = sender;
	NSString *key = nil;
	switch (theSwitch.tag) {
		case AUTOCORRECTION_ENABLED_TAG:
			key = kAutocorrectionEnabledKey;
			break;
		case AUTOCAPITALIZATION_ENABLED_TAG:
			key = kAutocapitalizationEnabledKey;
			break;
		case NOTES_SECTION_BADGE_TAG:
			key = kNotesSectionBadgeKey;
			break;
		case APP_ICON_BADGE_TAG:
			key = kAppIconBadgeKey;
			break;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:theSwitch.on forKey:key];
	[defaults synchronize];
	
	if ((theSwitch.tag == NOTES_SECTION_BADGE_TAG) || (theSwitch.tag == APP_ICON_BADGE_TAG)) {
		Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
		if (theSwitch.tag == NOTES_SECTION_BADGE_TAG) {
			[delegate updateNotesSectionBadge];
		}
		else if (theSwitch.tag == APP_ICON_BADGE_TAG) {
			[delegate updateAppIconBadgeNumber];
		}
	}
}

- (void)textFieldEditingChanged:(id)sender {
	UITextField *textField = sender;
	[self saveFontSizeForText:textField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)doneButtonPressed {
	self.navigationItem.rightBarButtonItem = nil;
	UITextField *textField = [(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]textField];
	[self saveFontSizeForText:textField.text];
	[textField resignFirstResponder];
}

- (void)saveFontSizeForText:(NSString *)text {
	if ([text length] > 0) {
		NSInteger fontSize = [text integerValue];
		if (fontSize > 0) {
			if (fontSize > MAXIMUM_FONT_SIZE) {
				fontSize = MAXIMUM_FONT_SIZE;
			}
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setInteger:fontSize forKey:kFontSizeKey];
			[defaults synchronize];
		}
	}
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
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
	if (indexPath.section == 1) {
		TextAndBackgroundViewController *textAndBackgroundViewController = [[TextAndBackgroundViewController alloc]initWithNibName:@"TextAndBackgroundViewController" bundle:nil];
		textAndBackgroundViewController.title = @"Text & Background";
		[self.navigationController pushViewController:textAndBackgroundViewController animated:YES];
		[textAndBackgroundViewController release];
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			FontSelectViewController *fontSelectViewController = [[FontSelectViewController alloc]initWithNibName:@"FontSelectViewController" bundle:nil];
			fontSelectViewController.isSelectingPrintedFont = NO;
			fontSelectViewController.title = @"Font";
			[self.navigationController pushViewController:fontSelectViewController animated:YES];
			[fontSelectViewController release];
		}
		else {
			[[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath]textField]becomeFirstResponder];
		}
	}
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
}


- (void)dealloc {
    [super dealloc];
}


@end


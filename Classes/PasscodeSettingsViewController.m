//
//  PasscodeSettingsViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/17/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "PasscodeSettingsViewController.h"
#import "PasscodeRequirementDelayViewController.h"
#import "Note_SafeAppDelegate.h"
#import "DetailCell.h"
#import "SwitchCell.h"

#define SIMPLE_PASSCODE_SWITCH_TAG								0
#define ERASE_DATA_SWITCH_TAG									1

#define kPasscodeRequirementDelayArray							[NSArray arrayWithObjects:@"Immediately", @"After 1 min.", @"After 5 min.", @"After 15 min.", @"After 1 hour", @"After 4 hours", nil]

#define IMMEDIATE_PASSCODE_REQUIREMENT_DELAY_INDEX				0
#define ONE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		1
#define FIVE_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		2
#define FIFTEEN_MINUTE_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX	3
#define ONE_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX			4
#define FOUR_HOUR_DELAY_PASSCODE_REQUIREMENT_DELAY_INDEX		5

static NSString *kPasscodeKey									= @"Passcode";
static NSString *kPasscodeRequirementDelayIndexKey				= @"Passcode Requirement Delay Index";
static NSString *kSimplePasscodeKey								= @"Simple Passcode";
static NSString *kEraseDataKey									= @"Erase Data";

static NSString *kNullStr										= @"";

@implementation PasscodeSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if ((![[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]modalViewController]) && ([self.navigationController.topViewController isEqual:self])) {
		[self.navigationController popToRootViewControllerAnimated:NO];
	}
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 2;
	}
	else if (section == 1) {
		return 2;
	}
	else {
		return 1;		
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"A simple passcode is a 4 digit number.";
	}
	else if (section == 2) {
		return @"Erase all notes in this app\nafter 10 failed passcode attempts.";
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell 1";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		BOOL passcodeSet = ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey] != nil);
		if (indexPath.row == 0) {
			if (passcodeSet) {
				cell.textLabel.text = @"Turn Passcode Off";
			}
			else {
				cell.textLabel.text = @"Turn Passcode On";
			}
		}
		else {
			cell.textLabel.text = @"Change Passcode";
			cell.textLabel.enabled = passcodeSet;
			cell.userInteractionEnabled = passcodeSet;
		}
		
		return cell;
	}
	else if ((indexPath.section == 1) && (indexPath.row == 0)) {
		static NSString *CellIdentifier = @"Cell 2";
		
		DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL passcodeSet = ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey] != nil);
		
		cell.textLabel.text = @"Require Passcode";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.detailLabel.text = [kPasscodeRequirementDelayArray objectAtIndex:[defaults integerForKey:kPasscodeRequirementDelayIndexKey]];
		cell.textLabel.enabled = passcodeSet;
		cell.detailLabel.enabled = passcodeSet;
		cell.userInteractionEnabled = passcodeSet;
		
		return cell;
	}
	else {
		static NSString *CellIdentifier = @"Cell 3";
		
		SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (indexPath.section == 1) {
			cell.textLabel.text = @"Simple Passcode";
			cell.cellSwitch.tag = SIMPLE_PASSCODE_SWITCH_TAG;
			cell.cellSwitch.on = [defaults boolForKey:kSimplePasscodeKey];
		}
		else {
			cell.textLabel.text = @"Erase Notes";
			cell.cellSwitch.tag = ERASE_DATA_SWITCH_TAG;
			cell.cellSwitch.on = [defaults boolForKey:kEraseDataKey];
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		[cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		return cell;
	}
}

- (void)switchValueChanged:(id)sender {
	UISwitch *theSwitch = sender;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (theSwitch.tag == SIMPLE_PASSCODE_SWITCH_TAG) {
		if ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey]) {
			LoginView *loginView = [[LoginView alloc]initWithNibName:@"LoginView" bundle:nil];
			if ([[NSUserDefaults standardUserDefaults]boolForKey:kSimplePasscodeKey]) {
				loginView.firstSegmentLoginViewType = kLoginViewTypeFourDigit;
				loginView.secondSegmentLoginViewType = kLoginViewTypeTextField;
			}
			else {
				loginView.firstSegmentLoginViewType = kLoginViewTypeTextField;
				loginView.secondSegmentLoginViewType = kLoginViewTypeFourDigit;
			}
			loginView.loginType = kLoginTypeChangePasscode;
			[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]presentModalViewController:loginView animated:YES];
			[loginView release];
		}
		else {
			[defaults setBool:theSwitch.on forKey:kSimplePasscodeKey];
			[defaults synchronize];
		}
	}
	else {
		[defaults setBool:theSwitch.on forKey:kEraseDataKey];
		[defaults synchronize];
	}
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
	if (indexPath.section == 0) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		LoginView *loginView = [[LoginView alloc]initWithNibName:@"LoginView" bundle:nil];
		kLoginViewType universalLoginViewType;
		if ([defaults boolForKey:kSimplePasscodeKey]) {
			universalLoginViewType = kLoginViewTypeFourDigit;
		}
		else {
			universalLoginViewType = kLoginViewTypeTextField;
		}
		loginView.firstSegmentLoginViewType = universalLoginViewType;
		loginView.secondSegmentLoginViewType = universalLoginViewType;
		if (indexPath.row == 0) {
			if ([(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kPasscodeKey]) {
				loginView.loginType = kLoginTypeAuthenticate;
				loginView.delegate = self;
			}
			else {
				loginView.loginType = kLoginTypeCreatePasscode;
			}
		}
		else {
			loginView.loginType = kLoginTypeChangePasscode;
		}
		[[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]rootViewController]presentModalViewController:loginView animated:YES];
		[loginView release];
	}
	else if ((indexPath.section == 1) && (indexPath.row == 0)) {
		PasscodeRequirementDelayViewController *passcodeRequirementDelayViewController = [[PasscodeRequirementDelayViewController alloc]initWithNibName:@"PasscodeRequirementDelayViewController" bundle:nil];
		passcodeRequirementDelayViewController.title = @"Require Passcode";
		[self.navigationController pushViewController:passcodeRequirementDelayViewController animated:YES];
		[passcodeRequirementDelayViewController release];
	}
}

- (void)loginViewDidAuthenticate {
	[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]deleteKeychainValue:kPasscodeKey];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[super dealloc];
}

@end

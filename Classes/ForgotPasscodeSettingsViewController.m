//
//  ForgotPasscodeSettingsViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/24/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import "ForgotPasscodeSettingsViewController.h"
#import "Note_SafeAppDelegate.h"
#import "SwitchCell.h"
#import "TextFieldCell.h"

#define SECURITY_QUESTION_TEXT_FIELD_TAG		0
#define SECURITY_QUESTION_ANSWER_TEXT_FIELD_TAG	1

static NSString *kForgotPasscodeOptionEnabledKey	= @"Forgot Passcode Option Enabled";
static NSString *kSecurityQuestionKey				= @"Security Question";
static NSString *kSecurityQuestionAnswerKey			= @"Security Question Answer";

@implementation ForgotPasscodeSettingsViewController

@synthesize securityQuestion;
@synthesize securityQuestionAnswer;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *storedSecurityQuestion = [delegate stringForKey:kSecurityQuestionKey];
	if (storedSecurityQuestion) {
		securityQuestion = [[NSMutableString alloc]initWithString:storedSecurityQuestion];
	}
	else {
		securityQuestion = [[NSMutableString alloc]init];
	}
	NSString *storedSecurityQuestionAnswer = [delegate stringForKey:kSecurityQuestionAnswerKey];
	if (storedSecurityQuestionAnswer) {
		securityQuestionAnswer = [[NSMutableString alloc]initWithString:storedSecurityQuestionAnswer];
	}
	else {
		securityQuestionAnswer = [[NSMutableString alloc]init];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self saveSecurityInformation];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.navigationController popToRootViewControllerAnimated:NO];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kForgotPasscodeOptionEnabledKey]) {
		return 3;
	}
	else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Security Question";
	}
	else if (section == 2) {
		return @"Answer";
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell 1";
		
		SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.text = @"Forgot Passcode\nOption Enabled";
		cell.cellSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kForgotPasscodeOptionEnabledKey];
		[cell.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		return cell;
	}
	else {
		/* static */ NSString *CellIdentifier /* = @"Cell" */;
		if (indexPath.section == 1) {
			CellIdentifier = @"Cell 2";
		}
		else {
			CellIdentifier = @"Cell 3";
		}
		
		TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.textField.delegate = self;
		if (indexPath.section == 1) {
			cell.textField.text = securityQuestion;
			cell.textField.tag = SECURITY_QUESTION_TEXT_FIELD_TAG;
		}
		else {
			cell.textField.text = securityQuestionAnswer;
			cell.textField.tag = SECURITY_QUESTION_ANSWER_TEXT_FIELD_TAG;
		}
		cell.textField.placeholder = @"Tap to Edit";
		cell.textField.returnKeyType = UIReturnKeyDone;
		[cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
		
		return cell;
	}
}

- (void)switchValueChanged:(id)sender {
	UISwitch *theSwitch = sender;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:theSwitch.on forKey:kForgotPasscodeOptionEnabledKey];
	[defaults synchronize];
	if (theSwitch.on) {
		[self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
	}
	else {
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)textFieldEditingChanged:(id)sender {
	UITextField *textField = sender;
	if (textField.tag == SECURITY_QUESTION_TEXT_FIELD_TAG) {
		[securityQuestion setString:textField.text];
	}
	else {
		[securityQuestionAnswer setString:textField.text];
	}
}

- (void)saveSecurityInformation {
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	if ([delegate stringForKey:kSecurityQuestionKey]) {
		[delegate updateKeychainValue:securityQuestion forIdentifier:kSecurityQuestionKey];
	}
	else {
		[delegate createKeychainValue:securityQuestion forIdentifier:kSecurityQuestionKey];
	}
	if ([delegate stringForKey:kSecurityQuestionAnswerKey]) {
		[delegate updateKeychainValue:securityQuestionAnswer forIdentifier:kSecurityQuestionAnswerKey];
	}
	else {
		[delegate createKeychainValue:securityQuestionAnswer forIdentifier:kSecurityQuestionAnswerKey];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self saveSecurityInformation];
	[textField resignFirstResponder];
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
	
	if (indexPath.section > 0) {
		[[(TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath]textField]becomeFirstResponder];
	}
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
	
	self.securityQuestion = nil;
	self.securityQuestionAnswer = nil;
}

- (void)dealloc {
	[securityQuestion release];
	[securityQuestionAnswer release];
	[super dealloc];
}

@end

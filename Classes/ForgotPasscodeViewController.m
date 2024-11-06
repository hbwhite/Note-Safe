//
//  ForgotPasscodeViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/20/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "ForgotPasscodeViewController.h"
#import "Note_SafeAppDelegate.h"
#import "LoginViewController.h"
#import "TextFieldCell.h"

static NSString *kPasscodeKey				= @"Passcode";
static NSString *kSecurityQuestionKey		= @"Security Question";
static NSString *kSecurityQuestionAnswerKey	= @"Security Question Answer";

@implementation ForgotPasscodeViewController

#pragma mark -
#pragma mark View lifecycle

- (IBAction)doneButtonPressed {
	[self verifySecurityQuestionAnswer];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}


- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	[[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField]becomeFirstResponder];
    [super viewWillAppear:animated];
}

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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]stringForKey:kSecurityQuestionKey];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    // Configure the cell...
	
	cell.textField.delegate = self;
	cell.textField.returnKeyType = UIReturnKeyDone;
	cell.textField.placeholder = @"Answer to Security Question";
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self verifySecurityQuestionAnswer];
	return NO;
}

- (void)verifySecurityQuestionAnswer {
	Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
	if ([[delegate stringForKey:kSecurityQuestionAnswerKey]caseInsensitiveCompare:[[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]textField]text]] == NSOrderedSame) {
		[delegate deleteKeychainValue:kPasscodeKey];
		[delegate showPasscodeResetAlert];
		[delegate.rootViewController dismissModalViewControllerAnimated:YES];
	}
	else {
		[(LoginViewController *)[self.navigationController.viewControllers objectAtIndex:0]authenticationDidFail];
		[self.navigationController popToRootViewControllerAnimated:YES];
		UIAlertView *incorrectAnswerAlert = [[UIAlertView alloc]
											 initWithTitle:@"Incorrect Answer"
											 message:@"Your answer to the security\nquestion was incorrect."
											 delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[incorrectAnswerAlert show];
		[incorrectAnswerAlert release];
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
}


- (void)dealloc {
    [super dealloc];
}


@end


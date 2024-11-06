//
//  PrintingOptionsViewController.m
//  Note Safe
//
//  Created by Harrison White on 1/29/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "PrintingOptionsViewController.h"
#import "PageOrientationViewController.h"
#import "FontSelectViewController.h"
#import "TextAlignmentViewController.h"
#import "PrintedTextColorViewController.h"
#import "ContentInsetsViewController.h"
#import "DuplexPrintingViewController.h"
#import "DetailCell.h"
#import "TextFieldCell.h"
#import "PrintObjects.h"

#define MAXIMUM_FONT_SIZE				288

@implementation PrintingOptionsViewController

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


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
    // Return YES for supported orientations.
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 0;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 4;
		case 3:
			return 1;
			break;
		case 4:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"These settings will apply to notes that are printed using AirPrint.\nTo print a note, open it, press the action button in the lower left hand corner, and select \"Print Note\" from the menu.\nAirPrint is not supported by all printers. Please visit\nwww.apple.com/iphone/features/\nairprint.html\nfor more information.";
	}
	else {
		return nil;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 2) && (indexPath.row == 1)) {
		static NSString *CellIdentifier = @"Cell 2";
		
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
		cell.textField.text = [NSString stringWithFormat:@"%i", [[NSUserDefaults standardUserDefaults]integerForKey:kPrintedFontSizeKey]];
		
		return cell;
	}
	else {
		static NSString *CellIdentifier = @"Cell 1";
		
		DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[DetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		NSArray *array = nil;
		NSString *key = nil;
		if (indexPath.section == 1) {
			cell.textLabel.text = @"Page Orientation";
			array = kPrintOrientationArray;
			key = kPrintOrientationKey;
		}
		else if (indexPath.section == 2) {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Font";
				cell.detailLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:kPrintedFontNameKey];
			}
			else if (indexPath.row == 2) {
				cell.textLabel.text = @"Text Color";
			}
			else {
				cell.textLabel.text = @"Text Alignment";
				array = kMainPrintTextAlignmentArray;
				key = kPrintTextAlignmentKey;
			}
		}
		else if (indexPath.section == 3) {
			cell.textLabel.text = @"Content Insets";
		}
		else if (indexPath.section == 4) {
			cell.textLabel.text = @"Duplex Printing";
			array = kPrintDuplexArray;
			key = kPrintDuplexKey;
		}
		if ((array) && (key)) {
			cell.detailLabel.text = [array objectAtIndex:[[NSUserDefaults standardUserDefaults]integerForKey:key]];
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
}

- (void)textFieldEditingChanged:(id)sender {
	UITextField *textField = sender;
	[self savePrintedFontSizeForText:textField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)doneButtonPressed {
	self.navigationItem.rightBarButtonItem = nil;
	UITextField *textField = [(TextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]]textField];
	[self savePrintedFontSizeForText:textField.text];
	[textField resignFirstResponder];
}

- (void)savePrintedFontSizeForText:(NSString *)text {
	if ([text length] > 0) {
		NSInteger fontSize = [text integerValue];
		if (fontSize > 0) {
			if (fontSize > MAXIMUM_FONT_SIZE) {
				fontSize = MAXIMUM_FONT_SIZE;
			}
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setInteger:fontSize forKey:kPrintedFontSizeKey];
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
		PageOrientationViewController *pageOrientationViewController = [[PageOrientationViewController alloc]initWithNibName:@"PageOrientationViewController" bundle:nil];
		pageOrientationViewController.title = @"Page Orientation";
		[self.navigationController pushViewController:pageOrientationViewController animated:YES];
		[pageOrientationViewController release];
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			FontSelectViewController *fontSelectViewController = [[FontSelectViewController alloc]initWithNibName:@"FontSelectViewController" bundle:nil];
			fontSelectViewController.isSelectingPrintedFont = YES;
			fontSelectViewController.title = @"Font";
			[self.navigationController pushViewController:fontSelectViewController animated:YES];
			[fontSelectViewController release];
		}
		else if (indexPath.row == 1) {
			[[(TextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath]textField]becomeFirstResponder];
		}
		else if (indexPath.row == 2) {
			PrintedTextColorViewController *printedTextColorViewController = [[PrintedTextColorViewController alloc]initWithNibName:@"PrintedTextColorViewController" bundle:nil];
			printedTextColorViewController.title = @"Printed Text Color";
			[self.navigationController pushViewController:printedTextColorViewController animated:YES];
			[printedTextColorViewController release];
		}
		else {
			TextAlignmentViewController *textAlignmentViewController = [[TextAlignmentViewController alloc]initWithNibName:@"TextAlignmentViewController" bundle:nil];
			textAlignmentViewController.title = @"Text Alignment";
			[self.navigationController pushViewController:textAlignmentViewController animated:YES];
			[textAlignmentViewController release];
		}
	}
	else if (indexPath.section == 3) {
		ContentInsetsViewController *contentInsetsViewController = [[ContentInsetsViewController alloc]initWithNibName:@"ContentInsetsViewController" bundle:nil];
		contentInsetsViewController.title = @"Content Insets";
		[self.navigationController pushViewController:contentInsetsViewController animated:YES];
		[contentInsetsViewController release];
	}
	else if (indexPath.section == 4) {
		DuplexPrintingViewController *duplexPrintingViewController = [[DuplexPrintingViewController alloc]initWithNibName:@"DuplexPrintingViewController" bundle:nil];
		duplexPrintingViewController.title = @"Duplex Printing";
		[self.navigationController pushViewController:duplexPrintingViewController animated:YES];
		[duplexPrintingViewController release];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end


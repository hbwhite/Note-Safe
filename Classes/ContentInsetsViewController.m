//
//  ContentInsetsViewController.m
//  Note Safe
//
//  Created by Harrison White on 12/8/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "ContentInsetsViewController.h"
#import "PrintObjects.h"
#import "TextFieldCell.h"

@implementation ContentInsetsViewController

@synthesize selectedTextField;
@synthesize decimalNumberHandler;
@synthesize maximumContentWidth;
@synthesize maximumContentHeight;

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
	
	decimalNumberHandler = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode:NSRoundPlain
							scale:1
							raiseOnExactness:NO
							raiseOnOverflow:NO
							raiseOnUnderflow:NO
							raiseOnDivideByZero:NO];
	
	UIPrintFormatter *printFormatter = [[UIPrintFormatter alloc]init];
	maximumContentWidth = printFormatter.maximumContentWidth;
	maximumContentHeight = printFormatter.maximumContentHeight;
	[printFormatter release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (selectedTextField) {
		if ([selectedTextField isFirstResponder]) {
			[self doneButtonPressed];
		}
	}
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"These values are used to determine where the content rectangle begins on the first page. Setting them too high may cause text to run off of the page.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
	TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
	}
	
	// Configure the cell...
	
	cell.textField.tag = indexPath.row;
	cell.textField.delegate = self;
	cell.textField.textAlignment = UITextAlignmentRight;
	cell.textField.clearButtonMode = UITextFieldViewModeNever;
	cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
	cell.textField.returnKeyType = UIReturnKeyDone;
	cell.textField.frame = CGRectMake(80, 10, 210, 22);
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Top";
			break;
		case 1:
			cell.textLabel.text = @"Left";
			break;
		case 2:
			cell.textLabel.text = @"Right";
			break;
	}
	cell.textField.text = [[self decimalNumberForString:[NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults]floatForKey:[self keyForTextFieldWithTag:indexPath.row]]]]stringValue];
	
	return cell;
}

- (NSString *)keyForTextFieldWithTag:(NSInteger)tag {
	switch (tag) {
		case 0:
			return kTopPrintMarginSizeKey;
			break;
		case 1:
			return kLeftPrintMarginSizeKey;
			break;
		case 2:
			return kRightPrintMarginSizeKey;
			break;
		default:
			return nil;
			break;
	}
}

- (NSDecimalNumber *)decimalNumberForString:(NSString *)string {
	return [[NSDecimalNumber decimalNumberWithString:string]decimalNumberByRoundingAccordingToBehavior:decimalNumberHandler];
}

- (void)textFieldEditingChanged:(id)sender {
	[self saveMarginSizeForTextField:sender];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	selectedTextField = textField;
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self saveMarginSizeForTextField:textField];
}

- (void)doneButtonPressed {
	self.navigationItem.rightBarButtonItem = nil;
	[self saveMarginSizeForTextField:selectedTextField];
	[selectedTextField resignFirstResponder];
}

- (void)saveMarginSizeForTextField:(UITextField *)textField {
	if ([textField.text length] > 0) {
		CGFloat marginSize = [[self decimalNumberForString:textField.text]floatValue];
		if (marginSize < 0) {
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:textField.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		}
		else {
			if (textField.tag == 0) {
				if (marginSize > maximumContentHeight) {
					marginSize = maximumContentHeight;
				}
			}
			else if (marginSize > maximumContentWidth) {
				marginSize = maximumContentWidth;
			}
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setFloat:marginSize forKey:[self keyForTextFieldWithTag:textField.tag]];
			[defaults synchronize];
		}
	}
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:textField.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
}

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
	
	self.decimalNumberHandler = nil;
}

- (void)dealloc {
	[decimalNumberHandler release];
	[super dealloc];
}

@end

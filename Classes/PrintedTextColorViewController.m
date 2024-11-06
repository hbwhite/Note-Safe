//
//  PrintedTextColorViewController.m
//  Note Safe
//
//  Created by Harrison White on 12/8/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "PrintedTextColorViewController.h"
#import "PrintObjects.h"
#import "TextViewCell.h"

#define RED_VALUE_SLIDER_CELL_TAG					0
#define GREEN_VALUE_SLIDER_CELL_TAG					1
#define BLUE_VALUE_SLIDER_CELL_TAG					2

static NSString *kPreviewTextStr					= @"The quick brown fox jumps over the lazy dog.";

@implementation PrintedTextColorViewController

@synthesize textColorRedValue;
@synthesize textColorGreenValue;
@synthesize textColorBlueValue;

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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	textColorRedValue = [defaults floatForKey:kPrintedTextColorRedRGBValueKey];
	textColorGreenValue = [defaults floatForKey:kPrintedTextColorGreenRGBValueKey];
	textColorBlueValue = [defaults floatForKey:kPrintedTextColorBlueRGBValueKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
		return 3;
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 62;
	}
	else {
		return 44;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Preview";
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell 1";
		
		TextViewCell *cell = (TextViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.textViewLabel.text = kPreviewTextStr;
		cell.textViewLabel.textColor = [UIColor colorWithRed:textColorRedValue green:textColorGreenValue blue:textColorBlueValue alpha:1];
		
		return cell;
	}
	else {
		static NSString *CellIdentifier = @"Cell 2";
		
		SliderCell *cell = (SliderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SliderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.delegate = self;
		cell.textLabel.text = [[NSArray arrayWithObjects:@"Red", @"Green", @"Blue", nil]objectAtIndex:indexPath.row];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		cell.slider.value = [defaults floatForKey:[[NSArray arrayWithObjects:kPrintedTextColorRedRGBValueKey, kPrintedTextColorGreenRGBValueKey, kPrintedTextColorBlueRGBValueKey, nil]objectAtIndex:indexPath.row]];
		NSInteger keys[3] = { RED_VALUE_SLIDER_CELL_TAG, GREEN_VALUE_SLIDER_CELL_TAG, BLUE_VALUE_SLIDER_CELL_TAG };
		cell.tag = keys[indexPath.row];
		
		return cell;
	}
}

- (void)sliderCell:(SliderCell *)cell valueChanged:(CGFloat)value {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (cell.tag == RED_VALUE_SLIDER_CELL_TAG) {
		textColorRedValue = value;
		[defaults setFloat:value forKey:kPrintedTextColorRedRGBValueKey];
	}
	else if (cell.tag == GREEN_VALUE_SLIDER_CELL_TAG) {
		textColorGreenValue = value;
		[defaults setFloat:value forKey:kPrintedTextColorGreenRGBValueKey];
	}
	else {
		textColorBlueValue = value;
		[defaults setFloat:value forKey:kPrintedTextColorBlueRGBValueKey];
	}
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
}

- (void)dealloc {
	[super dealloc];
}

@end

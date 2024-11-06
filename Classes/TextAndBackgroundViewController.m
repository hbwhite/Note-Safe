//
//  TextAndBackgroundViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/16/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import "TextAndBackgroundViewController.h"
#import "TextViewCell.h"

#define TEXT_COLOR_INDEX							0
#define BACKGROUND_COLOR_INDEX						1

#define RED_VALUE_SLIDER_CELL_TAG					0
#define GREEN_VALUE_SLIDER_CELL_TAG					1
#define BLUE_VALUE_SLIDER_CELL_TAG					2

static NSString *kPreviewTextStr					= @"The quick brown fox jumps over the lazy dog.";

static NSString *kTextColorRedRGBValueKey			= @"Text Color Red RGB Value";
static NSString *kTextColorGreenRGBValueKey			= @"Text Color Green RGB Value";
static NSString *kTextColorBlueRGBValueKey			= @"Text Color Blue RGB Value";

static NSString *kBackgroundColorRedRGBValueKey		= @"Background Color Red RGB Value";
static NSString *kBackgroundColorGreenRGBValueKey	= @"Background Color Green RGB Value";
static NSString *kBackgroundColorBlueRGBValueKey	= @"Background Color Blue RGB Value";

@implementation TextAndBackgroundViewController

@synthesize textColorRedValue;
@synthesize textColorGreenValue;
@synthesize textColorBlueValue;
@synthesize backgroundColorRedValue;
@synthesize backgroundColorGreenValue;
@synthesize backgroundColorBlueValue;
@synthesize isEditingBackgroundColor;

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
	
	textColorRedValue = [defaults floatForKey:kTextColorRedRGBValueKey];
	textColorGreenValue = [defaults floatForKey:kTextColorGreenRGBValueKey];
	textColorBlueValue = [defaults floatForKey:kTextColorBlueRGBValueKey];
	
	backgroundColorRedValue = [defaults floatForKey:kBackgroundColorRedRGBValueKey];
	backgroundColorGreenValue = [defaults floatForKey:kBackgroundColorGreenRGBValueKey];
	backgroundColorBlueValue = [defaults floatForKey:kBackgroundColorBlueRGBValueKey];
	
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSUserDefaults standardUserDefaults]synchronize];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 2) {
		return 3;
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
			return 62;
		}
		else {
			return 41;
		}
	}
	else if (indexPath.section == 1) {
		return 43;
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
		cell.backgroundColor = [UIColor colorWithRed:backgroundColorRedValue green:backgroundColorGreenValue blue:backgroundColorBlueValue alpha:1];
		
		return cell;
	}
	else if (indexPath.section == 1) {
		static NSString *CellIdentifier = @"Cell 2";
		
		SegmentedControlCell *cell = (SegmentedControlCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SegmentedControlCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.delegate = self;
		cell.segmentedControl.selectedSegmentIndex = 0;
		
		return cell; 
	}
	else {
		static NSString *CellIdentifier = @"Cell 3";
		
		SliderCell *cell = (SliderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[SliderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		}
		
		// Configure the cell...
		
		cell.delegate = self;
		cell.textLabel.text = [[NSArray arrayWithObjects:@"Red", @"Green", @"Blue", nil]objectAtIndex:indexPath.row];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (isEditingBackgroundColor) {
			cell.slider.value = [defaults floatForKey:[[NSArray arrayWithObjects:kBackgroundColorRedRGBValueKey, kBackgroundColorGreenRGBValueKey, kBackgroundColorBlueRGBValueKey, nil]objectAtIndex:indexPath.row]];
		}
		else {
			cell.slider.value = [defaults floatForKey:[[NSArray arrayWithObjects:kTextColorRedRGBValueKey, kTextColorGreenRGBValueKey, kTextColorBlueRGBValueKey, nil]objectAtIndex:indexPath.row]];
		}
		NSInteger keys[3] = { RED_VALUE_SLIDER_CELL_TAG, GREEN_VALUE_SLIDER_CELL_TAG, BLUE_VALUE_SLIDER_CELL_TAG };
		cell.tag = keys[indexPath.row];
		
		return cell;
	}
}

- (void)segmentedControlCellValueChanged:(NSInteger)selectedIndex {
	isEditingBackgroundColor = (selectedIndex == BACKGROUND_COLOR_INDEX);
	if (selectedIndex == TEXT_COLOR_INDEX) {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationRight];
	}
	else {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationLeft];
	}
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)sliderCell:(SliderCell *)cell valueChanged:(CGFloat)value {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (isEditingBackgroundColor) {
		if (cell.tag == RED_VALUE_SLIDER_CELL_TAG) {
			backgroundColorRedValue = value;
			[defaults setFloat:value forKey:kBackgroundColorRedRGBValueKey];
		}
		else if (cell.tag == GREEN_VALUE_SLIDER_CELL_TAG) {
			backgroundColorGreenValue = value;
			[defaults setFloat:value forKey:kBackgroundColorGreenRGBValueKey];
		}
		else {
			backgroundColorBlueValue = value;
			[defaults setFloat:value forKey:kBackgroundColorBlueRGBValueKey];
		}
	}
	else {
		if (cell.tag == RED_VALUE_SLIDER_CELL_TAG) {
			textColorRedValue = value;
			[defaults setFloat:value forKey:kTextColorRedRGBValueKey];
		}
		else if (cell.tag == GREEN_VALUE_SLIDER_CELL_TAG) {
			textColorGreenValue = value;
			[defaults setFloat:value forKey:kTextColorGreenRGBValueKey];
		}
		else {
			textColorBlueValue = value;
			[defaults setFloat:value forKey:kTextColorBlueRGBValueKey];
		}
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

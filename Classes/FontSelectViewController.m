//
//  FontSelectViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/24/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import "FontSelectViewController.h"

static NSString *kFontNameKey			= @"Font Name";
static NSString *kPrintedFontNameKey	= @"Printed Font Name";

@implementation FontSelectViewController

@synthesize fontNamesArray;
@synthesize selectedRow;
@synthesize isSelectingPrintedFont;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (NSString *)fontNameKey {
	if (isSelectingPrintedFont) {
		return kPrintedFontNameKey;
	}
	else {
		return kFontNameKey;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	fontNamesArray = [[NSMutableArray alloc]init];
	NSArray *familyNamesArray = [UIFont familyNames];
	for (NSString *familyName in familyNamesArray) {
		[fontNamesArray addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
	}
	[fontNamesArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	selectedRow = [fontNamesArray indexOfObject:[[NSUserDefaults standardUserDefaults]objectForKey:[self fontNameKey]]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [fontNamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	NSString *fontName = [fontNamesArray objectAtIndex:indexPath.row];
	cell.textLabel.text = fontName;
	cell.textLabel.font = [UIFont fontWithName:fontName size:17];
	if (indexPath.row == selectedRow) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger previouslySelectedRow = [fontNamesArray indexOfObject:[defaults objectForKey:[self fontNameKey]]];
	if (indexPath.row != previouslySelectedRow) {
		selectedRow = indexPath.row;
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:previouslySelectedRow inSection:0], indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[defaults setObject:[fontNamesArray objectAtIndex:indexPath.row] forKey:[self fontNameKey]];
		[defaults synchronize];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
	self.fontNamesArray = nil;
}

- (void)dealloc {
	[fontNamesArray release];
	[super dealloc];
}

@end

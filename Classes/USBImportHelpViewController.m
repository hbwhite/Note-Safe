//
//  ImportingNotesHelpViewController.m
//  Note Safe
//
//  Created by Harrison White on 11/6/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "USBImportHelpViewController.h"


@implementation USBImportHelpViewController

@synthesize isDetailView;
@synthesize isMacUser;

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (isDetailView) {
		return 0;
	}
	else {
		return 2;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (isDetailView) {
		NSString *headerString = @"The following instructions will help you make sure that the text files you are importing are in the proper format. Please follow these instructions for each note you would like to import to ensure that they are imported properly.\n\n";
		NSString *footerString = @"\n\nNow, return to the Settings section by pressing the back button in the upper left hand corner of this screen. Select \"Import Notes via USB\", and then follow the instructions on the screen to import the notes.";
		if (isMacUser) {
			return [[headerString stringByAppendingString:@"Open the \"TextEdit\" application and type or paste text in the window. From the menu at the top of the screen, choose \"Format\" > \"Make Plain Text\". Save the file."]stringByAppendingString:footerString];
		}
		else {
			return [[headerString stringByAppendingString:@"Open the \"Notepad\" application and type or paste text in the window. Choose \"File\" > \"Save As...\" and make sure \"Save as type...\" is set to \"Text Documents (*.txt)\". Save the file."]stringByAppendingString:footerString];
		}
	}
	else {
		
	}
	return @"I am a...";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Windows User";
		cell.imageView.image = [UIImage imageNamed:@"Windows"];
		cell.imageView.highlightedImage = [UIImage imageNamed:@"Windows-Selected"];
	}
	else {
		cell.textLabel.text = @"Mac User";
		cell.imageView.image = [UIImage imageNamed:@"Mac"];
		cell.imageView.highlightedImage = [UIImage imageNamed:@"Mac-Selected"];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
	USBImportHelpViewController *usbImportHelpViewController = [[USBImportHelpViewController alloc]initWithNibName:@"USBImportHelpViewController" bundle:nil];
	usbImportHelpViewController.title = indexPath.row == 0 ? @"Windows User" : @"Mac User";
	usbImportHelpViewController.isDetailView = YES;
	usbImportHelpViewController.isMacUser = (indexPath.row == 1);
	[self.navigationController pushViewController:usbImportHelpViewController animated:YES];
	[usbImportHelpViewController release];
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


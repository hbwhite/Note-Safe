//
//  MoreViewController.m
//  Note Safe
//
//  Created by Harrison White on 10/31/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MoreViewController.h"
#import "Note_SafeAppDelegate.h"
#import "ApplicationStrings.h"
#import "WebViewController.h"

#import "NetworkStatusChangeNotifier.h"
#import "SA_OAuthTwitterEngine.h"

static NSString *kTellAFriendTitleStr				= @"Tell a Friend";
static NSString *kTellAFriendImageTitleStr			= @"Share";
static NSString *kTellAFriendSelectedImageTitleStr	= @"Share-Selected";

static NSString *kRateOrReviewTitleStr				= @"Rate or Review";
static NSString *kRateOrReviewImageTitleStr			= @"Review";
static NSString *kRateOrReviewSelectedImageTitleStr	= @"Review-Selected";

static NSString *kFacebookTitleStr					= @"Facebook";
static NSString *kFacebookImageTitleStr				= @"Facebook";
static NSString *kFacebookSelectedImageTitleStr		= @"Facebook-Selected";

static NSString *kTwitterTitleStr					= @"Twitter";
static NSString *kTwitterImageTitleStr				= @"Twitter";
static NSString *kTwitterSelectedImageTitleStr		= @"Twitter-Selected";

static NSString *kApplicationVersionKey				= @"CFBundleVersion";

static NSString *kTwitterAuthenticationDataKey		= @"Twitter Authentication Data";

static NSString *kEmailBodyFormatStr				= @"<html><body>Check out this application:<br/><br/><a href=\"%@\">%@</a></body></html>";
static NSString *kTwitterPostPrefixStr				= @"Check out this app in the App Store:\n";

@implementation MoreViewController

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
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 1) {
		return 4;
	}
	else if (section == 2) {
		if (([[[UIDevice currentDevice]systemVersion]compare:@"5.0"] != NSOrderedAscending) && (NSClassFromString(@"TWTweetComposeViewController"))) {
			return 1;
		}
		else {
			return 2;
		}
	}
	else {
		return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [@"Note Safe\nVersion " stringByAppendingString:[[[NSBundle mainBundle]infoDictionary]objectForKey:kApplicationVersionKey]];
	}
	else if (section == 1) {
		return @"Support Us";
	}
	else {
		return @"Sign Out...";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"If you like this app, please help us out by telling a friend or writing a review. We greatly appreciate all of your support.";
	}
	else {
		return nil;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Visit Our Website";
	}
	else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = kTellAFriendTitleStr;
			cell.imageView.image = [UIImage imageNamed:kTellAFriendImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kTellAFriendSelectedImageTitleStr];
		}
		else if (indexPath.row == 1) {
			cell.textLabel.text = kRateOrReviewTitleStr;
			cell.imageView.image = [UIImage imageNamed:kRateOrReviewImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kRateOrReviewSelectedImageTitleStr];
		}
		else if (indexPath.row == 2) {
			cell.textLabel.text = @"Like Our Facebook Page";
			cell.detailTextLabel.text = @"facebook.com/harrisonapps";
			cell.imageView.image = [UIImage imageNamed:kFacebookImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kFacebookSelectedImageTitleStr];
		}
		else {
			cell.textLabel.text = @"Follow Us on Twitter";
			cell.detailTextLabel.text = @"twitter.com/harrisonapps";
			cell.imageView.image = [UIImage imageNamed:kTwitterImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kTwitterSelectedImageTitleStr];
		}
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			cell.textLabel.text = kFacebookTitleStr;
			cell.imageView.image = [UIImage imageNamed:kFacebookImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kFacebookSelectedImageTitleStr];
		}
		else {
			cell.textLabel.text = kTwitterTitleStr;
			cell.imageView.image = [UIImage imageNamed:kTwitterImageTitleStr];
			cell.imageView.highlightedImage = [UIImage imageNamed:kTwitterSelectedImageTitleStr];
		}
	}
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	// cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.31 blue:0.52 alpha:1];
    
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
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			UIActionSheet *sharingOptionsActionSheet = [[UIActionSheet alloc]
														initWithTitle:@"Tell a Friend"
														delegate:self
														cancelButtonTitle:@"Cancel"
														destructiveButtonTitle:nil
														otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
			sharingOptionsActionSheet.tag = 0;
			[sharingOptionsActionSheet showInView:self.tabBarController.view];
			[sharingOptionsActionSheet release];
		}
		else if (indexPath.row == 1) {
			UIActionSheet *rateOrReviewActionSheet = [[UIActionSheet alloc]
													  initWithTitle:@"You will be transferred to the App Store app in order to rate or review this application. We appreciate all of your ratings and reviews."
													  delegate:self
													  cancelButtonTitle:@"Cancel"
													  destructiveButtonTitle:nil
													  otherButtonTitles:@"Rate or Review", nil];
			rateOrReviewActionSheet.tag = 1;
			[rateOrReviewActionSheet showInView:self.tabBarController.view];
			[rateOrReviewActionSheet release];
		}
		else {
			WebViewController *webViewController = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
			webViewController.isFacebookPage = (indexPath.row == 2);
			if (indexPath.row == 2) {
				webViewController.title = @"Facebook";
			}
			else {
				webViewController.title = @"Twitter";
			}
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
	}
	else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
			Facebook *facebook = delegate.facebook;
			[facebook logout:delegate];
		}
		else {
			BOOL didSignOut = NO;
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			if ([[defaults stringForKey:kTwitterAuthenticationDataKey]length] > 0) {
				[defaults removeObjectForKey:kTwitterAuthenticationDataKey];
				[defaults synchronize];
				didSignOut = YES;
			}
			SA_OAuthTwitterEngine *twitterEngine = [(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]twitterEngine];
			if (twitterEngine) {
				if ([twitterEngine respondsToSelector:@selector(clearAccessToken)]) {
					[twitterEngine clearAccessToken];
				}
			}
			if (didSignOut) {
				UIAlertView *signOutSuccessfulAlert = [[UIAlertView alloc]
													   initWithTitle:@"Sign Out Successful"
													   message:@"You have successfully signed out of Twitter."
													   delegate:nil
													   cancelButtonTitle:@"OK"
													   otherButtonTitles:nil];
				[signOutSuccessfulAlert show];
				[signOutSuccessfulAlert release];
			}
			else {
				UIAlertView *alreadySignedOutAlert = [[UIAlertView alloc]
													  initWithTitle:@"Already Signed Out"
													  message:@"You are already signed out of Twitter."
													  delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alreadySignedOutAlert show];
				[alreadySignedOutAlert release];
			}
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		if (actionSheet.tag == 0) {
			if (buttonIndex == 2) {
				[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]presentMailComposeControllerWithSubject:kAppTitleStr message:[NSString stringWithFormat:kEmailBodyFormatStr, kAppStoreURLStr, kAppStoreURLStr] isHTML:YES attachedFilePath:nil attachedFileMIMEType:nil];
			}
			else {
				NetworkStatusChangeNotifier *networkStatusChangeNotifier = [NetworkStatusChangeNotifier defaultNotifier];
				if ([networkStatusChangeNotifier currentNetworkStatus] == kNetworkStatusNotConnected) {
					UIAlertView *noInternetConnectionAlert = [[UIAlertView alloc]
															  initWithTitle:@"No Internet Connection"
															  message:[(buttonIndex == 0) ? @"Facebook" : @"Twitter" stringByAppendingString:@" requires an Internet connection. Please connect to the Internet and try again."]
															  delegate:nil
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
					[noInternetConnectionAlert show];
					[noInternetConnectionAlert release];
				}
				else {
					Note_SafeAppDelegate *delegate = (Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate];
					if (buttonIndex == 0) {
						[delegate.facebook dialog:@"feed" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check out this app in the App Store.", @"message", kAppTitleStr, @"name", kAppStoreURLStr, @"link", kAppStoreURLStr, @"description", nil] andDelegate:self];
					}
					else if (buttonIndex == 1) {
						[delegate presentTwitterViewWithMessage:[kTwitterPostPrefixStr stringByAppendingString:kAppStoreURLStr]];
					}
				}
			}
		}
		else if (actionSheet.tag == 1) {
			if (buttonIndex == 0) {
				NSURL *request = [NSURL URLWithString:kAppStoreURLStr];
				if ([[UIApplication sharedApplication]canOpenURL:request]) {
					[[UIApplication sharedApplication]openURL:request];
				}
				else {
					[(Note_SafeAppDelegate *)[[UIApplication sharedApplication]delegate]displayCannotLaunchAppStoreAlert];
				}
			}
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


//
//  USBImportHelpViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/6/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface USBImportHelpViewController : UITableViewController {
	BOOL isDetailView;
	BOOL isMacUser;
}

@property (readwrite) BOOL isDetailView;
@property (readwrite) BOOL isMacUser;

@end

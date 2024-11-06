//
//  FontSelectViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/24/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontSelectViewController : UITableViewController {
	NSMutableArray *fontNamesArray;
	NSInteger selectedRow;
	BOOL isSelectingPrintedFont;
}

@property (nonatomic, assign) NSMutableArray *fontNamesArray;
@property (nonatomic) NSInteger selectedRow;
@property (readwrite) BOOL isSelectingPrintedFont;

- (NSString *)fontNameKey;

@end

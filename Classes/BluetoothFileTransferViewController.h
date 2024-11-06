//
//  BluetoothFileTransferViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/15/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface BluetoothFileTransferViewController : UITableViewController <GKPeerPickerControllerDelegate, GKSessionDelegate> {
	NSMutableString *pendingNoteImport;
	BOOL isImporting;
}

@property (nonatomic, assign) NSMutableString *pendingNoteImport;
@property (readwrite) BOOL isImporting;

@end

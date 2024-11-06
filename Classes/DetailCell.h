//
//  DetailCell.h
//  Note Safe
//
//  Created by Harrison White on 11/19/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell {
	UILabel *detailLabel;
}

@property (nonatomic, assign) UILabel *detailLabel;

- (void)orientationDidChange:(NSNotification *)notification;
- (void)updateDetailLabelFrame;

@end

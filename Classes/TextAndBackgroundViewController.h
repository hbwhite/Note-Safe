//
//  TextAndBackgroundViewController.h
//  Note Safe
//
//  Created by Harrison White on 11/16/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedControlCell.h"
#import "SliderCell.h"

@interface TextAndBackgroundViewController : UITableViewController <SegmentedControlCellDelegate, SliderCellDelegate> {
	CGFloat textColorRedValue;
	CGFloat textColorGreenValue;
	CGFloat textColorBlueValue;
	CGFloat backgroundColorRedValue;
	CGFloat backgroundColorGreenValue;
	CGFloat backgroundColorBlueValue;
	BOOL isEditingBackgroundColor;
}

@property (nonatomic) CGFloat textColorRedValue;
@property (nonatomic) CGFloat textColorGreenValue;
@property (nonatomic) CGFloat textColorBlueValue;
@property (nonatomic) CGFloat backgroundColorRedValue;
@property (nonatomic) CGFloat backgroundColorGreenValue;
@property (nonatomic) CGFloat backgroundColorBlueValue;
@property (readwrite) BOOL isEditingBackgroundColor;

@end

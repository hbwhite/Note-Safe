//
//  PrintedTextColorViewController.h
//  Note Safe
//
//  Created by Harrison White on 12/8/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderCell.h"

@interface PrintedTextColorViewController : UITableViewController <SliderCellDelegate> {
	CGFloat textColorRedValue;
	CGFloat textColorGreenValue;
	CGFloat textColorBlueValue;
}

@property (nonatomic) CGFloat textColorRedValue;
@property (nonatomic) CGFloat textColorGreenValue;
@property (nonatomic) CGFloat textColorBlueValue;

@end

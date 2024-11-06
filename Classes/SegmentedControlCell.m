//
//  SegmentedControlCell.m
//  Note Safe
//
//  Created by Harrison White on 8/11/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SegmentedControlCell.h"

#define SEGMENTED_CONTROL_TINT_COLOR_RED	0
#define SEGMENTED_CONTROL_TINT_COLOR_GREEN	0.65
#define SEGMENTED_CONTROL_TINT_COLOR_BLUE	1

@interface SegmentedControlCell ()

- (void)segmentedControlValueChanged;

@end

@implementation SegmentedControlCell

@synthesize delegate;
@synthesize segmentedControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Text Color", @"Background Color", nil]];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
			segmentedControl.frame = CGRectMake(0, 0, 302, 44);
		}
		else {
			segmentedControl.frame = CGRectMake(0, 0, 462, 44);
		}
		segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		segmentedControl.tintColor = [UIColor colorWithRed:SEGMENTED_CONTROL_TINT_COLOR_RED green:SEGMENTED_CONTROL_TINT_COLOR_GREEN blue:SEGMENTED_CONTROL_TINT_COLOR_BLUE alpha:1];
		[segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = segmentedControl;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)segmentedControlValueChanged {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(segmentedControlCellValueChanged:)]) {
			[delegate segmentedControlCellValueChanged:segmentedControl.selectedSegmentIndex];
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[segmentedControl release];
	[super dealloc];
}

@end

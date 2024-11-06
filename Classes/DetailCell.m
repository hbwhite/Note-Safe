//
//  DetailCell.m
//  Note Safe
//
//  Created by Harrison White on 11/19/11.
//  Copyright (c) 2012 Harrison Apps, LLC 2011 Harrison White. All rights reserved.
//

#import "DetailCell.h"

#define TEXT_COLOR_RED		(46.0 / 255.0)
#define TEXT_COLOR_GREEN    (65.0 / 255.0)
#define TEXT_COLOR_BLUE		(118.0 / 255.0)

@implementation DetailCell

@synthesize detailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		detailLabel = [[UILabel alloc]init];
		[self updateDetailLabelFrame];
		detailLabel.textColor = [UIColor colorWithRed:TEXT_COLOR_RED green:TEXT_COLOR_GREEN blue:TEXT_COLOR_BLUE alpha:1];
		detailLabel.highlightedTextColor = [UIColor whiteColor];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.textAlignment = UITextAlignmentRight;
		[self.contentView addSubview:detailLabel];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)orientationDidChange:(NSNotification *)notification {
	[self updateDetailLabelFrame];
}

- (void)updateDetailLabelFrame {
	if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
		detailLabel.frame = CGRectMake(10, 10, 260, 22);
	}
	else {
		detailLabel.frame = CGRectMake(10, 10, 420, 22);
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[detailLabel release];
    [super dealloc];
}

@end

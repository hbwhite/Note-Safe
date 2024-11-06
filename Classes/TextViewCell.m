//
//  TextViewCell.m
//  Note Safe
//
//  Created by Harrison White on 7/28/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "TextViewCell.h"

@implementation TextViewCell

@synthesize textViewLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		textViewLabel = [[UILabel alloc]init];
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
			textViewLabel.frame = CGRectMake(0, 0, 282, 44);
		}
		else {
			textViewLabel.frame = CGRectMake(0, 0, 442, 23);
		}
		textViewLabel.numberOfLines = 0;
		textViewLabel.backgroundColor = [UIColor clearColor];
		textViewLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.accessoryView = textViewLabel;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[textViewLabel release];
	[super dealloc];
}

@end

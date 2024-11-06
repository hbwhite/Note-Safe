//
//  SliderCell.m
//  Note Safe
//
//  Created by Harrison White on 6/13/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "SliderCell.h"

@interface SliderCell ()

- (void)sliderValueChanged;

@end

@implementation SliderCell

@synthesize delegate;
@synthesize slider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        slider = [[UISlider alloc]init];
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) {
			slider.frame = CGRectMake(0, 0, 220, 23);
		}
		else {
			slider.frame = CGRectMake(0, 0, 380, 23);
		}
        slider.minimumValue = 0;
        slider.maximumValue = 1;
        slider.backgroundColor = [UIColor clearColor];
		slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = slider;
        
		self.textLabel.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)sliderValueChanged {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(sliderCell:valueChanged:)]) {
			[delegate sliderCell:self valueChanged:slider.value];
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [slider release];
    [super dealloc];
}

@end

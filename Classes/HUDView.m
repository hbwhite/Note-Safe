//
//  HUDView.m
//  Note Safe
//
//  Created by Harrison White on 12/18/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "HUDView.h"

#define HUD_ALPHA 0.875

@implementation HUDView

@synthesize hudActivityIndicatorView;
@synthesize hudProgressView;
@synthesize hudLabel;
@synthesize hudSubscript;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor blackColor];
		self.alpha = HUD_ALPHA;
		self.layer.cornerRadius = 10;
		hudActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		hudActivityIndicatorView.frame = CGRectMake(107, 70, 37, 37);
		[hudActivityIndicatorView startAnimating];
		[self addSubview:hudActivityIndicatorView];
		hudProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
		hudProgressView.frame = CGRectMake(10, 154, 230, 11);
		[self addSubview:hudProgressView];
		hudLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 230, 50)];
		[hudLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[hudLabel setTextAlignment:UITextAlignmentCenter];
		hudLabel.backgroundColor = [UIColor clearColor];
		hudLabel.textColor = [UIColor whiteColor];
		[self addSubview:hudLabel];
		hudSubscript = [[UILabel alloc]initWithFrame:CGRectMake(10, 110, 230, 50)];
		[hudSubscript setFont:[UIFont boldSystemFontOfSize:15]];
		[hudSubscript setTextAlignment:UITextAlignmentCenter];
		hudSubscript.textColor = [UIColor whiteColor];
		hudSubscript.backgroundColor = [UIColor clearColor];
		[self addSubview:hudSubscript];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[hudActivityIndicatorView release];
	[hudProgressView release];
	[hudLabel release];
	[hudSubscript release];
    [super dealloc];
}


@end

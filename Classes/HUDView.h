//
//  HUDView.h
//  Note Safe
//
//  Created by Harrison White on 12/18/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HUDView : UIView {
	UIActivityIndicatorView *hudActivityIndicatorView;
	UIProgressView *hudProgressView;
	UILabel *hudLabel;
	UILabel *hudSubscript;
}

@property (nonatomic, retain) UIActivityIndicatorView *hudActivityIndicatorView;
@property (nonatomic, retain) UIProgressView *hudProgressView;
@property (nonatomic, retain) UILabel *hudLabel;
@property (nonatomic, retain) UILabel *hudSubscript;

@end

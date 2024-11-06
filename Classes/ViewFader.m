//
//  ViewFader.m
//  Note Safe
//
//  Created by Harrison White on 10/30/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "ViewFader.h"


@implementation ViewFader

@synthesize view;
@synthesize interval;
@synthesize decrement;
@synthesize faderTimer;
@synthesize shouldRemoveFromSuperview;

- (id)initWithFadeOutDuration:(CGFloat)duration view:(UIView *)aView {
	view = aView;
	interval = (duration / 100.0);
	decrement = (aView.alpha / 100.0);
	return self;
}

- (void)fadeOutView {
	faderTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(decreaseAlpha) userInfo:nil repeats:YES];
}

- (void)decreaseAlpha {
	if ((!shouldRemoveFromSuperview) && (view.alpha > 0)) {
		view.alpha -= decrement;
	}
	else {
		if (faderTimer) {
			[faderTimer invalidate];
			faderTimer = nil;
		}
		[view removeFromSuperview];
	}
}

@end

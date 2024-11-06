//
//  ViewFader.h
//  Note Safe
//
//  Created by Harrison White on 10/30/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewFader : NSObject {
	UIView *view;
	CGFloat interval;
	CGFloat decrement;
	NSTimer *faderTimer;
	BOOL shouldRemoveFromSuperview;
}

@property (nonatomic, assign) UIView *view;
@property (nonatomic) CGFloat interval;
@property (nonatomic) CGFloat decrement;
@property (nonatomic, assign) NSTimer *faderTimer;
@property (readwrite) BOOL shouldRemoveFromSuperview;

- (id)initWithFadeOutDuration:(CGFloat)duration view:(UIView *)aView;
- (void)fadeOutView;
- (void)decreaseAlpha;

@end

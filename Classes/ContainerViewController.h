//
//  ContainerViewController.h
//  Note Safe
//
//  Created by Harrison White on 10/30/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContainerViewController : UIViewController {
	UITabBarController *parent;
}

@property (nonatomic, assign) UITabBarController *parent;

- (void)presentTwitterPostView;

@end

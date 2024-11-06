//
//  LoginView.h
//  Note Safe
//
//  Created by Harrison White on 2/1/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginTypes.h"

@protocol LoginViewDelegate;

@class LoginNavigationController;

@interface LoginView : UIViewController {
	id <LoginViewDelegate> delegate;
	IBOutlet LoginNavigationController *loginNavigationController;
	kLoginViewType firstSegmentLoginViewType;
	kLoginViewType secondSegmentLoginViewType;
	kLoginType loginType;
}

@property (nonatomic, assign) id <LoginViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet LoginNavigationController *loginNavigationController;
@property (nonatomic, assign) kLoginViewType firstSegmentLoginViewType;
@property (nonatomic, assign) kLoginViewType secondSegmentLoginViewType;
@property (nonatomic, assign) kLoginType loginType;

@end

@protocol LoginViewDelegate <NSObject>

- (void)loginViewDidAuthenticate;

@end

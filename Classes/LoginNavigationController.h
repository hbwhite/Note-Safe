//
//  LoginNavigationController.h
//  Note Safe
//
//  Created by Harrison White on 2/1/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import "LoginView.h"
#import "LoginTypes.h"

@interface LoginNavigationController : UINavigationController {
	id /* <LoginViewDelegate> */ delegate;
	kLoginViewType firstSegmentLoginViewType;
	kLoginViewType secondSegmentLoginViewType;
	kLoginType loginType;
}

@property (nonatomic, assign) id /* <LoginViewDelegate> */ delegate;
@property (nonatomic, assign) kLoginViewType firstSegmentLoginViewType;
@property (nonatomic, assign) kLoginViewType secondSegmentLoginViewType;
@property (nonatomic, assign) kLoginType loginType;

@end

//
//  LoginTypes.h
//  Note Safe
//
//  Created by Harrison White on 2/2/11.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

typedef enum {
	kLoginViewTypeFourDigit,
	kLoginViewTypeTextField
} kLoginViewType;

typedef enum {
	kLoginTypeLogin,
	kLoginTypeAuthenticate,
	kLoginTypeChangePasscode,
	kLoginTypeCreatePasscode
} kLoginType;
//
//  TextFieldAlert.m
//  Note Safe
//
//  Created by Harrison White on 7/17/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "DualTextFieldAlert.h"


@implementation DualTextFieldAlert

@synthesize textField1;
@synthesize textField2;
@synthesize textFieldAlert;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(NSInteger)tag textFieldPlaceholder:(NSString *)textFieldPlaceholder textField2Placeholder:(NSString *)textField2Placeholder textFieldKeyboardType:(UIKeyboardType)textFieldKeyboardType textFieldTextAlignment:(UITextAlignment)textFieldTextAlignment textFieldAutocapitalizationType:(UITextAutocapitalizationType)textFieldAutocapitalizationType textFieldAutocorrectionType:(UITextAutocorrectionType)textFieldAutocorrectionType textFieldSecureTextEntry:(BOOL)textFieldSecureTextEntry {
	textFieldAlert = [[UIAlertView alloc]
					  initWithTitle:title
					  message:[NSString stringWithFormat:@"%@\n\n\n\n", message]
					  delegate:delegate
					  cancelButtonTitle:@"Cancel"
					  otherButtonTitles:@"Done", nil];
	textFieldAlert.tag = tag;
	textField1 = [[UITextField alloc]initWithFrame:CGRectMake(11, 80, 261, 24)];
	textField2 = [[UITextField alloc]initWithFrame:CGRectMake(11, 103, 261, 24)];
	[textField1 setPlaceholder:textFieldPlaceholder];
	[textField2 setPlaceholder:textField2Placeholder];
	[textField1 setFont:[UIFont systemFontOfSize:18]];
	[textField2 setFont:[UIFont systemFontOfSize:18]];
	[textField1 setKeyboardType:textFieldKeyboardType];
	[textField2 setKeyboardType:textFieldKeyboardType];
	[textField1 setReturnKeyType:UIReturnKeyNext];
	[textField1 setDelegate:self];
	[textField2 setDelegate:self];
	[textField1 setTextAlignment:textFieldTextAlignment];
	[textField2 setTextAlignment:textFieldTextAlignment];
	[textField1 setAutocapitalizationType:textFieldAutocapitalizationType];
	[textField2 setAutocapitalizationType:textFieldAutocapitalizationType];
	[textField1 setAutocorrectionType:textFieldAutocorrectionType];
	[textField2 setAutocorrectionType:textFieldAutocorrectionType];
	[textField1 setSecureTextEntry:textFieldSecureTextEntry];
	[textField2 setSecureTextEntry:textFieldSecureTextEntry];
	[textField1 setBorderStyle:UITextBorderStyleLine];
	[textField2 setBorderStyle:UITextBorderStyleLine];
	UIView *textFieldBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(11, 80, 261, 47)];
	textFieldBackgroundView.backgroundColor = [UIColor whiteColor];
	[textFieldAlert addSubview:textFieldBackgroundView];
	[textFieldBackgroundView release];
	[textFieldAlert addSubview:textField1];
	[textFieldAlert addSubview:textField2];
	[textField1 becomeFirstResponder];
	[textField1 release];
	[textField2 release];
	[textFieldAlert show];
	[textFieldAlert release];
	return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:textField1]) {
		[textField2 becomeFirstResponder];
	}
	return NO;
}

@end

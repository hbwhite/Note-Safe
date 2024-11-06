//
//  DualTextFieldAlert.h
//  Note Safe
//
//  Created by Harrison White on 7/17/10.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DualTextFieldAlert : UIAlertView <UITextFieldDelegate> {
	UITextField *textField1;
	UITextField *textField2;
	UIAlertView *textFieldAlert;
}

@property (nonatomic, assign) UITextField *textField1;
@property (nonatomic, assign) UITextField *textField2;
@property (nonatomic, assign) UIAlertView *textFieldAlert;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(NSInteger)tag textFieldPlaceholder:(NSString *)textFieldPlaceholder textField2Placeholder:(NSString *)textField2Placeholder textFieldKeyboardType:(UIKeyboardType)textFieldKeyboardType textFieldTextAlignment:(UITextAlignment)textFieldTextAlignment textFieldAutocapitalizationType:(UITextAutocapitalizationType)textFieldAutocapitalizationType textFieldAutocorrectionType:(UITextAutocorrectionType)textFieldAutocorrectionType textFieldSecureTextEntry:(BOOL)textFieldSecureTextEntry;

@end

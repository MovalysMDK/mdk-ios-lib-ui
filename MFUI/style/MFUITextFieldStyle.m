//
//  MFUITextFieldStyle.m
//  Pods
//
//  Created by Quentin Lagarde on 19/03/2015.
//
//

#import "MFUITextFieldStyle.h"
#import "MFUITextField.h"

@implementation MFUITextFieldStyle

-(void)applyStyleOnView:(MFUITextField *)view {
    [super applyStyleOnView:view];
}

-(void)applyValidStyleOnView:(MFUITextField *)view {
    [super applyValidStyleOnView:view];
    if(view) {
//        view.textField.layer.borderColor = [UIColor greenColor].CGColor;
//        view.textField.layer.borderWidth = 1.0f;
    }
}

-(void)applyErrorStyleOnView:(MFUITextField *)view {
    [super applyErrorStyleOnView:view];
    if(view) {
//        view.textField.layer.borderColor = [UIColor redColor].CGColor;
//        view.textField.layer.borderWidth = 2.0f;
    }
}



@end

/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */

#import <MFCore/MFCoreBean.h>

#import "MFEmailTextField.h"
#import "MFInvalidEmailValueUIValidationError.h"
#import "MFCreateEmailViewController.h"
#import "MFUICommand.h"
#import "UIView+ViewController.h"
#import "MFEmail.h"
#import "MFUIFieldValidator.h"


@interface MFEmailTextField ()

@end

@implementation MFEmailTextField

-(void)initializeComponent {
    [super initializeComponent];
    [self addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

-(NSString *)regex {
    return @"^[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-z]{2,6})$";
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    [self clearErrors];
    NSArray *validators = [MFFieldValidatorHandler fieldValidatorsForAttributes:self.controlAttributes.allKeys forControl:self];
    NSMutableDictionary *validationState = [NSMutableDictionary dictionary];
    for(id<MFFieldValidatorProtocol> fieldValidator in validators) {
        if(validationState[NSStringFromClass([fieldValidator class])]) {
            continue;
        }
        NSMutableDictionary *validatorParameters = [NSMutableDictionary dictionary];
        for(NSString *recognizedAttribute in [fieldValidator recognizedAttributes]) {
            validatorParameters[recognizedAttribute] = self.controlAttributes[recognizedAttribute];
        }
        id errorResult = [fieldValidator validate:[self getData] withCurrentState:validationState withParameters:validatorParameters];
        if(errorResult) {
            validationState[NSStringFromClass([fieldValidator class])] = errorResult;
        }
        else {
            validationState[NSStringFromClass([fieldValidator class])] = [NSNull null];
        }
    }
    
    int numberOfErrors = 0;
    for(id result in validationState.allValues) {
        if(![result isKindOfClass:[NSNull class]]) {
            numberOfErrors++;
            [self addErrors:@[result]];
        }
    }
    
    NSLog(@"ERRORS : %@", validationState);
    return numberOfErrors;
}

-(void) doAction {
    BOOL canSendMail = NO;
    if ([MFMailComposeViewController canSendMail]){
        // Create and show composer
        MFEmail *email = [MFEmail new];
        email.to = [self getData];
        [[MFCommandHandler commandWithKey:@"SendEmailCommand" withQualifier:nil] executeFromViewController:[self parentViewController] withParameters:email, nil];
        
    }
    if(!canSendMail)
    {
        [self addErrors:@[[[MFUIValidationError alloc] initWithCode:500 localizedDescriptionKey:@"MFCantSendMailTechnicalError"localizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)]]];
    }
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeEmailAddress;
}

-(void)textDidChange:(id)object {
    [self validateWithParameters:nil];
}


@end

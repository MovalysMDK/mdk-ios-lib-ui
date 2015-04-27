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

#import "MFUIApplication.h"
#import "MFEmailTextField.h"
#import "MFInvalidEmailValueUIValidationError.h"
#import "MFCreateEmailViewController.h"

@implementation MFEmailTextField

-(NSString *)regex {
    return @"^[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-z]{2,6})$";
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger numberOfErrors = [super validateWithParameters:parameters];
    if(![self matchPattern:[self text]]) {
        NSError *error = [[MFInvalidEmailValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        numberOfErrors++;
        
    }
    return numberOfErrors;
}

-(void) doAction {
    BOOL canSendMail = NO;
    if ([MFMailComposeViewController canSendMail]){
        // Create and show composer
        MFCreateEmailViewController *emailController = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CREATE_EMAIL_VIEW_CONTROLLER];
        if(nil != emailController)
        {
            [emailController setToRecipients:@[[self getData]]];
            //[self.transitionDelegate showViewController:emailController animated:YES completion:nil];
            [[MFUIApplication getInstance].lastAppearViewController presentViewController:emailController animated:YES completion:nil];
            canSendMail = YES;
        }
    }
    if(!canSendMail)
    {
        [self addErrors:@[[[MFUIValidationError alloc] initWithCode:500 localizedDescriptionKey:@"MFCantSendMailTechnicalError"localizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name]]];
    }
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeEmailAddress;
}

@end

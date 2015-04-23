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
//
//  MFSendEmailTextField.m
//  MFUI
//
//

#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreBean.h>

#import "MFSendEmailTextField.h"
#import "MFCreateEmailViewController.h"
#import "MFUIApplication.h"

@implementation MFSendEmailTextField

NSString *const MFSETF_DEFAULT_EMAIL_PATTERN = @"^[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-z]{2,6})$";

NSString *const MFSETF_DEFAULT_URL_TO_SEND_EMAIL = @"mailto:%@";

NSString *const MF_LIVERENDERING_DEFAULT_EMAIL_VALUE = @"email@email.fr";

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) initialize
{
    [super initialize];
    
    self.pattern = MFSETF_DEFAULT_EMAIL_PATTERN;
    self.urlSpecificField = MFSETF_DEFAULT_URL_TO_SEND_EMAIL;
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError *(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFInvalidEmailValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    [self setKeyboardType:UIKeyboardTypeEmailAddress];
}

-(void) doAction
{
    [super doAction];
    BOOL canSendMail = NO;
    if ([MFMailComposeViewController canSendMail]){
        // Create and show composer
        MFCreateEmailViewController *emailController = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CREATE_EMAIL_VIEW_CONTROLLER];
        if(nil != emailController)
        {
            [emailController setToRecipients:@[[self getValue]]];
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


-(MFNoMatchingValueUIValidationError *) buildError
{
    return [[MFInvalidEmailValueUIValidationError alloc] initWithLocalizedFieldName:[self localizedFieldDisplayName] technicalFieldName:self.selfDescriptor.name];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.regularExpressionTextField.textField.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFTEXTFIELD_TEXTFIELD
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD) {
        [self.regularExpressionTextField.textField setTag:TAG_MFSENDEMAILTEXTFIELD_TEXTFIELD];
    }
    if (self.actionButton.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON) {
        [self.actionButton setTag:TAG_MFSENDEMAILTEXTFIELD_ACTIONBUTTON];
    }
}


#pragma mark - specific UITextField functions

-(id<UITextFieldDelegate>) delegate
{
    return self.regularExpressionTextField.delegate;
}

-(void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.regularExpressionTextField.delegate = delegate;
}

-(void)setMandatory:(NSNumber *)mandatory {
    [self.regularExpressionTextField setMandatory:mandatory];
}



-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.regularExpressionTextField setEditable:editable];
}

-(void)selfCustomization {
    [self setButtonImage:@"envelope.png"];
}


#pragma mark - LiveRendering Methods

-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.regularExpressionTextField.text = MF_LIVERENDERING_DEFAULT_EMAIL_VALUE;

    [self setButtonImage:@"envelope.png"];
}
@end

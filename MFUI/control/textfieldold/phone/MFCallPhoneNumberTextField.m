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
//  MFCallPhoneNumberTextField.m
//  MFUI
//
//

#import "MFCallPhoneNumberTextField.h"

@implementation MFCallPhoneNumberTextField

#pragma mark - Constants

NSString *const MFCPNTF_DEFAULT_PHONE_NUMBER_PATTERN = @"^(\\+[0-9]{1,3})?[ ]?(\\([0-9]{1,3}\\))?[0-9]([ \\.\\-]?[0-9]{1,3}){0,4}[0-9]$";

NSString *const MFCPNTF_DEFAULT_URL_TO_CALL_PHONE_NUMBER = @"tel://%@";


#pragma mark - Initializing

-(void) initialize
{
    [super initialize];
    
    [self displayButton:[[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]];
    self.urlSpecificField = MFCPNTF_DEFAULT_URL_TO_CALL_PHONE_NUMBER;
    self.pattern = MFCPNTF_DEFAULT_PHONE_NUMBER_PATTERN;
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError *(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFInvalidPhoneNumberValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    [self setKeyboardType:UIKeyboardTypePhonePad];

}


#pragma mark - Custom methods

-(void) doAction{
    [super doAction];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:self.urlSpecificField, [self getData]]];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)setMandatory:(NSNumber *)mandatory {
    [self.regularExpressionTextField setMandatory:mandatory];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.regularExpressionTextField setEditable:editable];
}

-(void)selfCustomization {
    [self setButtonImage:@"phone.png"];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    [self.regularExpressionTextField.textField setTag:TAG_MFCALLPHONENUMBERTEXTFIELD_TEXTFIELD];
    [self.actionButton setTag:TAG_MFCALLPHONENUMBERTEXTFIELD_ACTIONBUTTON];
}

@end

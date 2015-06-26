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

#import "MFPhoneTextField.h"
#import "MFInvalidPhoneNumberValueUIValidationError.h"

@implementation MFPhoneTextField

-(NSString *)regex {
    return @"^(\\+[0-9]{1,3})?[ ]?(\\([0-9]{1,3}\\))?[0-9]([ \\.\\-]?[0-9]{1,3}){0,4}[0-9]$";
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger numberOfErrors = [super validateWithParameters:parameters];
    if(![self matchPattern:[self text]]) {
        NSError *error = [[MFInvalidPhoneNumberValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)];
        [self addErrors:@[error]];
        numberOfErrors++;
        
    }
    return numberOfErrors;
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypePhonePad;
}

-(void) doAction {
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [self getData]]];
    [[UIApplication sharedApplication] openURL:url];
}

@end

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

#import "MFUrlTextField.h"
#import "MFInvalidUrlValueUIValidationError.h"

@implementation MFUrlTextField

-(NSString *)regex {
   return @"\\b(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger numberOfErrors = [super validateWithParameters:parameters];
    if(![self matchPattern:[self text]]) {
        NSError *error = [[MFInvalidUrlValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)];
        [self addErrors:@[error]];
        numberOfErrors++;
        
    }
    return numberOfErrors;
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeURL;
}

-(void) doAction {
    NSString *newUrl = [self text];
    if(newUrl && !([newUrl length] == 0) &&
       [newUrl rangeOfString:@"://"].location == NSNotFound)
    {
        newUrl = [@"http://"stringByAppendingString:newUrl];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newUrl]];
}

@end

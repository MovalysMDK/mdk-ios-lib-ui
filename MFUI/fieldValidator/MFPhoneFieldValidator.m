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

#import "MFInvalidPhoneNumberValueUIValidationError.h"
#import "MFPhoneFieldValidator.h"

@implementation MFPhoneFieldValidator

+(instancetype)sharedInstance{
    static MFPhoneFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSArray *)recognizedAttributes {
    return @[];
}

-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters {
    MFError *result = nil;
    if([value isKindOfClass:[NSString class]]) {
        if(![self matchPattern:value]) {
            result = [[MFInvalidPhoneNumberValueUIValidationError alloc]  initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
        }
    }
    return result;
}

-(BOOL)canValidControl:(UIView *)control {
    BOOL canValid = YES;
    canValid = canValid && [control isKindOfClass:NSClassFromString(@"UITextField")];
    return canValid;
}

-(BOOL)isBlocking {
    return NO;
}

-(NSString *)regex {
    return @"^(\\+[0-9]{1,3})?[ ]?(\\([0-9]{1,3}\\))?[0-9]([ \\.\\-]?[0-9]{1,3}){0,4}[0-9]$";
}

-(BOOL) matchPattern:(NSString *)checkString
{
    NSString *regex = [self regex];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:checkString];
}

@end

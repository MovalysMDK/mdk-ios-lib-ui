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

#import "MFLengthFieldValidator.h"
#import "MFTooLongStringUIValidationError.h"
#import "MFTooShortStringUIValidationError.h"


NSString *FIELD_VALIDATOR_MIN_LENGTH = @"minLength";
NSString *FIELD_VALIDATOR_MAX_LENGTH = @"maxLength";

@implementation MFLengthFieldValidator

+(instancetype)sharedInstance{
    static MFLengthFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}


-(NSArray *)recognizedAttributes {
    return @[FIELD_VALIDATOR_MIN_LENGTH, FIELD_VALIDATOR_MAX_LENGTH];
}

-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters {
    if([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *)value;
        if(!stringValue || stringValue.length > [parameters[FIELD_VALIDATOR_MAX_LENGTH] intValue]) {
            return [[MFTooLongStringUIValidationError alloc] initWithLocalizedFieldName:@"ERREUR" technicalFieldName:@"ON VERRA PLUS TARD"];
        }
        else if( stringValue.length < [parameters[FIELD_VALIDATOR_MIN_LENGTH] intValue]) {
            return [[MFTooShortStringUIValidationError alloc] initWithLocalizedFieldName:@"ERREUR" technicalFieldName:@"ON VERRA PLUS TARD"];
        }
    }
    return nil;
}

-(BOOL)canValidControl:(UIView *)control {
    BOOL canValid = YES;
    canValid = canValid && [control isKindOfClass:NSClassFromString(@"UITextField")];
    return canValid;
}

@end

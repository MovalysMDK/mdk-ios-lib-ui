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

#import "MFEmailFieldValidator.h"
#import "MFInvalidEmailValueUIValidationError.h"

@implementation MFEmailFieldValidator

+(instancetype)sharedInstance{
    static MFEmailFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
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
            result = [[MFInvalidEmailValueUIValidationError alloc] initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
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
    return @"^[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*(\\.[a-z]{2,6})$";
}

-(BOOL) matchPattern:(NSString *)checkString
{
    NSString *regex = [self regex];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:checkString];
}

@end

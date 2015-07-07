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

#import "MFMandatoryFieldValidator.h"
#import "MFMandatoryFieldUIValidationError.h"
#import "MFUIBaseListViewModel.h"
#import "MFPhotoViewModel.h"

NSString *FIELD_VALIDATOR_ATTRIBUTE_MANDATORY = @"mandatory";

@implementation MFMandatoryFieldValidator

+(instancetype)sharedInstance{
    static MFMandatoryFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(NSArray *)recognizedAttributes {
    return @[FIELD_VALIDATOR_ATTRIBUTE_MANDATORY];
}

-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters {
    MFError *result = nil;
    if([parameters[FIELD_VALIDATOR_ATTRIBUTE_MANDATORY] boolValue]) {
        if([value isKindOfClass:[NSString class]]) {
            NSString *stringValue = (NSString *)value;
            if(!stringValue || stringValue.length == 0) {
                result = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
            }
        }
        else if([value isKindOfClass:[MFUIBaseListViewModel class]]) {
            MFUIBaseListViewModel *listViewModelValue = (MFUIBaseListViewModel *)value;
            if(!listViewModelValue || listViewModelValue.viewModels.count == 0) {
                result = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
            }
        }
        else if([value isKindOfClass:[MFPhotoViewModel class]]) {
            MFPhotoViewModel *valueAsPhotoViewModel = (MFPhotoViewModel *)value;
            if([valueAsPhotoViewModel isEmpty]) {
                result = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
            }
        }
    }
    return result;
}

-(BOOL)canValidControl:(UIView *)control {
    BOOL canValid = YES;
    canValid = canValid && ([control isKindOfClass:NSClassFromString(@"MFTextField")] ||
                            [control isKindOfClass:NSClassFromString(@"MFUIOldBaseComponent")] ||
                            [control isKindOfClass:NSClassFromString(@"MFUIBaseComponent")]);
    return canValid;
}

-(BOOL)isBlocking {
    return YES;
}

@end

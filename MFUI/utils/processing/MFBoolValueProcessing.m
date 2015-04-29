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
//  MFBoolValueProcessing.m
//  MFUI
//
//

#import "MFBoolValueProcessing.h"
@implementation MFBoolValueProcessing


/**
 * @see MFTypeValueProcessingProtocol.h
 */
-(id)processTreatmentOnComponent:(id<MFUIComponentProtocol>)component withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel forProperty:(NSString *)property fromBindableProperties:(NSDictionary *)bindableProperties {
    id value = [((MFFieldDescriptor *)component.selfDescriptor) valueForKey:property];;
    
    NSNumber *returnValue = @0;
    
    if(value) {
        if([value isKindOfClass:[NSString class]]) {
            //Vérification si la valeur est une valeur autorisée ou une valeur personnalisée
            BOOL isAuthorizedValue = [[[[bindableProperties objectForKey:property] objectForKey:MFATTR_RECOGNIZED_VALUES] componentsSeparatedByString:@";"] containsObject:value];
            
            if(isAuthorizedValue) {
                if([value isEqualToString:@"YES"] || [value isEqualToString:@"1"] || [value isEqualToString:@"true"]) {
                    returnValue = @1;
                }
                else if ([value isEqualToString:@"NO"] || [value isEqualToString:@"0"] || [value isEqualToString:@"false"]) {
                    returnValue = @0;
                }
            }
            else {
                returnValue = ([[(id)viewModel valueForKey:value] boolValue]) ? (returnValue = @1) : (returnValue = @0);
            }
        }
        else if([value isKindOfClass:[NSNumber class]]) {
            returnValue = value;
        }
        else if (value) {
            
        }
    }
    
    return returnValue;
}



@end

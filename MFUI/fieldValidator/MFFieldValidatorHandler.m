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

#import "MFFieldValidatorHandler.h"
#import "MFFieldValidatorProtocol.h"
#import "MFComponentApplicationProtocol.h"
#import "MFSimpleComponentProvider.h"

@implementation MFFieldValidatorHandler

+(NSArray *)fieldValidatorsForAttributes:(NSArray *)attributes forControl:(UIView *)control{
    NSMutableArray *result = [NSMutableArray array];
    
    id<UIApplicationDelegate> appDelegate =  [[UIApplication sharedApplication] delegate];
    NSDictionary *completeFieldValidatorDictionary = nil;
    if([appDelegate conformsToProtocol:@protocol(MFComponentApplicationProtocol)]) {
        completeFieldValidatorDictionary = ((id<MFComponentApplicationProtocol>)appDelegate).fieldValidatorsByAttributes;
    }
    if(!completeFieldValidatorDictionary){
        completeFieldValidatorDictionary = [MFFieldValidatorHandler loadFieldValidatorByAttributes];
    }
    
    [attributes enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
        id<MFFieldValidatorProtocol> fieldValidatorInstance = completeFieldValidatorDictionary[attribute];
        if(fieldValidatorInstance) {
            if([fieldValidatorInstance canValidControl:control]) {
                [result addObject:fieldValidatorInstance];
            }
        }
    }];
    
    return result;
}

+(NSDictionary *)loadFieldValidatorByAttributes {
    NSBundle *mdkControlBundle = [NSBundle bundleForClass:[MFFieldValidatorHandler class]];
    NSBundle *appBundle = [NSBundle bundleForClass:NSClassFromString(@"AppDelegate")];
    
    NSMutableDictionary *completeValidatorList = [[NSDictionary dictionaryWithContentsOfFile:[mdkControlBundle pathForResource:@"MDKFieldValidatorList" ofType:@"plist"]] mutableCopy];
    
    NSString *appResourcePath = [appBundle pathForResource:@"AppFieldValidatorList" ofType:@"plist"];
    
    if(appResourcePath) {
        [completeValidatorList addEntriesFromDictionary:[[NSDictionary dictionaryWithContentsOfFile:appResourcePath] mutableCopy]];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for(NSString *fieldValidatorKey in completeValidatorList.allKeys) {
        
        id<MFFieldValidatorProtocol> fieldValidatorInstance = nil;
        id<MFComponentProviderProtocol> componentProvider = nil;
        id<UIApplicationDelegate> appDelegate =  [[UIApplication sharedApplication] delegate];
        
        if([appDelegate conformsToProtocol:@protocol(MFComponentApplicationProtocol)]) {
            componentProvider = [((id<MFComponentApplicationProtocol>)appDelegate) componentProvider];
        }
        else {
            componentProvider = [MFSimpleComponentProvider new];
        }
        fieldValidatorInstance = [componentProvider fieldValidatorWithKey:fieldValidatorKey];
        
        
        if(fieldValidatorInstance) {
            if([fieldValidatorInstance conformsToProtocol:@protocol(MFFieldValidatorProtocol)]) {
                NSArray *validatorRecognizedAttributes = [fieldValidatorInstance recognizedAttributes];
                for(NSString *recognizedParameter in validatorRecognizedAttributes) {
                    if(!result[recognizedParameter]) {
                        result[recognizedParameter] = fieldValidatorInstance;
                    }
                }
            }
            else {
                @throw [NSException exceptionWithName:@"Incorrect FieldValidator" reason:[NSString stringWithFormat:@"The declared FieldValidator with key %@ does not conform MFFieldValidatorProtocol", fieldValidatorKey]userInfo:nil];
            }
        }
    }
    id<UIApplicationDelegate> appDelegate =  [[UIApplication sharedApplication] delegate];
    if([appDelegate conformsToProtocol:@protocol(MFComponentApplicationProtocol)]) {
        ((id<MFComponentApplicationProtocol>)appDelegate).fieldValidatorsByAttributes = result;
    }
    
    return result;
}

@end

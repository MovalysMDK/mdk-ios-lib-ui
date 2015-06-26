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
        Class fieldValidatorClass = completeFieldValidatorDictionary[attribute];
        if(fieldValidatorClass) {
            id<MFFieldValidatorProtocol> fieldValidator = [fieldValidatorClass sharedInstance];
            if([fieldValidator canValidControl:control]) {
                [result addObject:fieldValidator];
            }
        }
        else {
            @throw [NSException exceptionWithName:@"No FieldValidator Found" reason:[NSString stringWithFormat:@"No FieldValidator found for key: %@", attribute]userInfo:nil];
        }
    }];
    
    return result;
}

+(NSDictionary *)loadFieldValidatorByAttributes {
    NSBundle *mdkControlBundle = [NSBundle bundleForClass:[MFFieldValidatorHandler class]];
    NSBundle *appBundle = [NSBundle bundleForClass:NSClassFromString(@"AppDelegate")];
    
    NSMutableArray *completeValidatorList = [NSMutableArray array];
    completeValidatorList = [[NSArray arrayWithContentsOfFile:[mdkControlBundle pathForResource:@"MDKFieldValidatorList" ofType:@"plist"]] mutableCopy];
    
    NSString *appResourcePath = [appBundle pathForResource:@"AppFieldValidatorList" ofType:@"plist"];
    
    if(appResourcePath) {
        completeValidatorList = [[completeValidatorList arrayByAddingObjectsFromArray:[NSArray arrayWithContentsOfFile:appResourcePath]] mutableCopy];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for(NSString *fieldValidatorName in completeValidatorList) {
        Class fieldValidatorClass = NSClassFromString(fieldValidatorName);
        if(!fieldValidatorClass) {
            @throw [NSException exceptionWithName:@"No FieldValidator Found" reason:[NSString stringWithFormat:@"No FieldValidator found with class: %@", fieldValidatorName]userInfo:nil];
        }
        else {
            if([fieldValidatorClass conformsToProtocol:@protocol(MFFieldValidatorProtocol)]) {
                id<MFFieldValidatorProtocol> fieldValidator = [fieldValidatorClass sharedInstance];
                
                NSArray *validatorRecognizedAttributes = [fieldValidator recognizedAttributes];
                for(NSString *recognizedParameter in validatorRecognizedAttributes) {
                    if(!result[recognizedParameter]) {
                        result[recognizedParameter] = fieldValidatorClass;
                    }
                }
            }
            else {
                @throw [NSException exceptionWithName:@"Incorrect FieldValidator" reason:[NSString stringWithFormat:@"The declared FieldValidator with name %@ does not conform MFFieldValidatorProtocol", fieldValidatorName]userInfo:nil];
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

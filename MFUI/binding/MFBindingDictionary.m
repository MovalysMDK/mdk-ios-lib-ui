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

#import "NSString+Utils.h"
#import "MFBindingDictionary.h"
#import "MFBinding.h"
#import "MFBindingFormatParser.h"

NSString *BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL = @"->";
NSString *BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL = @"<-";
NSString *BINDING_TWO_WAYS_SYMBOL = @"<->";

NSString *BINDING_I18N_KEY_PREFIX = @"i18n.";
NSString *BINDING_VIEWMODEL_PROPERTY_PREFIX = @"vm.";
NSString *BINDING_COMPONENT_PROPERTY_PREFIX = @"c.";
NSString *BINDING_OUTLET_PREFIX = @"outlet.";

NSString *BINDING_OUTLET_SUFFFIX = @".binding";


@interface MFBindingDictionary ()

@property (nonatomic, strong) NSMutableDictionary *typedBindingStructure;

@end



/************************************************************/
/* MFBindingDescriptor                                      */
/************************************************************/

#pragma mark - MFBindingDescriptor
@implementation MFBindingDescriptor

#pragma mark Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModelProperty = nil;
        self.componentProperty = nil;
    }
    return self;
}

+(instancetype) bindingDescriptorWithFormat:(NSString *)format {
    MFBindingDescriptor *bindingDescriptor = [MFBindingDescriptor new];
    NSArray *bindingComponents = nil;
    
    if([format containsString:BINDING_TWO_WAYS_SYMBOL]) {
        bindingDescriptor.bindingMode = MFBindingValueModeTwoWays;
        bindingComponents = [format componentsSeparatedByString:BINDING_TWO_WAYS_SYMBOL];
    }
    else if ([format containsString:BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL]) {
        bindingDescriptor.bindingMode = MFBindingValueModeOneWay;
        bindingComponents = [format componentsSeparatedByString:BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL];
    }
    else if ([format containsString:BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL]) {
        bindingDescriptor.bindingMode = MFBindingValueModeOneWay;
        bindingComponents = [format componentsSeparatedByString:BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL];
    }
    else {
        @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"You should specify a valid direction for binding for the format :%@ . Correct formats are : vm.xxx->c.yyy, c.yyy<-.vm.xxx or vm.xxx<->c.yyy", format] userInfo:nil];
    }
    if([format containsString:BINDING_VIEWMODEL_PROPERTY_PREFIX]) {
        bindingDescriptor = [bindingDescriptor fillVMBindingDescriptor:bindingDescriptor fromComponents:bindingComponents fromFormat:format];
    }
    else if([format containsString:BINDING_I18N_KEY_PREFIX]) {
        bindingDescriptor = [bindingDescriptor fillI18NBindingDescriptor:bindingDescriptor fromComponents:bindingComponents fromFormat:format];
    }
    
    return bindingDescriptor;
}

-(MFBindingDescriptor *) fillI18NBindingDescriptor:(MFBindingDescriptor *)bindingDescriptor fromComponents:(NSArray *)bindingComponents fromFormat:(NSString *)format{
    if([format containsString:BINDING_TWO_WAYS_SYMBOL]) {
        @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"Please verify the binding direction for format : %@. Two ways binding is not allowed for 'i18n'", format] userInfo:nil];
    }
    if([[bindingComponents[0] trim] containsString:BINDING_I18N_KEY_PREFIX]) {
        if(bindingDescriptor.bindingMode == MFBindingValueModeOneWay && [format containsString:BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL]) {
            @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"Please verify the binding direction for format : %@", format] userInfo:nil];
        }
        bindingDescriptor.i18nKey = [[bindingComponents[0] trim] stringByReplacingOccurrencesOfString:BINDING_I18N_KEY_PREFIX withString:@""];
        bindingDescriptor.componentProperty = [[bindingComponents[1] trim] stringByReplacingOccurrencesOfString:BINDING_COMPONENT_PROPERTY_PREFIX withString:@""];
    }
    else if([[bindingComponents[1] trim] containsString:BINDING_I18N_KEY_PREFIX]) {
        if(bindingDescriptor.bindingMode == MFBindingValueModeOneWay && [format containsString:BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL]) {
            @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"Please verify the binding direction for format : %@", format] userInfo:nil];
        }
        bindingDescriptor.i18nKey = [[bindingComponents[1] trim] stringByReplacingOccurrencesOfString:BINDING_I18N_KEY_PREFIX withString:@""];
        bindingDescriptor.componentProperty = [[bindingComponents[0] trim] stringByReplacingOccurrencesOfString:BINDING_COMPONENT_PROPERTY_PREFIX withString:@""];
    }
    else {
        @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"In the format %@, you must prefix the ViewModel property name with \"vm.\" and the Component property name with \"c.\" ", format] userInfo:nil];
        
    }
    return bindingDescriptor;
}

-(MFBindingDescriptor *) fillVMBindingDescriptor:(MFBindingDescriptor *)bindingDescriptor fromComponents:(NSArray *)bindingComponents fromFormat:(NSString *)format{
    if([[bindingComponents[0] trim] containsString:BINDING_VIEWMODEL_PROPERTY_PREFIX]) {
        if(bindingDescriptor.bindingMode == MFBindingValueModeOneWay && [format containsString:BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL]) {
            @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"Please verify the binding direction for format : %@", format] userInfo:nil];
        }
        bindingDescriptor.viewModelProperty = [[bindingComponents[0] trim] stringByReplacingOccurrencesOfString:BINDING_VIEWMODEL_PROPERTY_PREFIX withString:@""];
        bindingDescriptor.componentProperty = [[bindingComponents[1] trim] stringByReplacingOccurrencesOfString:BINDING_COMPONENT_PROPERTY_PREFIX withString:@""];
    }
    else if([[bindingComponents[1] trim] containsString:BINDING_VIEWMODEL_PROPERTY_PREFIX]) {
        if(bindingDescriptor.bindingMode == MFBindingValueModeOneWay && [format containsString:BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL]) {
            @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"Please verify the binding direction for format : %@", format] userInfo:nil];
        }
        bindingDescriptor.viewModelProperty = [[bindingComponents[1] trim] stringByReplacingOccurrencesOfString:BINDING_VIEWMODEL_PROPERTY_PREFIX withString:@""];
        bindingDescriptor.componentProperty = [[bindingComponents[0] trim] stringByReplacingOccurrencesOfString:BINDING_COMPONENT_PROPERTY_PREFIX withString:@""];
    }
    else {
        @throw [NSException exceptionWithName:@"Invalid Binding Descriptor" reason:[NSString stringWithFormat:@"In the format %@, you must prefix the ViewModel property name with \"vm.\" and the Component property name with \"c.\" ", format] userInfo:nil];
        
    }
    return bindingDescriptor;
}

-(NSString *)abstractBindedProperty {
    NSString *result = self.viewModelProperty;
    if(!result) {
        result = self.i18nKey;
    }
    return result;
}

-(MFBindingSource)bindingSource {
    MFBindingSource result = MFBindingSourceViewModel;
    if (self.i18nKey) {
        result = MFBindingSourceStrings;
    }
    return result;
}

#pragma mark Consistency
-(BOOL)isConsistent {
    return (self.componentProperty != nil) && ((self.i18nKey != nil) || self.viewModelProperty != nil);
}

#pragma mark Description
-(NSString *)description {
    return [NSString stringWithFormat:@"DATA[%@] %@ COMPO[%@]", [self abstractBindedProperty], ((self.bindingMode == MFBindingValueModeTwoWays) ? BINDING_TWO_WAYS_SYMBOL : BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL), self.componentProperty];
}
@end


/************************************************************/
/* MFOutletBindingKey                                       */
/************************************************************/

#pragma mark - MFOutletBindingKey
@implementation MFOutletBindingKey

#pragma mark Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.outletName = nil;
    }
    return self;
}

+(instancetype) bindingKeyForOutletName:(NSString *)outletName {
    MFOutletBindingKey *outletBindingKey = [MFOutletBindingKey new];
    outletName = [outletName stringByReplacingOccurrencesOfString:BINDING_OUTLET_PREFIX withString:@""];
    outletName = [outletName stringByReplacingOccurrencesOfString:BINDING_OUTLET_SUFFFIX withString:@""];
    outletBindingKey.outletName = outletName;
    return outletBindingKey;
}

#pragma mark Consistency
-(BOOL)isConsistent {
    return (self.outletName != nil);
}

#pragma mark Description
-(NSString *)description {
    return self.outletName;
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone {
    MFOutletBindingKey *outletBindingKey = [[self class] allocWithZone:zone];
    outletBindingKey->_outletName = [_outletName copyWithZone:zone];
    return outletBindingKey;
}

-(BOOL)isEqual:(id)object {
    BOOL isEqual = YES;
    if(![object isKindOfClass:[MFOutletBindingKey class]]) {
        isEqual = NO;
    }
    else {
        isEqual = isEqual && [self.outletName isEqualToString:((MFOutletBindingKey *)object).outletName];
    }
    return isEqual;
}

-(NSUInteger)hash {
    return self.outletName.hash;
}
@end



/************************************************************/
/* MFBindingDictionary                                      */
/************************************************************/

#pragma mark - MFBindingDictionary
@implementation MFBindingDictionary

#pragma mark Initialization

-(instancetype)init {
    self = [super init];
    if(self) {
        self.typedBindingStructure = [NSMutableDictionary new];
    }
    return self;
}

+(instancetype) bindingDictionary {
    return [MFBindingDictionary new];
}

+(instancetype) bindingDictionaryFromFormat:(NSString *)bindingFormat, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, bindingFormat);
    MFBindingDictionary *dictionary = [MFBindingFormatParser bindingDictionaryFromVaList:args withFirstArg:bindingFormat];
    va_end(args);
    return dictionary;
}




#pragma mark Managing Dictionary
-(void) addBindingDescriptor:(MFBindingDescriptor *)bindingDescriptor forOutletBindingKey:(MFOutletBindingKey *)outletBindingKey {
    if([self canAddBindingDescriptor:bindingDescriptor forOutletBindingKey:outletBindingKey]) {
        NSMutableArray *bindingDescriptors = self.typedBindingStructure[outletBindingKey];
        if(!bindingDescriptors) {
            bindingDescriptors = [NSMutableArray new];
        }
        [bindingDescriptors addObject:bindingDescriptor];
        [self.typedBindingStructure setObject:bindingDescriptors forKey:outletBindingKey];
    }
}

-(BOOL) canAddBindingDescriptor:(MFBindingDescriptor *)bindingDescriptor forOutletBindingKey:(MFOutletBindingKey *)outletBindingKey {
    BOOL canAdd = YES;
    if(!(canAdd = [outletBindingKey isConsistent])) {
        @throw [NSException exceptionWithName:@"Invalid Binding" reason:@"A binding descriptor cannot be added with a nil outlet binding key" userInfo:nil];
    }
    if(!(canAdd = [bindingDescriptor isConsistent])) {
        @throw [NSException exceptionWithName:@"Invalid Binding" reason:[NSString stringWithFormat:@"The Binding descriptor for the key %@ is inconsistent : %@", outletBindingKey.description, bindingDescriptor.description] userInfo:nil];
    }
    return canAdd;
}

#pragma mark Subscripting
-(id)objectForKeyedSubscript:(id)key {
    if([key isKindOfClass:[NSString class]]) {
        return self.typedBindingStructure[[MFOutletBindingKey bindingKeyForOutletName:key]];
    }
    else if([key isKindOfClass:[MFOutletBindingKey class]]) {
        return self.typedBindingStructure[key];
    }
    else {
        @throw [NSException exceptionWithName:@"Invalid key" reason:@"You should use NSString formatted-key or MFOOuytletBindingKey when using Subscripting on MFBindingDictionary" userInfo:nil];
    }
}

-(void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self addBindingDescriptor:[MFBindingDescriptor bindingDescriptorWithFormat:obj] forOutletBindingKey:[MFOutletBindingKey bindingKeyForOutletName:key]];
}

-(NSString *)description {
    return self.typedBindingStructure.description;
}

-(NSArray *) allValues {
    return self.typedBindingStructure.allValues;
}

-(NSArray *) allKeys {
    return self.typedBindingStructure.allKeys;
}
@end

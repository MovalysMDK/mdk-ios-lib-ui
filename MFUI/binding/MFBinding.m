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


#import "MFBinding.h"
#import "MFAbstractComponentWrapper.h"



@implementation MFBinding

-(instancetype) init {
    self = [super init];
    if(self) {
        _bindingByViewModelKeys = [NSMutableDictionary new];
        _bindingByComponents = [NSMutableDictionary new];
        _bindingByBindingKeys = [NSMutableDictionary new];
    }
    return self;
}


#pragma mark - Binding Management

-(void)registerBindingValue:(MFBindingValue *)bindingValue {
    //1 : Register in bindingByViewModelKeys
    NSMutableArray *registeredValues = [self.bindingByViewModelKeys[bindingValue.abstractBindedPropertyName] mutableCopy];
    if(!registeredValues) {
        registeredValues = [NSMutableArray new];
    }
    [registeredValues addObject:bindingValue];
    [self.bindingByViewModelKeys setObject:registeredValues forKey:bindingValue.abstractBindedPropertyName];
    
    //2 : Register in bindingByComponents
    if(bindingValue.bindingMode == MFBindingValueModeTwoWays) {
        NSNumber *key = @([bindingValue.wrapper.component hash]);
        if(!self.bindingByComponents[key]) {
            MFOneWayBindingValue *oneWayBindingValue = (MFOneWayBindingValue *)bindingValue;
            //Par précaution et souci de compréhension, inutile dans ce sens
            [self.bindingByComponents setObject:oneWayBindingValue forKey:key];
        }
    }
}

-(void)registerBindingValue:(MFBindingValue *)bindingValue forBindingKey :(NSString *)bindingKey {
    NSMutableArray *bindingValuesforKey = _bindingByBindingKeys[bindingKey];
    if(!bindingValuesforKey) {
        bindingValuesforKey = [NSMutableArray array];
    }
    [bindingValuesforKey addObject:bindingValue];
    _bindingByBindingKeys[bindingKey] = bindingValuesforKey;
    [bindingValue.wrapper dispatchDidBinded];
}



-(void) clearBindingValuesForBindingKey:(NSString *)bindingKey {
    NSArray *bindingValues = _bindingByBindingKeys[bindingKey];
    for(MFBindingValue *bindingValueToRemove in bindingValues) {
        _bindingByComponents = [self clearBindingValue:bindingValueToRemove inDictionary:_bindingByComponents];
        _bindingByViewModelKeys = [self clearBindingValue:bindingValueToRemove inDictionary:_bindingByViewModelKeys];
    }
    [_bindingByBindingKeys removeObjectForKey:bindingKey];
}

-(void) clearBindingValuesForComponentHash:(NSNumber *)componentHash {
    [_bindingByComponents removeObjectForKey:componentHash];
    NSMutableDictionary *mutableCopy = [_bindingByViewModelKeys mutableCopy];
    for(NSString *key in _bindingByViewModelKeys) {
        NSMutableArray *bindingValues = _bindingByViewModelKeys[key];
        MFBindingValue *bindingValueToRemove = nil;
        for(MFBindingValue *bindingValue in bindingValues) {
            if([@(bindingValue.wrapper.component.hash) isEqualToNumber:componentHash]) {
                bindingValueToRemove = bindingValue;
                bindingValue.wrapper = nil;
                break;
            }
        }
        if(bindingValueToRemove) {
            [bindingValues removeObject:bindingValueToRemove];
        }
        mutableCopy[key] = bindingValues;
    }
    _bindingByViewModelKeys = mutableCopy;
}



-(NSMutableDictionary *) clearBindingValue:(MFBindingValue *) bindingValue inDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *copy = [dictionary mutableCopy];
    for(NSString *key in dictionary.allKeys) {
        id bindingValues = dictionary[key];
        if([bindingValues isKindOfClass:[MFBindingValue class]]) {
            NSUInteger objectPosition = [dictionary.allValues indexOfObject:bindingValue];
            if(objectPosition != NSNotFound && objectPosition != -1) {
                [copy removeObjectForKey:dictionary.allKeys[objectPosition]];
            }
            break;
        }
        else {
            if([bindingValues containsObject:bindingValue]) {
                bindingValue.wrapper = nil;
                [bindingValues removeObject:bindingValue];
            }
            [copy setObject:bindingValues forKey:key];
        }
    }
    return copy;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"BY VIEW MODEL PROPERTY NAME : %@ \n\n BY COMPONENTS HASH : %@ \n\n BY BINDING KEY : %@", self.bindingByViewModelKeys.description, self.bindingByComponents.description, self.bindingByBindingKeys.description];
}

@end


@implementation MFBindingValue

-(instancetype)initWithWrapper:(MFAbstractComponentWrapper *)componentWrapper withBindingMode:(MFBindingValueMode)bindingMode withVmBindedPropertyName:(NSString *)vmBindedPropertyName withComponentBindedPropertyName:(NSString *)componentBindedPropertyName withComponentOutletName:(NSString *)componentOutletName fromSource:(MFBindingSource)bindingSource{
    self = [self initWithWrapper:componentWrapper withBindingMode:bindingMode withVmBindedPropertyName:vmBindedPropertyName withComponentOutletName:componentOutletName fromSource:bindingSource];
    if(self) {
        self.componentBindedPropertyName = componentBindedPropertyName;
    }
    return self;
}

-(instancetype)initWithWrapper:(MFAbstractComponentWrapper *)componentWrapper withBindingMode:(MFBindingValueMode)bindingMode withVmBindedPropertyName:(NSString *)vmBindedPropertyName withComponentOutletName:(NSString *)componentOutletName  fromSource:(MFBindingSource)bindingSource{
    self = [super init];
    if(self) {
        self.wrapper = componentWrapper;
        self.bindingMode = bindingMode;
        self.abstractBindedPropertyName = vmBindedPropertyName;
        self.componentOutletName = componentOutletName;
        self.bindingSource = bindingSource;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Wrapper : %@\rBindingMode : %@\rViewModel Property Name : %@\rComponent Property Name : %@\rComponent Outlet Name : %@", self.wrapper, (self.bindingMode == MFBindingValueModeOneWay) ? @"One Way" : @"Two ways", self.abstractBindedPropertyName, self.componentBindedPropertyName, self.componentOutletName];
}

-(void)setBindingIndexPath:(NSIndexPath *)bindingIndexPath {
    _bindingIndexPath = bindingIndexPath;
    self.wrapper.wrapperIndexPath = bindingIndexPath;
}
@end


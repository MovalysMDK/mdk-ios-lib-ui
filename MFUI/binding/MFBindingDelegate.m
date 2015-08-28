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


#import "MFBindingDelegate.h"
#import "MFObjectWithBindingProtocol.h"
#import "MFAbstractComponentWrapper.h"

@interface MFBindingDelegate ()

@property (nonatomic, strong) NSMutableDictionary *knwonWrappers;
@property (nonatomic, strong) MFBinding *binding;
@property (nonatomic, weak) NSObject<MFObjectWithBindingProtocol> *object;

@end

@implementation MFBindingDelegate
@synthesize structure = _structure;

#pragma mark - Initializing
-(instancetype) initWithObject:(id<MFObjectWithBindingProtocol>)object {
    self = [super init];
    if(self) {
        self.object = object;
        self.binding = [MFBinding new];
        self.knwonWrappers = [NSMutableDictionary new];
    }
    return self;
}


#pragma mark - Components registering

-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode withBindingKey:(NSString *)bindingKey withIndexPath:(NSIndexPath *)indexPath fromBindingSource:(MFBindingSource)bindingSource withConverterName:(NSString *)converterName{
    MFBindingValue *bindingValue =[self registerComponentBindingProperty:componentBindingProperty withViewModelProperty:viewModelProperty forComponent:component withOutletName:outletName withMode:bindingMode withBindingKey:bindingKey fromBindingSource:bindingSource];
    bindingValue.bindingIndexPath = indexPath;
    bindingValue.converterName = converterName;
    [self.binding registerBindingValue:bindingValue forBindingKey:bindingKey];
    return bindingValue;
}

-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode withBindingKey:(NSString *)bindingKey  fromBindingSource:(MFBindingSource)bindingSource {
    MFBindingValue *bindingValue =[self registerComponentBindingProperty:componentBindingProperty withViewModelProperty:viewModelProperty forComponent:component withOutletName:outletName withMode:bindingMode fromBindingSource:bindingSource];
//    [self.binding registerBindingValue:bindingValue forBindingKey:bindingKey];
    return bindingValue;
}


-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode  fromBindingSource:(MFBindingSource)bindingSource {
    
    [self fixKnownWrappers];
    MFAbstractComponentWrapper *wrapper = self.knwonWrappers[@(component.hash)];
    if(!wrapper) {
        NSString *customWrapper = nil;
        Class currentClass = [component class];
        wrapper = [[MFAbstractComponentWrapper alloc] initWithComponent:component];
        while(currentClass != nil) {
            if( (customWrapper = [self wrappersConfiguration][NSStringFromClass(currentClass)]) != nil) {
                wrapper = [[NSClassFromString(customWrapper) alloc] initWithComponent:(UIView<MFUIComponentProtocol> *)component];
                break;
            }
            else if((NSClassFromString([NSString stringWithFormat:@"%@Wrapper", currentClass])) != nil) {
                customWrapper = [NSString stringWithFormat:@"%@Wrapper", currentClass];
                wrapper = [[NSClassFromString(customWrapper) alloc] initWithComponent:(UIView<MFUIComponentProtocol> *)component];
                break;
            }
            currentClass = [currentClass superclass];
        }
        wrapper.objectWithBinding = self.object;
        [self.knwonWrappers setObject:wrapper forKey:@(component.hash)];
    }
    MFBindingValue *bindingValue = [[MFBindingValue alloc] initWithWrapper:wrapper withBindingMode:bindingMode withVmBindedPropertyName:viewModelProperty withComponentBindedPropertyName:componentBindingProperty withComponentOutletName:outletName fromSource:bindingSource];
    [self.binding registerBindingValue:bindingValue];
    return bindingValue;
}


-(NSString *)description {
    return [NSString stringWithFormat:@"Binding For Object : %@ : \n%@", self.object, self.binding];
}

-(NSDictionary *) wrappersConfiguration {
    //    return [((AppDelegate *)[[UIApplication sharedApplication] delegate]) wrappersConfiguration];
    return nil;
}

-(void) fixKnownWrappers {
    NSMutableDictionary *result = [self.knwonWrappers mutableCopy];
    NSMutableArray *objectToRemoveKeys = [NSMutableArray array];
    
    for(MFAbstractComponentWrapper *wrapper in self.knwonWrappers.allValues) {
        if(!wrapper.component) {
            [objectToRemoveKeys addObjectsFromArray:[self.knwonWrappers allKeysForObject:wrapper]];
        }
    }
    [result removeObjectsForKeys:objectToRemoveKeys];
    self.knwonWrappers = result;
}
-(MFBinding *)binding {
    return _binding;
}


#pragma mark - Binding accessors
-(NSArray *) bindingValuesForCellBindingKey:(NSString *)cellBindingKey {
    return self.binding.bindingByBindingKeys[cellBindingKey];
}

-(NSArray *)allBindingValues {
    NSMutableArray *result = [NSMutableArray array];
    for(NSArray *array in self.binding.bindingByViewModelKeys.allValues) {
        [result addObjectsFromArray:array];
    }
    return result;
}

-(void)clear {
    [self.structure removeAllObjects];
}




@end

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

#import <MFCore/MFCoreBean.h>
#import "MFBinding+Dispatcher.h"
#import "MFUIBaseListViewModel.h"
#import "MFAbstractComponentWrapper.h"
#import "MFLocalizedString.h"
#import "MFBindingConverterProtocol.h"

@implementation MFBinding (Dispatcher)

-(void)dispatchValue:(id)value fromComponent:(UIView *)component onObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MFBindingValue *bindingValue = self.bindingByComponents[@(component.hash)];
    if(bindingValue) {
        if([object isKindOfClass:[MFUIBaseListViewModel class]]) {
            //object is list ViewModel
            object = ((MFUIBaseListViewModel *)object).viewModels[indexPath.row];
        }
        value = [self convertValue:value isFromViewModelToControl:NO withWrapper:bindingValue.wrapper];
        value = [self applyCustomConverter:bindingValue.converterName onValue:value isFromViewModelToControl:NO];
        [object setValue:value forKeyPath:bindingValue.abstractBindedPropertyName];
        
    }
}

-(void)dispatchValue:(id)value fromPropertyName:(NSString *)propertyName fromSource:(MFBindingSource)bindingSource{
    if(bindingSource == MFBindingSourceStrings) {
        value = MFLocalizedStringFromKey(propertyName);
    }
    if([value isEqual:[NSNull null]] || [value isKindOfClass:NSClassFromString(@"MFKeyNotFound")]) {
        value = nil;
    }
    NSArray *bindingValues = self.bindingByViewModelKeys[propertyName];
    for(MFBindingValue *bindingValue in bindingValues) {
        NSString *componentBindedPropertyNameWithFirstUppercased = [NSString stringWithFormat:@"%@%@", [[bindingValue.componentBindedPropertyName substringToIndex:1] uppercaseString], [bindingValue.componentBindedPropertyName substringFromIndex:1]];
        NSString *stringSelector = [NSString stringWithFormat:@"set%@:", componentBindedPropertyNameWithFirstUppercased];
        SEL dataSetterSelector = NSSelectorFromString(stringSelector);
        if([bindingValue.wrapper.component respondsToSelector:dataSetterSelector]) {
            if(!value) {
                value = [bindingValue.wrapper nilValueBySelector][stringSelector];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                id convertedValue = [self convertValue:value isFromViewModelToControl:YES withWrapper:bindingValue.wrapper];
                convertedValue = [self applyCustomConverter:bindingValue.converterName onValue:convertedValue isFromViewModelToControl:YES];
                [bindingValue.wrapper.component setValue:convertedValue forKeyPath:bindingValue.componentBindedPropertyName];
            });
        }
    }
}

-(void)dispatchValue:(id)value fromPropertyName:(NSString *)propertyName atIndexPath:(NSIndexPath *)indexPath fromSource:(MFBindingSource)bindingSource {
    if(bindingSource == MFBindingSourceStrings) {
        value = MFLocalizedStringFromKey(propertyName);
    }
    NSArray *bindingValues = self.bindingByViewModelKeys[propertyName];
    for(MFBindingValue *bindingValue in bindingValues) {
        if([bindingValue.bindingIndexPath isEqual:indexPath]) {
            NSString *componentBindedPropertyNameWithFirstUppercased = [NSString stringWithFormat:@"%@%@", [[bindingValue.componentBindedPropertyName substringToIndex:1] uppercaseString], [bindingValue.componentBindedPropertyName substringFromIndex:1]];
            NSString *stringSelector = [NSString stringWithFormat:@"set%@:", componentBindedPropertyNameWithFirstUppercased];
            SEL dataSetterSelector = NSSelectorFromString(stringSelector);
            if([bindingValue.wrapper.component respondsToSelector:dataSetterSelector]) {
                if(!value) {
                    value = [bindingValue.wrapper nilValueBySelector][stringSelector];
                }
                value = [self convertValue:value isFromViewModelToControl:YES withWrapper:bindingValue.wrapper];
                value = [self applyCustomConverter:bindingValue.converterName onValue:value isFromViewModelToControl:YES];
                [bindingValue.wrapper.component setValue:value forKeyPath:bindingValue.componentBindedPropertyName];
            }
        }
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(id)convertValue:(id)value isFromViewModelToControl:(BOOL)isVmToControl withWrapper:(MFAbstractComponentWrapper *) wrapper{
    if([wrapper respondsToSelector:@selector(convertValue:isFromViewModelToControl:)]) {
        value = [wrapper performSelector:@selector(convertValue:isFromViewModelToControl:) withObject:value withObject:@(isVmToControl)];
    }
    return value;
}

-(id)applyCustomConverter:(NSString *)converterName onValue:(id)value isFromViewModelToControl:(BOOL)formViewModelToControl {
    id result = value;
    if(converterName) {
        id<MFBindingConverterProtocol> converter = [[MFBeanLoader getInstance] getBeanWithKey:converterName];
        if(formViewModelToControl) {
            result = [converter convertValueFromViewModelToControl:value];
        }
        else {
            result = [converter convertValueFromControlToViewModel:value];
        }
    }
    return result;
}

#pragma clang diagnostic pop


@end

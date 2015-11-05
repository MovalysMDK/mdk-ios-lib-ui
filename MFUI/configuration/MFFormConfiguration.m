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


#import "MFFormConfiguration.h"
#import "MFObjectWithBindingProtocol.h"


#import "MFComponentAttributesProtocol.h"
#import "MFComponentAssociatedLabelProtocol.h"

@interface MFFormConfiguration ()

@property (nonatomic, weak) NSObject<MFObjectWithBindingProtocol> *objectWithBinding;

@end

@implementation MFFormConfiguration


#pragma mark - Initialization

+ (instancetype)createFormConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>)objectWithBinding {
    MFFormConfiguration *config = [MFFormConfiguration new];
    config.objectWithBinding = objectWithBinding;
    return config;
}


#pragma mark - Configuration
-(void)createFormConfigurationWithViewDescriptor:(MFBindingViewDescriptor *)viewDescriptor {
    MFBindingDictionary *bindingDictionary = viewDescriptor.viewBinding;
    for(MFOutletBindingKey* outletBindingKey in bindingDictionary.allKeys) {
        UIView *valueAsView = [self.objectWithBinding valueForKey:outletBindingKey.outletName];
        
        if([valueAsView conformsToProtocol:@protocol(MFComponentAttributesProtocol)]) {
            [((id<MFComponentAttributesProtocol>)valueAsView) setControlAttributes:viewDescriptor.controlsAttributes[outletBindingKey.outletName]];
        }
        if([valueAsView conformsToProtocol:@protocol(MFComponentAssociatedLabelProtocol)]) {
            NSString *associatedLabelOutletName = viewDescriptor.associatedLabels[outletBindingKey.outletName];
            if(associatedLabelOutletName) {
                UIView *associatedLabel = [self.objectWithBinding valueForKey:associatedLabelOutletName];
                if(associatedLabel && [associatedLabel isKindOfClass:NSClassFromString(@"MFLabel")]) {
                    ((id<MFComponentAssociatedLabelProtocol>)valueAsView).associatedLabel = (MDKLabel *)associatedLabel;
                }
            }
        }
        
        for(MFBindingDescriptor *itemDescriptor in bindingDictionary[outletBindingKey]) {
            [self.objectWithBinding.bindingDelegate registerComponentBindingProperty:itemDescriptor.componentProperty withViewModelProperty:[itemDescriptor abstractBindedProperty] forComponent:valueAsView withOutletName:outletBindingKey.outletName withMode:itemDescriptor.bindingMode fromBindingSource:itemDescriptor.bindingSource];
        }
    }
}
@end

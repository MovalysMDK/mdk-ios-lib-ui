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

@import MDKControl.Protocol;

#import "UITableViewCell+Binding.h"
#import "MFBindingDelegate.h"
#import "MFObjectWithBindingProtocol.h"

#import "MFComponentAttributesProtocol.h"
#import "MFComponentAssociatedLabelProtocol.h"
#import "UIView+Binding.h"



@implementation UITableViewCell (Binding)

-(void)bindCellFromDescriptor:(MFBindingCellDescriptor *)bindingCellDescriptor onObjectWithBinding:(id<MFObjectWithBindingProtocol>)objectWithBinding {
    MFBindingDictionary *bindingDictionary = bindingCellDescriptor.cellBinding;
    for(MFOutletBindingKey* outletBindingKey in bindingDictionary.allKeys) {
        UIView *valueAsView = [self valueForKey:outletBindingKey.outletName];
        if([valueAsView conformsToProtocol:@protocol(MFComponentAttributesProtocol)] || [valueAsView conformsToProtocol:@protocol(MDKControlAttributesProtocol)] ) {
            NSDictionary *controlAttributes = bindingCellDescriptor.controlsAttributes[outletBindingKey.outletName];
            if(!controlAttributes) {
                controlAttributes = @{};
            }
            [((id<MFComponentAttributesProtocol>)valueAsView) setControlAttributes:controlAttributes];
        }
        if([valueAsView conformsToProtocol:@protocol(MFComponentAssociatedLabelProtocol)] || [valueAsView conformsToProtocol:@protocol(MDKControlAssociatedLabelProtocol)] ) {
            NSString *associatedLabelOutletName = bindingCellDescriptor.associatedLabels[outletBindingKey.outletName];
            if(associatedLabelOutletName) {
                UIView *associatedLabel = [self valueForKey:associatedLabelOutletName];
                if(associatedLabel && [associatedLabel isKindOfClass:NSClassFromString(@"MDKLabel")]) {
                    ((id<MFComponentAssociatedLabelProtocol>)valueAsView).associatedLabel = (MDKLabel *)associatedLabel;
                }
            }
        }
        
        for(MFBindingDescriptor *itemDescriptor in bindingDictionary[outletBindingKey]) {
            [valueAsView setBindedName:itemDescriptor.abstractBindedProperty];
            [objectWithBinding.bindingDelegate registerComponentBindingProperty:itemDescriptor.componentProperty withViewModelProperty:[itemDescriptor abstractBindedProperty] forComponent:valueAsView withOutletName:outletBindingKey.outletName withMode:itemDescriptor.bindingMode withBindingKey:[bindingCellDescriptor generatedBindingKey] withIndexPath:[bindingCellDescriptor cellIndexPath] fromBindingSource:itemDescriptor.bindingSource withConverterName:bindingCellDescriptor.converters[outletBindingKey.outletName]];
        }
    }
}



@end
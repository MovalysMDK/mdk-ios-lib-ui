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


#import "UIView+Binding.h"

#import "MFBindingDelegate.h"
#import "MFObjectWithBindingProtocol.h"
#import "MFComponentAttributesProtocol.h"
#import "MFComponentAssociatedLabelProtocol.h"
#import "MFBindingViewDescriptor.h"

#import <objc/runtime.h>

NSString const *bindedNameKey = @"bindedNameKey";


@implementation UIView (Binding)

-(void)bindViewFromDescriptor:(MFBindingViewDescriptor *)bindingViewDescriptor onObjectWithBinding:(id<MFObjectWithBindingProtocol>)objectWithBinding {
    MFBindingDictionary *bindingDictionary = bindingViewDescriptor.viewBinding;
    for(MFOutletBindingKey* outletBindingKey in bindingDictionary.allKeys) {
        UIView *valueAsView = [self valueForKey:outletBindingKey.outletName];
        
        if([valueAsView conformsToProtocol:@protocol(MFComponentAttributesProtocol)]) {
            [((id<MFComponentAttributesProtocol>)valueAsView) setControlAttributes:bindingViewDescriptor.controlsAttributes[outletBindingKey.outletName]];
        }
        if([valueAsView conformsToProtocol:@protocol(MFComponentAssociatedLabelProtocol)]) {
            NSString *associatedLabelOutletName = bindingViewDescriptor.associatedLabels[outletBindingKey.outletName];
            if(associatedLabelOutletName) {
                UIView *associatedLabel = [self valueForKey:associatedLabelOutletName];
                if(associatedLabel && [associatedLabel isKindOfClass:NSClassFromString(@"MFLabel")]) {
                    ((id<MFComponentAssociatedLabelProtocol>)valueAsView).associatedLabel = (MDKLabel *)associatedLabel;
                }
            }
        }
        
        //FIXME: Voir si y a besoin d'une boucle, et pourquoi affectation
        for(MFBindingDescriptor *itemDescriptor in bindingDictionary[outletBindingKey]) {
            [self setBindedName:itemDescriptor.abstractBindedProperty];
            [objectWithBinding.bindingDelegate registerComponentBindingProperty:itemDescriptor.componentProperty withViewModelProperty:[itemDescriptor abstractBindedProperty] forComponent:valueAsView withOutletName:outletBindingKey.outletName withMode:itemDescriptor.bindingMode withBindingKey:[bindingViewDescriptor generatedBindingKey] withIndexPath:[bindingViewDescriptor viewIndexPath] fromBindingSource:itemDescriptor.bindingSource withConverterName:bindingViewDescriptor.converters[outletBindingKey.outletName]];
        }
        [valueAsView didBinded];
    }
}

-(void)didBinded {
    //Does nothing
}

- (void)setBindedName:(NSString *)bindedName {
    objc_setAssociatedObject(self, &bindedNameKey, bindedName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)bindedName {
    return objc_getAssociatedObject(self, &bindedNameKey);
}

@end

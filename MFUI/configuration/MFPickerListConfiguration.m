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

#import "MFPickerListConfiguration.h"
#import "MFObjectWithBindingProtocol.h"

const NSString *SELECTEDITEM_PICKERLIST_DESCRIPTOR = @"SELECTEDITEM_PICKERLIST_DESCRIPTOR";
const NSString *LISTITEM_PICKERLIST_DESCRIPTOR = @"LISTITEM_PICKERLIST_DESCRIPTOR";


@interface MFPickerListConfiguration ()

@property (nonatomic, weak) id<MFObjectWithBindingProtocol> objectWithBinding;

@end

@implementation MFPickerListConfiguration


#pragma mark - Initialization

+(instancetype)createPickerListConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>)objectWithBinding {
    MFPickerListConfiguration *pickerListConfiguration = [MFPickerListConfiguration new];
    pickerListConfiguration.objectWithBinding = objectWithBinding;
    [pickerListConfiguration initializeStructure];
    return pickerListConfiguration;
}

-(void)createPickerListItemWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor {
    [[self currentStructure] setObject:viewDescriptor forKey:SELECTEDITEM_PICKERLIST_DESCRIPTOR];
}

-(void)createPickerSelectedItemWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor {
    [[self currentStructure] setObject:viewDescriptor forKey:LISTITEM_PICKERLIST_DESCRIPTOR];
}


-(void) initializeStructure {
    if(!self.objectWithBinding.bindingDelegate.structure) {
        self.objectWithBinding.bindingDelegate.structure = [NSMutableDictionary new];
    }
}

#pragma mark - Utils

-(NSMutableDictionary *) currentStructure {
    return self.objectWithBinding.bindingDelegate.structure;
}
@end

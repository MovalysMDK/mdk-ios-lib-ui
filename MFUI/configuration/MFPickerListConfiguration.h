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

#import <Foundation/Foundation.h>
#import "MFBindingViewDescriptor.h"
#import "MFBindingCellDescriptor.h"

@protocol MFObjectWithBindingProtocol;

FOUNDATION_EXPORT const NSString *SELECTEDITEM_PICKERLIST_DESCRIPTOR;
FOUNDATION_EXPORT const NSString *LISTITEM_PICKERLIST_DESCRIPTOR;


/*!
 * @class MFPickerListConfiguration
 * @brief This class allows to create a configuration for MDK PickerList
 * @discussion You should always use a MFPickerListConfiguration to configure your MDK PickerList component
 */
@interface MFPickerListConfiguration : NSObject

/*!
 * @brief Initializes a table configuration object with the specified object with binding, and
 * returns its to the caller.
 * @param objectWithBinding An object that conformas the MFObjectWithBindingProtocol protocol
 * @return The built MFTableConfiguration instance
 * @see MFObjectWithBindingProtocol
 */
+(instancetype) createPickerListConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>) objectWithBinding;

/*!
 * @brief Creates a picker list item in the picker list configured by this object
 * @discussion This method must be called by PickerList Data delegate
 * @param cellDescriptor The descriptor that describes the cell to add
 * @see MFBindingCellDescriptor
 */
-(void)createPickerListItemWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor;

/*!
 * @brief Creates the picker selected item in the picker list configured by this object
 * @discussion This method must be called by PickerList Data delegate
 * @param viewDescriptor The descriptor that describes the view to add
 * @see MFBindingViewDescriptor
 */
-(void)createPickerSelectedItemWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor;
    
@end

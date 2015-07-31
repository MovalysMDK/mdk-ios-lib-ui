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
#import "MFPickerListItemBindingDelegate.h"
#import "MFPickerSelectedItemBindingDelegate.h"

/*!
 * @class MFPickerListExtention
 * @brief This class is an extension for the PickerList component
 */
@interface MFPickerListExtension : NSObject

/*!
 * @brief The list item data delegate of the PickerList
 */
@property (nonatomic, strong) MFPickerListItemBindingDelegate *listItemBindingDelegate;

/*!
 * @brief The selected item data delegate of the PickerList
 */
@property (nonatomic, strong) MFPickerSelectedItemBindingDelegate *selectedItemBindingDelegate;

/*!
 * @brief The picker values key
 */
@property (nonatomic, strong) NSString* pickerValuesKey;

/**
 * @brief Indicates if the component should display the searchBar
 */
@property (nonatomic) BOOL hasSearch;

/**
 * @brief the filter to use when search is available
 */
@property (nonatomic, strong) id<MFPickerListFilterProtocol> filter;

@end

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

@import MDKControl.ControlPickerList;

#import <Foundation/Foundation.h>
#import "MFCommonFormProtocol.h"

@interface MFPickerListItemBindingDelegate : MDKPickerListBaseDelegate <MFCommonFormProtocol, UISearchBarDelegate, MDKUIPickerListDataProtocol>

#pragma mark - Methods

/*!
 * @brief Initializes and returns an new instance of MFPickerListItemBindingDelegate
 * @param pickerList The pickerList reference to set to this bindingDelegate
 * @return A new instance of MFPickerListItemBindingDelegate
 */
- (instancetype)initWithPickerList:(MDKUIPickerList *)pickerList;


#pragma mark - Properties

/*!
 * @brief Indicates if the picker has search
 */
@property (nonatomic) BOOL hasSearch;


/*!
 * @brief Indicates if the picker has search
 */
@property (nonatomic, strong) id<MDKPickerListFilterProtocol> filter;

-(void) willDisplayPickerListView;

@end

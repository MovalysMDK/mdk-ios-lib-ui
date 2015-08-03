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

#import "MFUIOldBaseComponent.h"
#import "MFBindingViewAbstract.h"
#import "MFPickerListTableView.h"
#import "MFControlChangesProtocol.h"

@class MFUIBaseListViewModel;

IB_DESIGNABLE
@interface MFPickerList : MFUIOldBaseComponent <UIGestureRecognizerDelegate, MFControlChangesProtocol>

@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, strong) MFPickerListTableView *pickerListTableView;


-(NSArray *) getValues;

@end

/*!
 * @protocol MFPickerListFilterProtocol
 * @brief A protocol that identfy a PickerList filter
 * @discussion The class that implements this protocol can filter a list of picker items bu
 * implementing the filterItems:withString: method
 */
@protocol MFPickerListFilterProtocol <NSObject>

/*!
 * @brief Filters a given array of items with a given string
 * @param items An array of items
 * @param string The string used to filter
 * @return An array of filtered items
 */
@required
-(NSArray *)filterItems:(NSArray *)items withString:(NSString *)string;

@end


@interface MFPickerListDefaultFilter : NSObject <MFPickerListFilterProtocol>

@end

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
#import "MFBindingCellDescriptor.h"
#import "MFBindingViewDescriptor.h"

@protocol MFObjectWithBindingProtocol;

FOUNDATION_EXPORT const NSString *SECTION_ORDER_KEY;
FOUNDATION_EXPORT const NSString *CURRENT_SECTION_KEY;
FOUNDATION_EXPORT const NSString *CELL_1D_DESCRIPTOR;
FOUNDATION_EXPORT const NSString *SECTION_HEADER_VIEW_2D_DESCRIPTOR;
FOUNDATION_EXPORT const NSString *CELL_FIXEDLIST_DESCRIPTOR;


/*!
 * @class MFTableConfiguration
 * @brief This class allows to create a configuration for MDK TableView-form
 * @discussion You should always use a MFTableConfiguration to configure your MDK ViewController
 * that presents a UITableView
 */
@interface MFTableConfiguration : NSObject

#pragma mark - Initialization
/*!
 * @brief Initializes a table configuration object with the specified object with binding, and
 * returns its to the caller.
 * @param objectWithBinding An object that conformas the MFObjectWithBindingProtocol protocol
 * @return The built MFTableConfiguration instance
 * @see MFObjectWithBindingProtocol
 */
+(instancetype) createTableConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>) objectWithBinding;

#pragma mark - Configuration
/*!
 * @brief Creates a section in the TableView configured by this object.
 * @discussion Be careful : the given name of the section should be unique in this configuration
 * @param tableSectionName The name of the new section
 */
-(void) createTableSectionWithName:(NSString *)tableSectionName;

/*!
 * @brief Creates a cell in the TableView configured by this object.
 * @discussion The cell is add in the last created section.
 * @param cellDecriptor The descriptor that describes the cell to add
 * @see MFBindingCellDescriptor
 */
-(void) createTableCellWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor;

/*!
 * @brief Creates a cell in the TableView configured by this object.
 * @discussion This method must not be called to configure a Simple TableView Form 
 * but only for a FormList (1D)
 * @param cellDecriptor The descriptor that describes the cell to add
 * @see MFBindingCellDescriptor
 */
-(void) create1DTableCellWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor;

/*!
 * @brief Creates a headerView section in the TableView configured by this object.
 * @discussion This method must not be called to configure a Simple TableView Form
 * but only for a FormList (2D)
 * @param viewDescriptor The descriptor that describes the view to add
 * @see MFBindingViewDescriptor
 */
-(void)create2DTableHeaderViewWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor;

/*!
 * @brief Creates a cell in the TableView configured by this object.
 * @discussion This method must be called by FixedList Data delegate
 * @param cellDecriptor The descriptor that describes the cell to add
 * @see MFBindingCellDescriptor
 */
-(void)createFixedListTableCellWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor;


/*!
 * @brief Creates a cell in the TableView configured by this object.
 * @discussion This method must be called by FixedList Data delegate
 * @param cellDecriptor The descriptor that describes the cell to add
 * @see MFBindingCellDescriptor
 */
-(void)createPickerListItemWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor;

@end

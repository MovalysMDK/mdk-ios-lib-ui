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
#import "MFBindingDictionary.h"

/*!
 * @class MFBindingCellDescriptor
 * @brief This class describes a MDK Form cell.
 * @discussion This class is used to present a cell on table-mode forms.
 * It declares its height, its storyboard-identifier, its binding ...
 * @see MFBindingDictionary
 */
@interface MFBindingCellDescriptor : NSObject <MFBindingConsistencyProtocol>

#pragma mark - Properties
/*!
 * @brief The storyboard-identifer of the tableViewCell described by this object
 */
@property (nonatomic, strong) NSString *cellIdentifier;

/*!
 * @brief The height of the tableViewCell described by this object
 */
@property (nonatomic, strong) NSNumber *cellHeight;

/*!
 * @brief The binding to the TableViewCell described by this object to some ViewModel properties
 */
@property (nonatomic, strong) MFBindingDictionary *cellBinding;

/*!
 * @brief The indexPath of the TableViewCell described by this object.
 */
@property (nonatomic, strong) NSIndexPath *cellIndexPath;

/*!
 * @brief The attributes to set on controls
 */
@property (nonatomic, strong) NSDictionary *controlsAttributes;

/*!
 * @brief The labels/controls associations
 */
@property (nonatomic, strong) NSDictionary *associatedLabels;

#pragma mark - Initialization
/*!
 * @brief Initializes a new cell descriptor object with the given identifer and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier;

/*!
 * @brief Initializes a new cell descriptor object with the given identifer  and the given binding,
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param cellBinding The binding dictionary of the TableViewCell described by this object.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellBinding:(MFBindingDictionary *)cellBinding;

/*!
 * @brief Initializes a new cell descriptor object with the given identifer and the given binding as format,
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param format,...  A variadic parameter that describes the binding of the TableViewCell described by this object.
 * It will be converted to this bindingDictionary property.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellBindingFormat:(NSString *)format,... NS_REQUIRES_NIL_TERMINATION;

/*!
 * @brief Initializes a new cell descriptor object with the given identifer and the given cell height
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param cellHeight The height of the TableViewCell described by this object
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight;

/*!
 * @brief Initializes a new cell descriptor object with the given identifer, the given cell height and the 
 * given binding dictionary
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param cellHeight The height of the TableViewCell described by this object
 * @param cellBinding The binding dictionary of the TableViewCell described by this object.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight withCellBinding:(MFBindingDictionary *)cellBinding;

/*!
 * @brief Initializes a new cell descriptor object with the given identifer, the given cell height and the given binding as format
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param cellHeight The height of the TableViewCell described by this object
 * @param format,...  A variadic parameter that describes the binding of the TableViewCell described by this object.
 * It will be converted to this bindingDictionary property.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight withCellBindingFormat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Unique bindingKey

/*!
 * @brief Generated a unique bindingKey-string-format associated to the cell described by this object.
 * @return A unique bindingKey as NSString object associated to the cell described by this object.
 */
-(NSString *) generatedBindingKey;
@end

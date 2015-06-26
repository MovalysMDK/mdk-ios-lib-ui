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

@interface MFBindingViewDescriptor : NSObject <MFBindingConsistencyProtocol>

#pragma mark - Properties
/*!
 * @brief The binding to the TableViewCell described by this object to some ViewModel properties
 */
@property (nonatomic, strong) MFBindingDictionary *viewBinding;

/*!
 * @brief The attributes to set on controls
 */
@property (nonatomic, strong) NSDictionary *controlsAttributes;

/*!
 * @brief The labels/controls associations
 */
@property (nonatomic, strong) NSDictionary *associatedLabels;

#pragma mark - Methods

/*!
 * @brief Initializes a new cell descriptor object with the given identifer and the given binding as format,
 * and returns it to the caller
 * @param identifier The storyboard-identifier of the TableViewCell described by this object.
 * @param format,...  A variadic parameter that describes the binding of the TableViewCell described by this object.
 * It will be converted to this bindingDictionary property.
 * @return The built MFBindingCellDescriptor instance.
 */
+(instancetype) viewDescriptorWithCellBindingFormat:(NSString *)format,... NS_REQUIRES_NIL_TERMINATION;

@end

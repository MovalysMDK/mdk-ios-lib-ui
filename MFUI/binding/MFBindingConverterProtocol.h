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

/*!
 * @protocol MFBindingConverterProtocol
 * @brief A protocol that describes a binding converter
 */
@protocol MFBindingConverterProtocol <NSObject>

/*!
 * @brief Converts a value that comes from ViewModel to a value for a Control
 * @param valueFromViewModel The value that comes from ViewModel to convert
 * @return The converted value for a Control
 */
-(id)convertValueFromViewModelToControl:(id)valueFromViewModel;

/*!
 * @brief Converts a value that comes from a Control to a value for a ViewModel
 * @param valueFromControl The value that comes from a Control to convert
 * @return The converted value for ViewModel
 */
-(id)convertValueFromControlToViewModel:(id)valueFromControl;
@end

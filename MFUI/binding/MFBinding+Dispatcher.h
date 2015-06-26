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

#import "MFBinding.h"

/*!
 * @category Dispatcher
 * @brief A category on the MFBinding object that applies the binding events
 * (Form to VM, and VM to form).
 */
@interface MFBinding (Dispatcher)

#pragma mark - Methods

/*!
 * @brief Dispatches a given value to a component.
 * @param value The value to set in a component
 * @param component The component that need tp bu updated with the new value
 * @param object The object that manages binding
 * @param indexPath The fictive indexPath of the component to bind
 */
-(void)dispatchValue:(id)value fromComponent:(UIView *)component onObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/*!
 * @brief Dispatches a given value to a view model property.
 * @param value The new value to set in the ViewModel
 * @param propertyName The view model property name to uodate.
 */
-(void)dispatchValue:(id)value fromPropertyName:(NSString *)propertyName fromSource:(MFBindingSource)bindingSource;

/*!
 * @brief Dispatches a given value to a view model property.
 * @param value The new value to set in the ViewModel
 * @param propertyName The view model property name to uodate.
 * @param indexPath The fictive indexPath of the component to bind
 */
-(void)dispatchValue:(id)value fromPropertyName:(NSString *)propertyName atIndexPath:(NSIndexPath *)indexPath fromSource:(MFBindingSource)bindingSource;

@end

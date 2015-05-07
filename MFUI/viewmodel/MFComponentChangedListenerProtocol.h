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


@protocol MFComponentChangedListenerProtocol <NSObject>

#pragma mark - Methods

/*!
 * @brief This methods is called when the value of a component has changed on the form implementing this protocol. 
 * @param bindingKey The key used in the binding to bind the component that has changed to a binded property on a ViewModel
 * @param indexPath the indexPath of the cell container of the component that has changed, used to identify which viewModel
 * should be updated
 */
-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath;

@end

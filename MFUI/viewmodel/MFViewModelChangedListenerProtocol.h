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
//
//  MFViewModelChangedListenerProtocol.h
//  MFUI
//
//




@protocol MFUIBaseViewModelProtocol;

@protocol MFViewModelChangedListenerProtocol <NSObject>

#pragma mark - Methods

/*!
 * @brief This method is called when a binded property has changed on a View Model
 * @param keyPath The keyPath of the changed property 
 * @param sender The ViewModel on which the property with the given keyPath has changed
 */
-(void)dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)keyPath sender:(id<MFUIBaseViewModelProtocol>)sender;

@end

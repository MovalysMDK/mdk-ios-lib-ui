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
//  MFUIElementCommonProtocol.h
//  MFUI
//
//



/**
 Protocol shared by all UI elements (Cell, Control, Controller, ...)
 **/
@protocol MFUIElementCommonProtocol <NSObject>

#pragma mark - Methods

/**
 * @brief Set the main value for this component
 * @param value The value to set
 */
@optional
-(void) setValue:(NSString *) value;

/**
 * @brief Returns the main value of this component
 * @return The value of the component
 */
@optional
-(NSString *) getValue;



@end

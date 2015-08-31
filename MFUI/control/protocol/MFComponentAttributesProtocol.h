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
 * @protocol MFComponentAttributesProtocol
 * @brief This protocol provides a property to hold control attributes
 */

//FIXME: Rename en control
@protocol MFComponentAttributesProtocol <NSObject>

/*!
 * @brief The control attributes property
 */
@property (nonatomic, strong) NSDictionary *controlAttributes;


/*!
 * @brief Adds a control attribute
 * @param controlAttribute A control attribute to add
 * @param key The key used to add the control attribute
 */
-(void)addControlAttribute:(id)controlAttribute forKey:(NSString *)key;

@end

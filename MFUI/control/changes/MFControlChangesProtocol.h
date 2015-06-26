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
#import "MFControlChangedTargetDescriptor.h"

/*!
 * @protocol MFControlChangesProtocol
 * @brief This protocol identifies a control that can customize its changes events
 */
@protocol MFControlChangesProtocol <NSObject>

/*!
 * @brief A dictionary that contains key/value paris of a sub-component associated
 * to the MFControlChangedTargetDescriptor object to use to customize the event.
 * @see MFControlChangedTargetDescriptor
 */
@property (nonatomic, strong) NSDictionary *targetDescriptors;

/*!
 * @brief This method should be called by sub-components to customize the target event
 * @param sender The sender of the event
 */
@required
-(void) valueChanged:(UIView *)sender;

@end

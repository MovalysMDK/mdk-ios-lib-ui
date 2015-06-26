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
#import "MFListenerDescriptor.h"


/*!
 * @class MFListenerDescriptorManager
 * @brief This class manages a collection of listener descriptors
 * @discussion It used by object that can listen (then that conform MFObjectWithListenerProtocol)
 * @see MFObjectWithListenerProtocol, MFListenerDescriptor
 */
@interface MFListenerDescriptorManager : NSObject

#pragma mark - Methods
/*!
 * @brief Adds a new listener descriptor to this manager
 * @param listenerDescriptor The listener descriptor to add
 */
-(void) addListenerDescriptor:(MFListenerDescriptor *)listenerDescriptor;

/*!
 * @brief Adds an array of listener descriptors to this manager
 * @param listenerDescriptors An array of listener descriptors to add to this manager
 */
-(void) addListenerDescriptors:(NSArray *)listenerDescriptors;

/*!
 * @brief Retrieves an array of listener descriptors corresponding to a given event type
 * already registered in this manager.
 * @param eventType The event type value you want to retrieve an array of listener descriptors
 * @return An array of listener descriptors corresponding to the givent event type value
 */
-(NSArray *)listenerDescriptorsForEventType:(MFListenerEventType)eventType;

@end

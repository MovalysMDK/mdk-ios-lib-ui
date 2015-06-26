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

@class MFUIBaseViewModel;

/*!
 * @class MFViewModelConfiguration
 * @brief This class allows to create a configuration for a MDK ViewModel
 */
@interface MFViewModelConfiguration : NSObject

#pragma mark - Initialization

/*!
 * @brief Initializes a new View Model Configuration instance with the specified ViuewModel and 
 * returns it to the caller
 * @param viewModel the ViewModel to configure
 * @return The MFViewModelConfiguration built instance
 * @see MFUIBaseViewModel
 */
+(instancetype) configurationForViewModel:(MFUIBaseViewModel *)viewModel;

#pragma mark - Configuraton

/*!
 * @brief Adds a Listener Descriptor to the ViewModel to configure with this object
 * @param listenerDescriptor the listener descriptor to add
 * @see MFListenerDescriptor
 */
-(void) addListenerDescriptor:(MFListenerDescriptor *)listenerDescriptor;

/*!
 * @brief Adds an array of Listener Descriptors to the ViewModel to configure with this object
 * @param listenerDescriptors An array of listener descriptors to add
 */
-(void) addListenerDescriptors:(NSArray *)listenerDescriptors;

@end





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
//  MFOrientationChangedDelegate.h
//  MFUI
//
//


#import "MFOrientationChangedProtocol.h"

@interface MFOrientationChangedDelegate : NSObject

#pragma  mark - Properties

/**
 * @brief The object that declares a MFOrientationChangedDelegate
 */
@property (nonatomic, weak) id<MFOrientationChangedProtocol> listener;

#pragma mark - Methods 

/**
 * @brief Custom contrcuteur with listener initialization
 * @param The listener of the orientation change
 * @return the built object
 */
-(id) initWithListener:(id<MFOrientationChangedProtocol>) listener;

/**
 * @brief A common block of code that register the orientation changes on the listener
 */
-(void)registerOrientationChanges;

/**
 * @brief A common block of code that unregister the orientation changes on the listener
 */
-(void)unregisterOrientationChanges;

/**
 * @brief Indicates if the current orientation change is a change of type : Portrait <--> Landscape.
 * @return YES if the orientation change is of type Portrait <--> Landscape
 */
-(BOOL)checkIfOrientationChangeIsAScreenNormalRotation;

@end

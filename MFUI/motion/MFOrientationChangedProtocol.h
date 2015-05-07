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
//  MFOrientationChangedProtocol.h
//  MFUI
//
//



@protocol MFOrientationChangedProtocol <NSObject>

#pragma mark - Properties

/*!
 * @brief The property used to save the current orientation of the device
 */
@property (nonatomic) UIDeviceOrientation currentOrientation;


#pragma mark - Methods

/*!
 * @brief The method that should be used to register the orientation changes using a @class(MFOrientationChangedDelegate). 
 * This method in required.
 */
@required
-(void) registerOrientationChange;

/*!
 * @brief The method that should be used to register the orientation changes using a @class(MFOrientationChangedDelegate).
 * This method in required.
 */
@optional
-(void) unregisterOrientationChange;


/*!
 * @brief The selector that should be called by a @class(MFOrientationChangedDelegate) when orientation changed?.
 * This method in required.
 * @param The notification associated to an orientation change
 */
@required
-(void) orientationDidChanged:(NSNotification *)notification;


@end

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
//  MFPosition.h
//  MFUI
//
//


#import <CoreLocation/CoreLocation.h>

#import "MFPositionDelegate.h"
#import "MFUIComponentProtocol.h"
#import "MFUIOldBaseComponent.h"
#import "MFTextField.h"
#import "MFDoubleTextField.h"
#import "MFControlChangesProtocol.h"

/*!
 * @class MFPosition
 * @brief Custom control to display geo-position (latitude and longitude).
 * @discussion
 */
@interface MFPosition : MFUIOldBaseComponent<MFUIComponentProtocol, CLLocationManagerDelegate, MFControlChangesProtocol>

#pragma mark - Properties
/*!
 * @brief The location property of the position component
 */
@property(nonatomic, strong) CLLocation *location;

/*!
 * @brief The textfield to display latitude
 */
@property(nonatomic, strong) MFDoubleTextField *latitude;

/*!
 * @brief The textfield to display longitude
 */
@property(nonatomic, strong) MFDoubleTextField *longitude;

@end



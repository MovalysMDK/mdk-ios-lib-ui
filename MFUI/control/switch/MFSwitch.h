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
//  MFSwitch.h
//  MFUI
//
//

#import "MFUIBaseComponent.h"

IB_DESIGNABLE

/**
 * @class MFSwitch
 * @brief The MDK iOS Switch component
 * @discussion This components allows two states : enabled or disabled. It is similar
 * to a checkbox component.
 */
@interface MFSwitch : MFUIBaseComponent

#pragma mark - Properties

/**
 * @brief Underlying component.
 */
@property (nonatomic, strong) UISwitch *innerSwitch;


#pragma mark - Inspectable Properties

@property (nonatomic) IBInspectable BOOL IB_uState;

@property (nonatomic, strong) IBInspectable UIColor *IB_onTintColor;

@end

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

#import "MFSwitch+UISwitchForwarding.h"

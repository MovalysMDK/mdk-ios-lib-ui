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
//  MFSwitch+UISwitchForwarding.h
//  MFUI
//
//

#import "MFSwitch.h"

@interface MFSwitch (UISwitchForwarding)

// forwarded properties to inner UISwitch
@property(nonatomic, getter=isOn) BOOL on;
@property(nonatomic, retain) UIColor *onTintColor;
@property(nonatomic, retain) UIColor *tintColor;
@property(nonatomic, retain) UIColor *thumbTintColor;
@property(nonatomic, retain) UIImage *onImage;
@property(nonatomic, retain) UIImage *offImage;

// forwarded methods to inner UISwitch
- (id)initWithFrame:(CGRect)frame;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

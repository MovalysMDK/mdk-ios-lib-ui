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
//  UIPickerListSelectionIndicator.h
//  MFUI
//
//


/*!
 * @class MFPickerListSelectionIndicator
 * @brief An UIView to indicate the selected row in MFPickerList
 * @discussion Should be non-ARC
 */
@interface MFPickerListSelectionIndicator : UIView

#pragma mark - Methods

/*!
 * @brief Custom init
 * @param  frame the Frame of the viex
 * @param mainColor The color that should have the indicator view
 * @return The built view
 */
- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)mainColor;

@end

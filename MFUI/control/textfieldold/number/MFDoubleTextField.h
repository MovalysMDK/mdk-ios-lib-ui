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
//  MFDoubleTextField.h
//  MFUI
//
//

#import "MFUIError.h"

#import "MFRegularExpressionTextField.h"

/*
 Open a dialog to allow user to write an double number.
 Before validating the input double, this control checks control's value is a well formed double number.
 */

@interface MFDoubleTextField : MFRegularExpressionTextField

/**
 * @brief The minimum number of digits in the integer part of this double number
 *
 */

@property (nonatomic, strong) NSString *integerPartMinDigits;


/**
 * @brief The maximum number of digits in the integer part of this double number
 *
 */

@property (nonatomic, strong) NSString *integerPartMaxDigits;

/**
 * @brief The minimum number of digits in the decimal part of this double number
 *
 */

@property (nonatomic, strong) NSString *decimalPartMinDigits;

/**
 * @brief The maximum number of digits in the decimal part of this double number
 *
 */

@property (nonatomic, strong) NSString *decimalPartMaxDigits;

/**
 * @brief Generate the regex to control
 *
 */
- (void)createPattern;

@end

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
//  MFDatePicker.h
//  MFUI
//
//

#import "MFUIMotion.h"
#import "MFUIProtocol.h"


#import "MFUIOldBaseComponent.h"

/**
 * @class MFNumberPicker
 * @brief The framework number picker component
 * @discussion This component display a picker aimed to select a n interger value.
 */
@interface MFNumberPicker : MFUIOldBaseComponent <MFDefaultConstraintsProtocol, UITextFieldDelegate>

#pragma mark - Properties

/**
 * @brief The current selected value
 */
@property (nonatomic) NSInteger currentValue;

/**
 * @brief The minimal value
 */
@property (nonatomic) NSInteger minimalValue;

/**
 * @brief The maximal value
 */
@property (nonatomic) NSInteger maximalValue;

/**
 * @brief The step betweens two values
 */
@property (nonatomic) NSInteger step;

@end




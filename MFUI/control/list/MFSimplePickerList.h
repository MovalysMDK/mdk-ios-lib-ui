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


#import "MFUIUtils.h"
#import "MFUIMotion.h"

#import "MFUIOldBaseComponent.h"
#import "MFButton.h"
#import "MFEnumExtension.h"
#import "MFControlChangesProtocol.h"

#pragma mark - Constants
FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_ENUM_CLASS_NAME_KEY;

IB_DESIGNABLE
@interface MFSimplePickerList : MFUIOldBaseComponent <UIGestureRecognizerDelegate, MFOrientationChangedProtocol, UIPickerViewDataSource, UIPickerViewDelegate, MFControlChangesProtocol>

#pragma mark - Properties
/*!
 * @brief The picker that allows to choose an enum
 */
@property (nonatomic, strong) UIPickerView *pickerView;

/*!
 * @brief The button displays a selected date and allow to display the picker to choose another one
 */
@property (nonatomic, strong) MFButton *pickerButton;

/*!
 * @brief The current selected date
 */
@property (nonatomic) int currentEnumValue;

/*!
 * @brief The view container of the pickerView
 */
@property (nonatomic, strong) UIScrollView *modalPickerView;

/*!
 * @brief The button to confirm the current choice
 */
@property (nonatomic, strong) UISegmentedControl *confirmButton;

/*!
 * @brief The button to cancel the current choice
 */
@property (nonatomic, strong) UISegmentedControl *cancelButton;

/*!
 * @brief Indicates if th pickerView is currently showing
 */
@property (nonatomic) BOOL isShowing;

/*!
 * @brief the manipuled data of the component
 */
@property (nonatomic, strong) id<MFEnumHelperProtocol> data;

/*!
 * @brief The delegate used when orientation change
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;

/*!
 * @brief The enum extension for this component
 */
@property (nonatomic, strong) MFEnumExtension *mf;

@end




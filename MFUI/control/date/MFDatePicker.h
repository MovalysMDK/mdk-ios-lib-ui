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

#import "MFUIBaseComponent.h"
//#import "MFButton.h"
#import "MFOrientationChangedDelegate.h"
#import "MFUILabel.h"
#import "MFDefaultConstraintsProtocol.h"


IB_DESIGNABLE
/**
 * @class MFDatePicker
 * @brief The date framework component
 * @discussion This components allows to choose and display a date, a time, or a datetime.
 */
@interface MFDatePicker : MFUIBaseComponent <MFOrientationChangedProtocol, MFDefaultConstraintsProtocol>


#pragma mark - Custom enumeration (edit mode options)
/**
 * @brief This structure defines the mode of the date Picker
 * MFDatePickerModeDate : The view displayed is a date Picker
 * MFDatePickerModeTime : The view displayed is a time Picker
 * MFDatePickerModeDateTime : The view displayed is a dateTime Picker
 */
typedef enum {
    MFDatePickerModeDate = 0,
    MFDatePickerModeTime = 1,
    MFDatePickerModeDateTime = 2
} MFDatePickerMode;


#pragma mark - Properties
/**
 * @brief The picker that allows to choose a date
 */
@property (nonatomic, strong) UIDatePicker *datePicker;

/**
 * @brief The button displays a selected date and allow to display the picker to choose another one
 */
@property (nonatomic, strong) UIButton *dateButton;

/**
 * @brief The current selected date
 */
@property (nonatomic, strong) NSDate *currentDate;

/**
 * @brief The view container of the pickerView
 */
@property (nonatomic, strong) UIScrollView *modalPickerView;

/**
 * @brief The button to confirm the current choice
 */
@property (nonatomic, strong) UISegmentedControl *confirmButton;

/**
 * @brief The button to cancel the current choice
 */
@property (nonatomic, strong) UISegmentedControl *cancelButton;

/**
 * @brief Indicates if th pickerView is currently showing
 */
@property (nonatomic) BOOL isShowing;

/**
 * @brief Defines the mode of the picker to display
 */
@property (nonatomic) MFDatePickerMode datePickerMode;

/**
 * @brief the manipuled data of the component
 */
@property (nonatomic, strong) NSDate *data;

/**
 * @brief The delegate used when orientation change
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;


#pragma mark - IBInspectable properties

@property (nonatomic, strong) IBInspectable NSString *IB_uDateString;

@property (nonatomic) IBInspectable NSInteger IB_borderWidth;

@property (nonatomic) IBInspectable NSInteger IB_cornerRadius;

@property (nonatomic) IBInspectable NSInteger IB_textAlignment;

@property (nonatomic) IBInspectable NSInteger IB_textSize;


@end




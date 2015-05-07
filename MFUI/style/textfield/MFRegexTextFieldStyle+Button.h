
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

#import "MFRegexTextFieldStyle.h"
#import "MFRegexTextField.h"

/*!
 * @brief This constant defines the sides size of the action button
 * The default value is 22
 */
FOUNDATION_EXPORT NSInteger REGEX_BUTTON_SQUARE_SIZE;

/*!
 * @brief The key to identify the action button width constraint
 * This constraint defines a constant width with value of "22" (REGEX_BUTTON_SQUARE_SIZE)
 * for the action button
 */
FOUNDATION_EXPORT const NSString * REGEX_BUTTON_WIDTH_CONSTRAINT;

/*!
 * @brief The key to identify the action button height constraint
 * This constraint defines a constant height with value of "22" (REGEX_BUTTON_SQUARE_SIZE)
 * for the action button
 */
FOUNDATION_EXPORT const NSString * REGEX_BUTTON_HEIGHT_CONSTRAINT;

/*!
 * @brief The key to identify the action button centerY constraint
 * This constraint defines that the action button has the same centerY value
 * as its parent (MFRegexTextField).
 */
FOUNDATION_EXPORT const NSString * REGEX_BUTTON_CENTER_Y_CONSTRAINT;

/*!
 * @brief The key to identify the action button right constraint
 * This constraint defines that the action button has the right side aligned with 
 * its parent with an offset of "2" (DEFAULT_ACCESSORIES_MARGIN)
 */
FOUNDATION_EXPORT const NSString * REGEX_BUTTON_RIGHT_CONSTRAINT;


/*!
 * @class MFRegexTextFieldStyle+Button
 * @brief This category adds the necessary methods to manage an action button
 * on the MFRegexTextField component.
 */
@interface MFRegexTextFieldStyle (Button)

#pragma mark - Methods

/*!
 * @brief This methods allows to customize the default constraints applied
 * by the framework to the action button.
 * @param buttonConstraints A NSDictionary object that contains key/value pairs 
 * as following : the key is a NSString object that identy a unique NSLayoutConstraint 
 * value object.
 * @param component The component on which will be applied the constraints.
 * @return A dictionary that contains some constraints to apply between the action
 * button and the component itself. This dictionary should be the given "buttonsConstraints"
 * dictionary with some constraints potentially modified.
 * @discussion You can retrieve any constraints in the given dictionary with the keys prefixed
 * by "REGEX_BUTTON_"
 */
-(NSDictionary *)customizeButtonConstraints:(NSDictionary *)buttonConstraints onComponent:(MFRegexTextField *)component;


/*!
 * @brief Returns the icon's name that the action button should display
 * @return The icon's name that the action button should display
 */
-(NSString *) accessoryButtonImageName;


@end


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

#import "MFTextFieldStyle.h"
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const NSString * ERROR_VIEW_WIDTH_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_HEIGHT_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_CENTER_Y_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_RIGHT_CONSTRAINT;

FOUNDATION_EXPORT NSInteger DEFAULT_CLEAR_BUTTON_CONTAINER;
FOUNDATION_EXPORT NSInteger DEFAULT_ERROR_VIEW_SQUARE_SIZE;

@class MFTextField;
/*!
 * @class MFTextFieldStyle+ErrorView
 * @brief This category on MFTextFieldStyle defines the necessary methods
 * to customize the errorView of the Text Field component.
 */
@interface MFTextFieldStyle (ErrorView)


#pragma mark - Methods

/*!
 * @brief This method allows to customize the framework-defined constraints for
 * the errorView in the MFTextField component.
 * @param errorViewConstraints A dictionary that contains key/value pair as following :
 * The key is an NSString object that identify a NSLayoutConstrain object value.
 * @param component The component that will aplly the custom constraints
 * @return A Dictionary that contains the constraints to apply on the errorView in the
 * component
 * @discussion Typically, you will modifiy the constraints given by the errorViewConstraints
 * dictionary and return the modified dictionary.
 */
-(NSDictionary *) customizeErrorViewConstraints:(NSDictionary *)errorViewConstraints onComponent:(MFTextField *)component;

@end

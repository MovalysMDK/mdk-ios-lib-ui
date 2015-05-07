
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
@class MFTextField;

FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_WIDTH_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_HEIGHT_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_CENTER_Y_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_LEFT_CONSTRAINT;

/*!
 * @class MFTextFieldStyle+BackgroundView
 * @brief This category on MFTextFieldStyle defines the necessary methods 
 * to customize the backgroundView of the Text Field component.
 */
@interface MFTextFieldStyle (BackgroundView)

#pragma mark - Methods

/*!
 * @brief This method allows to customize the framework-defined constraints for
 * the backgroundView in the MFTextField component.
 * @param backgroundViewConstraints A dictionary that contains key/value pair as following :
 * The key is an NSString object that identify a NSLayoutConstrain object value. 
 * @param component The component that will aplly the custom constraints
 * @return A Dictionary that contains the constraints to apply on the backgroundView in the 
 * component
 * @discussion Typically, you will modifiy the constraints given by the backgroundViewConstraints 
 * dictionary and return the modified dictionary.
 */
-(NSDictionary *)customizeBackgroundViewConstraints:(NSDictionary *)backgroundViewConstraints onComponent:(MFTextField *)component;

@end

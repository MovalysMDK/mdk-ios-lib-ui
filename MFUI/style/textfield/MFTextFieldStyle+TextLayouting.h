
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

/*!
 * @class MFTextFieldStyle+TextLayouting
 * @brief This category on MFTextFieldStyle defines the necessary methods to
 * customize the text rects of the Text Field component following its states.
 */
@interface MFTextFieldStyle (TextLayouting)

#pragma mark - Methods

/*!
 * @brief Defines the text rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the text rect
 * @return A CGrect structure that defines the text rect of the given component.
 */
-(CGRect) textRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/*!
 * @brief Defines the editing rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the editing rect
 * @return A CGrect structure that defines the editing rect of the given component.
 */
-(CGRect) editingRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/*!
 * @brief Defines the clear button rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the clear button rect
 * @return A CGrect structure that defines the clear button rect of the given component.
 */
-(CGRect) clearButtonRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/*!
 * @brief Defines the placeholder rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the placeholder rect
 * @return A CGrect structure that defines the placeholder rect of the given component.
 */
-(CGRect) placeholderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;


/*!
 * @brief Defines the border rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the border rect
 * @return A CGrect structure that defines the border rect of the given component.
 */
-(CGRect) borderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;
@end

//
//  MFTextFieldStyle+TextLayouting.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle.h"

/**
 * @class MFTextFieldStyle+TextLayouting
 * @brief This category on MFTextFieldStyle defines the necessary methods to
 * customize the text rects of the Text Field component following its states.
 */
@interface MFTextFieldStyle (TextLayouting)

#pragma mark - Methods

/**
 * @brief Defines the text rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the text rect
 * @return A CGrect structure that defines the text rect of the given component.
 */
-(CGRect) textRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/**
 * @brief Defines the editing rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the editing rect
 * @return A CGrect structure that defines the editing rect of the given component.
 */
-(CGRect) editingRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/**
 * @brief Defines the clear button rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the clear button rect
 * @return A CGrect structure that defines the clear button rect of the given component.
 */
-(CGRect) clearButtonRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;

/**
 * @brief Defines the placeholder rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the placeholder rect
 * @return A CGrect structure that defines the placeholder rect of the given component.
 */
-(CGRect) placeholderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;


/**
 * @brief Defines the border rect for the given component
 * @param bounds The original bounds of the Text Field component
 * @param component The Text Field component you want to defines the border rect
 * @return A CGrect structure that defines the border rect of the given component.
 */
-(CGRect) borderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component;
@end

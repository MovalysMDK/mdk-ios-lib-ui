//
//  MFEmailTextFieldStyle.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFRegexTextFieldStyle.h"
#import "MFRegexTextFieldStyle+Button.h"
#import "MFTextFieldStyle+BackgroundView.h"

@implementation MFRegexTextFieldStyle

-(NSDictionary *)customizeErrorViewConstraints:(NSDictionary *)errorViewConstraints onComponent:(MFTextField *)component {
    NSMutableDictionary *constraints = [errorViewConstraints mutableCopy];
    NSLayoutConstraint *right = errorViewConstraints[ERROR_VIEW_RIGHT_CONSTRAINT];
    right.constant -= (REGEX_BUTTON_SQUARE_SIZE + 2*DEFAULT_ACCESSORIES_MARGIN);
    constraints[ERROR_VIEW_RIGHT_CONSTRAINT] = right;
    return constraints;
}

-(CGRect)textRectForBounds:(CGRect)bounds onComponent:(MFRegexTextField *)component {
    CGRect rect = [super textRectForBounds:bounds onComponent:component];
    rect.size.width -= (REGEX_BUTTON_SQUARE_SIZE + 2*DEFAULT_ACCESSORIES_MARGIN);
    return rect;
}

-(CGRect)editingRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component {
    CGRect rect = [super editingRectForBounds:bounds onComponent:component];
    rect.size.width -= (REGEX_BUTTON_SQUARE_SIZE + DEFAULT_ACCESSORIES_MARGIN);
    return rect;}

-(CGRect)placeholderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component {
    CGRect rect = [super placeholderRectForBounds:bounds onComponent:component];
    rect.size.width -= (REGEX_BUTTON_SQUARE_SIZE + DEFAULT_ACCESSORIES_MARGIN);
    return rect;
}

-(CGRect)clearButtonRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component {
    CGRect rect = [super clearButtonRectForBounds:bounds onComponent:component];
    rect.origin.x -= (REGEX_BUTTON_SQUARE_SIZE + DEFAULT_ACCESSORIES_MARGIN);
    return rect;
}

-(NSDictionary *)customizeBackgroundViewConstraints:(NSDictionary *)backgroundViewConstraints onComponent:(MFTextField *)component {
    NSLayoutConstraint *width = backgroundViewConstraints[BACKGROUND_VIEW_WIDTH_CONSTRAINT];
    width.constant -= (REGEX_BUTTON_SQUARE_SIZE + 2*DEFAULT_ACCESSORIES_MARGIN);
    NSMutableDictionary *dictionary = [backgroundViewConstraints mutableCopy];
    dictionary[BACKGROUND_VIEW_WIDTH_CONSTRAINT] = width;
    return dictionary;
}


@end

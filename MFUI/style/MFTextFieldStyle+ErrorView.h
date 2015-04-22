//
//  AdvancedTextFieldStyle+ErrorView.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 16/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle.h"
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const NSString * ERROR_VIEW_WIDTH_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_HEIGHT_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_CENTER_Y_CONSTRAINT;
FOUNDATION_EXPORT const NSString * ERROR_VIEW_RIGHT_CONSTRAINT;

FOUNDATION_EXPORT NSInteger DEFAULT_CLEAR_BUTTON_CONTAINER;
FOUNDATION_EXPORT NSInteger DEFAULT_ERROR_VIEW_SQUARE_SIZE;

@class MFTextField;
/**
 * @class MFTextFieldStyle+ErrorView
 * @brief This category on MFTextFieldStyle defines the necessary methods
 * to customize the errorView of the Text Field component.
 */
@interface MFTextFieldStyle (ErrorView)


#pragma mark - Methods

/**
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

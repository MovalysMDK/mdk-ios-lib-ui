//
//  MFTextFieldStyle+BackgroundView.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle.h"
@class MFTextField;

FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_WIDTH_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_HEIGHT_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_CENTER_Y_CONSTRAINT;
FOUNDATION_EXPORT const NSString * BACKGROUND_VIEW_LEFT_CONSTRAINT;

/**
 * @class MFTextFieldStyle+BackgroundView
 * @brief This category on MFTextFieldStyle defines the necessary methods 
 * to customize the backgroundView of the Text Field component.
 */
@interface MFTextFieldStyle (BackgroundView)

#pragma mark - Methods

/**
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

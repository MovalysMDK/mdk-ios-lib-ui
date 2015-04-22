//
//  AdvancedTextFieldStyle.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 15/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFStyleProtocol.h"
#import "MFErrorViewProtocol.h"
#import "MFBackgroundViewProtocol.h"
#import "MFTextField.h"

FOUNDATION_EXPORT NSInteger DEFAULT_ACCESSORIES_MARGIN;

/**
 * @class MFTextFieldStyle
 * @brief This class manages the syle of a MFUrlTextField component
 */
@interface MFTextFieldStyle : NSObject <MFStyleProtocol, MFErrorViewProtocol, MFBackgroundViewProtocol>

#pragma mark - Methods

/**
 * @brief This methods allows to define constraints that will be applied on 
 * custom accessory view added to the component.
 * @param accessoryView The Accessory View added to the component on that the 
 * constraints will be applied
 * @param identifier A NSString object that identify the accessoryView.
 * @param component The component that will add the defined constraints
 * @return A NSArray object that contains the constraints that will define a position
 * for the given accessoryView in the component.
 * @discussion This method is called for each accessoryView that has been defined 
 * for this component. Be careful when defining constraints : use identifier parameter
 * to identify the accessoryView you want to define the position in the component.
 */
-(NSArray *)defineConstraintsForAccessoryView:(UIView *)accessoryView withIdentifier:(NSString *)identifier onComponent:(MFTextField *)component;

@end

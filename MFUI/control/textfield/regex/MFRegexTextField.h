//
//  MFEmailTextField.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextField.h"

/**
 * @class MFRegexTextField
 * @brief The MFRegexTextField component.
 * @discussion This component inherits from MFNewTextField component.
 * @discussion It show a text field where the content is validated or
 * not by a specified regualr expression. 
 * @discussion An action button allows the use to do a specific action
 * following the current text value in the text field.
 */
@interface MFRegexTextField : MFTextField

/**
 * @brief Returns the regular expression that controls this component
 * @return The regular expression that controls this component
 */
-(NSString *) regex;

@end

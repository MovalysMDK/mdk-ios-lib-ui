//
//  MFPhoneTextField.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 20/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFRegexTextField.h"

/**
 * @class MFPhoneTextField
 * @brief This class represents the Phone Text Field component.
 * @discussion This component inherits from MFRegexTextField and must contains
 * a valid "phone number value" to be validated (ex : 0203040506)
 */
@interface MFPhoneTextField : MFRegexTextField

@end

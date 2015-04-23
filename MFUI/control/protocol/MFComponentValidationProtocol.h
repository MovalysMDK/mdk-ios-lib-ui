//
//  MFComponentValidationProtocol.h
//  MFUI
//
//  Created by Quentin Lagarde on 21/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MFComponentValidationProtocol <NSObject>


/**
 Indicate if the control is valid.
 */
@property(nonatomic, setter=setIsValid:) BOOL isValid;

/**
 * Validate the ui component value.
 * @param parameters - parameters from the page
 * @return Number of errors detected by the UI component
 */
-(NSInteger) validateWithParameters:(NSDictionary *)parameters;

@end

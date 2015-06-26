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
#import <Foundation/Foundation.h>
#import <MFUI/MFUIError.h>

/*!
 * @protocol MFFieldValidatorProtocol
 * @brief A protocol that identifies a FieldValidator
 */
@protocol MFFieldValidatorProtocol <NSObject>

#pragma mark - Methods

/*!
 * @brief Static builder of MFFieldValidator instances
 * @return An object that conforms MFFieldValidatorProtocol
 */
+(instancetype) sharedInstance;

/*!
 * @brief Process to the validation
 * @discussion The validator has a specific algorithm that validates the given value
 * following the given parameters
 * @param currentState The current state in the validation. This dictionary contains some key/value pairs objects, that describe for each previous validator applied on
 * this value if it has returned an error or not.
 * @param parameters The parameters of the validator.
 * @return An instance of MFError if the validation failed, nil otherwhise (validation succeeded).
 */
-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters;

/*!
 * @brief Returns the recognized attributes by this validator.
 * @return An array that contains the attributes names as string recognized by this
 * validator.
 */
-(NSArray *) recognizedAttributes;

/*!
 * @brief Indicates if the validator can valid the given control
 * @param control The control the validator will potentially validate the value
 * @return YES if this validator can validate the value of the given control,
 * NO otherwhise.
 */
-(BOOL) canValidControl:(UIView *)control;

@end

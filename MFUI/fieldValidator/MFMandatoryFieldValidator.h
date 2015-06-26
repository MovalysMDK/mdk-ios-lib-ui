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
#import "MFFieldValidatorProtocol.h"

FOUNDATION_EXPORT NSString *FIELD_VALIDATOR_ATTRIBUTE_MANDATORY;

/*!
 * @class MFMandatoryFieldValidator
 * @brief The FieldValidator for mandatory behaviour
 * @discussion This validator checks the consistency of the value to validate in 
 * case of mandatory
 */
@interface MFMandatoryFieldValidator : NSObject <MFFieldValidatorProtocol>

@end

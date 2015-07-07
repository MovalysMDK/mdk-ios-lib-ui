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

/*!
 * @class MFUrlFieldValidator
 * @brief The FieldValidator for url
 * @discussion This validator checks the valid url value
 */
@interface MFUrlFieldValidator : NSObject <MFFieldValidatorProtocol>

/*!
 * @brief Returns the regular expression that should be matched
 * @return The regular expression that should be matched
 */
-(NSString *) regex;

/*!
 * @brief Indicates if the value match the given pattern
 * @param checkString The pattern to match
 * @return A BOOL value that is YES if the component is matching the pattern, NO otherwhise.
 */
-(BOOL) matchPattern:(NSString *)checkString;

@end

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


//iOS imports


//Converter protocol
#import "MFConverterProtocol.h"

/*!
 * @class MFStringConverter
 * @brief Class of static methods used to convert string into other types, or other types into a string
 */
@interface MFStringConverter : NSObject <MFConverterProtocol>

#pragma  mark - Methods

/*!
 * @brief Convert a string to a date.
 * @param value The string to convert as a date
 * @return The date retrieved from the given string
 */
+ (NSDate *)toDate:(id)value;

/*!
 * @brief Convert a string to a date.
 * @param value The string to convert as a date
 * @param dateFormatter The dateFormatter to use to voncert the given string as a date
 * @return The date retrieved from the given string
 */
+ (NSDate *)toDate:(id)value withFormatter:(NSDateFormatter *)dateFormatter;

/*!
 * @brief Convert a string to a number.
 * @param value The string to convert as a number
 * @return The number retrieved from the given string
 */
+ (NSNumber *)toNumber:(id)value;

/*!
 * @brief Convert an object to a string.
 * @param dateFormatter The dateFormatter to use to voncert the given string as a date
 * @return The string retrieved from the given object
 */
+ (NSString *)toString:(id)value;

@end

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


#import "MFConverterProtocol.h"
#import "MFDatePicker.h"

/*!
 * @class MFDateConverter
 * @brief Class of static methods to convert a date into other types and other types into a date
 */
@interface MFDateConverter : NSObject <MFConverterProtocol>

#pragma mark - Methods

/*!
 * @brief Convert a time to a string
 * @param value The time value to convert as a string
 * @return The string converted value
 */
+(NSString *)fromTimeToString:(id)value;

/*!
 * @brief Convert a datetime to a string
 * @param value The datetime value to convert as a string
 * @return The string converted value
 */
+(NSString *)fromDateTimeToString:(id)value;

/*!
 * @brief Convert a datetime to a string
 * @param value The datetime value to convert as a string
 * @param mode The MFDatePickerMode to use to format the converted string value
 * @return The string converted value
 */
+(NSString *)toString:(id)value withMode:(MFDatePickerMode)mode;

/*!
 * @brief Convert a datetime to a string
 * @param value The datetime value to convert as a string
 * @param customFormat The custom format to use to format the converted string value
 * @return The string converted value
 */
+(NSString *)toString:(id)value withCustomFormat:(NSString*)customFormat;


@end

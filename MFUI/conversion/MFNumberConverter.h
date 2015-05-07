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


//Protocol
#import "MFConverterProtocol.h"

/**
 * @class MFNumberConverter
 * @brief Class of static methods to convert number into other types and other types into number
 */
@interface MFNumberConverter : NSObject <MFConverterProtocol>


#pragma mark - Methods

/**
 * @brief Converts a number into a string
 * @param value The value to convert
 * @param numberFormatter The numberFormatter to use to convert the given number
 * @return The converted value string of the given number
 */
+(NSString *)toString:(id)value withFormatter:(NSNumberFormatter *)numberFormatter;

@end

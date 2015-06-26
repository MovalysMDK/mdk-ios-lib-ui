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

/*!
 * @category Utils
 * @brief A category that adds some useful methods on NSString object.
 */
@interface NSString (Utils)

/*!
 * @brief Trims the current string, by deleting white space characters before and after the string.
 * @return The trimmed string
 */
-(NSString *) trim;

/*!
 * @brief Indicated if the current string contains the given one
 * @discussion This method exists on NSString since iOS8, but need to be implemented here to be used on 
 * versions prior to iOS 8
 * @param aString The string to locate if it exists in the current string
 * @return YES if the current string contains the given string, NO otherwhise
 */
-(BOOL)containsString:(NSString *)aString;

@end

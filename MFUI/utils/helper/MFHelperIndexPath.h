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
//
//  MFHelperIndexPath.h
//  MFCore
//
//



@interface MFHelperIndexPath : NSObject

/*!
 * @brief Converts and returns an object into an indexpath
 * @param value an object to convert as an NSIndexPath.
 * @return An NSIndexPath
 */
+(NSIndexPath *)indexPathValue:(id) value;

/*!
 * @brief Converts and returns a NSIndexPath into a NSString
 * @param indexPath a NSIndexPath to convert as an NSString.
 * @return An NSString corresponding to the givent NSSindexPath
 */
+(NSString *)toString:(NSIndexPath *) indexPath;


@end

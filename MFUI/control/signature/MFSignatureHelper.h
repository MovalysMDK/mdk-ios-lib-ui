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
//  MFSignatureHelper.h
//  MFUI
//
//


#import <QuartzCore/QuartzCore.h>

/**
 * @class MFSignatureHelper
 * @brief An helper to the signature component
 * @discussion This helper converts a graphical signature into a NSMutableArray path and vice versa
 */
@interface MFSignatureHelper : NSObject

#pragma mark - Static methods
/**
 * @brief Converts a given path as an array into a string
 * @param lines An array containing lines descriptions
 * @param width The width of lines
 * @param x0 The x-axis origin of the signature
 * @param y0 The y-axis origin of the signature
 * @return A string that represents
 */
+ (NSString *) convertFromLinesToString:(NSMutableArray *) lines width:(float) width originX:(float) x0 originY:(float) y0;


+ (NSMutableArray *) convertFromStringToLines:(NSString *) string width:(float) width originX:(float) x0 originY:(float) y0;

/**
 * Save the context
 * @param context context to save
 * @return NSError if save technical failed
 */

@end

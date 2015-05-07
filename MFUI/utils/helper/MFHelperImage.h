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
//  MFHelperImage.h
//  MFCore
//
//



#import <MFCore/MFCoreFoundationExt.h>

/*!
 * Help developer to process or load image.
 *
 */
@interface MFHelperImage : NSObject

/*!
 * Load an image from a string URL.
 *
 * @see UIImage for more information about image
 * @param url - String representing URL
 * @return UIImage loaded from the given url.
 */
+(UIImage *) loadImageFromString:(NSString *) url;

/*!
 * Load an image from a MFURL URL.
 *
 * @see UIImage for more information about image
 * @see MFURL for more information about url
 * @param url - MFURL where the system can find image.
 * @return Image loaded from the given url.
 */
+(UIImage *) loadImageFromMFURL:(MFURL *) url;

@end

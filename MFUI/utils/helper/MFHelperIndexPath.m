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
//  MFHelperIndexPath.m
//  MFCore
//
//

#import "MFHelperIndexPath.h"

static NSString *const INDEX_PATH_STRING_SEPARATOR = @"_";

@implementation MFHelperIndexPath

/**
 * @brief Converts and returns an object into an indexpath
 * @param value an object to convert as an NSIndexPath.
 * @return An NSIndexPath
 */
+(NSIndexPath *)indexPathValue:(id) value {
    NSIndexPath *indexPath = nil;
    if([value isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString*) value;
        NSArray *components = [stringValue componentsSeparatedByString:INDEX_PATH_STRING_SEPARATOR];
        if(components && components.count == 2) {
            int section = [[components objectAtIndex:0] intValue];
            int row = [[components objectAtIndex:1] intValue];
            indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return indexPath;
}

/**
 * @brief Converts and returns a NSIndexPath into a NSString
 * @param indexPath a NSIndexPath to convert as an NSString.
 * @return An NSString corresponding to the givent NSSindexPath
 */
+(NSString *)toString:(NSIndexPath *) indexPath {
    NSString *string = nil;
    if(indexPath) {
        string = [NSString stringWithFormat:@"%ld_%ld", (long)indexPath.section, (long)indexPath.row];
    }
    return string;
}




@end

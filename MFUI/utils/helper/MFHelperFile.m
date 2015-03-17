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
//  MFHelperFile.m
//  MFCore
//
//

#import "MFHelperFile.h"
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreFoundationExt.h>

@implementation MFHelperFile

+(NSArray *) getAllFilesFromMainBundle
{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
    if(nil != error)
    {
        MFCoreLogError(@"An error occured (%@) when the application tries to read file in location '%@'", error.localizedDescription, path);
        return nil;
    }
    return directoryAndFileNames;
}

+(NSArray *) getAllFilesFromMainBundleMatchWith:(NSString *) regularExpression
{
    NSError *error = nil;
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regularExpression options:0 error:&error];
    if(nil != error)
    {
        MFCoreLogError(@"An error occured (%@) when the application tries to prepare regular expression '%@'", error.localizedDescription, regularExpression);
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *path in [MFHelperFile getAllFilesFromMainBundle]) {
        if([regExp numberOfMatchesInString:path options:0 range:NSMakeRange(0, path.length)] > 0)
        {
            [list addObject:path];
        }
    }
    return list;
}

+(NSArray *) getAllFilesFromMainBundleWithExtension:(NSString *) extension
{
    return [MFHelperFile getAllFilesFromMainBundleMatchWith:[NSString stringWithFormat:@".+\\.%@$", extension]];
}

@end

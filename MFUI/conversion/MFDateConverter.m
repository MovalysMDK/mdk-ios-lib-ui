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


#import "MFDateConverter.h"
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"

@implementation MFDateConverter

- (id)initWithParameters:(NSDictionary *)parameters
{
    if(self) {
    }
    return self;
}

+(NSNumber *)toDate:(id)value {
    return value;
}

+(NSNumber *)toNumber:(id)value {
    NSDate *date = value;
    return [[NSNumber alloc] initWithFloat:[date timeIntervalSince1970]];
}

+(NSString *)toString:(id)value {
    return [MFDateConverter toString:value withMode:MDKDateTimeModeDate];
}

+(NSString *)fromTimeToString:(id)value {
    return [MFDateConverter toString:value withMode:MDKDateTimeModeTime];
}

+(NSString *)fromDateTimeToString:(id)value {
    return [MFDateConverter toString:value withMode:MDKDateTimeModeDateTime];
}

+(NSString *)toString:(id)value withMode:(MDKDateTimeMode)datePickerMode{
    NSDate *date = value;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    switch(datePickerMode) {
        case MDKDateTimeModeDate:
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            break;
        case MDKDateTimeModeTime :
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            break;
        case MDKDateTimeModeDateTime :
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            break;
        default:
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            break;
    }

    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:date];
}

+(NSString *)toString:(id)value withCustomFormat:(NSString*)customFormat {
    NSDate *date = value;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:customFormat];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:date];
}


@end

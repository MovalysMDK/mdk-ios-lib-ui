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


#import "MFStringConverter.h"

@implementation MFStringConverter

- (id)initWithParameters:(NSDictionary *)parameters
{
    if(self) {
    }
    return self;
}


+ (NSDate *)toDate:(id)value
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    return [dateFormatter dateFromString:value];
}


+ (NSDate *)toDate:(id)value withFormatter:(NSDateFormatter *)dateFormatter
{
    return [dateFormatter dateFromString:value];
}


+ (NSNumber *)toNumber:(id)value
{
    //Le formatter permet d'obtenir un nombre en gérant automatiquement le séparateur
    //décimal qui dépend des réglages linguistiques de l'appareil.
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [numberFormatter numberFromString:value];
    return number;
}


+ (NSNumber *)toNumber:(id)value withFormatter:(NSNumberFormatter *)numberFormatter
{
    return [numberFormatter numberFromString:value];
}

+ (NSString *)toString:(id)value
{
    return [value description];
}


@end

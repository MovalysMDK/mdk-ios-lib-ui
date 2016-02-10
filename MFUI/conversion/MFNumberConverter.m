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
//  MFNumberConverter.m
//  MFUI
//
//

#import "MFNumberConverter.h"

@implementation MFNumberConverter

- (id)initWithParameters:(NSDictionary *)parameters {
    self = [super init];
    if(self) {
    }
    return self;
}

+(NSDate *)toDate:(id)value {
    NSTimeInterval timestamp = [(NSNumber *) value floatValue];
    return [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];

}

+(NSNumber *)toNumber:(id)value {
    return value;
}

+(NSString *)toString:(id)value {
    
    //Le formatter permet d'obtenir une version du nombre en chaine contenant le bon séparateur décimal (lié aux
    //régales linguistiques de l'appareil).
    //Cette chaine pourra ensuite être à nouveau convertie en NSNumber sans erreur.
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    //Par défaut, le formatter arrondi à l'entier supérieur : il faut lui spécifier un nombre maximal de décimales
    //pour pouvoir conserver un nombre décimal.
    [numberFormatter setMaximumFractionDigits:1000000];
    
    return [numberFormatter stringFromNumber:value];
}

+(NSString *)toString:(id)value withFormatter:(NSNumberFormatter *)numberFormatter {
    return [numberFormatter stringFromNumber:(NSNumber *) value];
}

@end

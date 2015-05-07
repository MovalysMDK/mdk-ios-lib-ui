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


#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreConfig.h>

#import "MFFloatConverter.h"
#import <MFCore/MFCoreApplication.h>



@implementation MFFloatConverter

#pragma mark - Convertisseur personnalisé
-(id) initWithParameters:(NSDictionary *)parameters {
    self = [super init];
    if(self) {
    }
    return self;
}

/*
@synthesize customParameters;

NSString *const CONVERTER_FLOAT_DEFAULT_REGISTRY_KEY = @"float";
NSString *const CONVERTER_FLOAT_NB_DIGITS_PARAMETER = @"numberOfDigits";


#pragma mark - Convertisseur par défaut.
+(NSString *)convertObjectToString:(id)value {
    float correctValue = [value floatValue];

    //Récupération des paramètres par défaut pour ce convertisseur
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    NSDictionary *converters =[registry getDictionaryProperty:CONVERTER_LIST_REGISTRY_KEY];
    NSDictionary *floatConverter = [converters objectForKey:CONVERTER_FLOAT_DEFAULT_REGISTRY_KEY];
    int numberOfDigits = [[floatConverter objectForKey:CONVERTER_FLOAT_NB_DIGITS_PARAMETER] intValue];
    
    //Formattage du nombre
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:numberOfDigits];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:correctValue]];
}

+(id)convertStringToObject:(NSString *)value {
    return [NSNumber numberWithFloat:[value floatValue]];
}


#pragma mark - Convertisseur personnalisé
-(id)initWithParameters:(NSDictionary *)parameters {
    self = [super init];
    if(self) {
        self.customParameters = parameters;
    }
    return self;
}

-(NSString *)convertObjectToString:(id)value {
    //Vérification des paramètres du convertisseur.
    if(![self checkParameters]) {
        return nil;
    }
    
    float correctValue = [value floatValue];
    
    //Récupération des paramètres par défaut pour ce convertisseur
    int numberOfDigits = [[self.customParameters objectForKey:CONVERTER_FLOAT_NB_DIGITS_PARAMETER] intValue];
    
    //Formattage du nombre
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:numberOfDigits];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:correctValue]];
}

-(id)convertStringToObject:(NSString *)value {
    return [NSNumber numberWithFloat:[value floatValue]];
}

#pragma mark - Gestion d'erreurs

-(BOOL)checkParameters {
    // La vérification est particulière à chaque convertisseur.
    if(!self.customParameters) {
        @throw([NSException exceptionWithName:@"Nil parameters" reason:@"You must define parameters to use custom MFFloatConverter" userInfo:nil]);
    }
    else if(![self.customParameters objectForKey:CONVERTER_FLOAT_NB_DIGITS_PARAMETER]) {
        @throw([NSException exceptionWithName:@"Missing parameter" reason:@"Parameter \"numberOfDigits\" is not defined" userInfo:nil]);
    }
    
    //Vérification des paramètres ici
    return YES;
}
*/
@end

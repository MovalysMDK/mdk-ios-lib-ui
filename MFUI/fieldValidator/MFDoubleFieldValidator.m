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

#import "MFDoubleFieldValidator.h"
#import "MFInvalidDoubleValueUIValidationError.h"

NSString *FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS = @"integerPartMinDigits";
NSString *FIELD_VALIDATOR_INTEGER_PART_MAX_DIGITS = @"integerPartMaxDigits";
NSString *FIELD_VALIDATOR_DECIMAL_PART_MIN_DIGITS = @"decimalPartMinDigits";
NSString *FIELD_VALIDATOR_DECIMAL_PART_MAX_DIGITS = @"decimalPartMaxDigits";

@implementation MFDoubleFieldValidator

+(instancetype)sharedInstance{
    static MFDoubleFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSArray *)recognizedAttributes {
    return @[FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS,
             FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS,
             FIELD_VALIDATOR_DECIMAL_PART_MIN_DIGITS,
             FIELD_VALIDATOR_DECIMAL_PART_MAX_DIGITS];
}

-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters {
    MFError *result = nil;
    if([value isKindOfClass:[NSString class]]) {
        if(![self matchPattern:value withParameters:parameters]) {
            result = [[MFInvalidDoubleValueUIValidationError alloc]  initWithLocalizedFieldName:parameters[@"componentName"] technicalFieldName:parameters[@"componentName"]];
        }
    }
    return result;
}

-(BOOL)canValidControl:(UIView *)control {
    BOOL canValid = YES;
    canValid = canValid && [control isKindOfClass:NSClassFromString(@"UITextField")];
    return canValid;
}

-(BOOL)isBlocking {
    return NO;
}

-(BOOL) matchPattern:(NSString *)checkString withParameters:(NSDictionary *)parameters {
    NSString *regex = [self createPatternFromParameters:parameters];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:checkString];
}

- (NSString *) createPatternFromParameters:(NSDictionary *)parameters {
    
    //Construction de la regex de vérification en fonction des propriétés du PLIST
    NSString *quantificateurPartieEntiere;
    NSString *quantificateurPartieDecimale;
    
    //Génération des quantificateurs
    
    //Si un nombre minimum de chiffres pour la partie entière est spécifié (et différent de zéro)
    if (parameters[FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS] != nil
        && [parameters[FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS] intValue] != 0) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@,", parameters[FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS]];
        //Autrement, il faudra saisir au moins un chiffre
    } else {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"1,"];
    }
    
    //Si un nombre maximum de chiffres pour la partie entière est spécifié (et différent de zéro) et qu'il est
    //supérieur au nombre minimum
    if (parameters[FIELD_VALIDATOR_INTEGER_PART_MAX_DIGITS]!= nil &&
        [parameters[FIELD_VALIDATOR_INTEGER_PART_MAX_DIGITS] intValue] != 0 &&
        [parameters[FIELD_VALIDATOR_INTEGER_PART_MAX_DIGITS] intValue] >= [parameters[FIELD_VALIDATOR_INTEGER_PART_MIN_DIGITS] intValue]) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@%@", quantificateurPartieEntiere, parameters[FIELD_VALIDATOR_INTEGER_PART_MAX_DIGITS]];
    }
    else {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@2", quantificateurPartieEntiere];
    }
    
    //Si un nombre minimum de chiffres pour la partie décimale est spécifié
    if (parameters[FIELD_VALIDATOR_DECIMAL_PART_MIN_DIGITS] != nil) {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"%@,", parameters[FIELD_VALIDATOR_DECIMAL_PART_MIN_DIGITS]];
        //Autrement, il faudra saisir au moins un chiffre
    } else {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"1,"];
    }
    
    //Si un nombre maximum de chiffres pour la partie décimale est spécifié et qu'il est supérieur au nombre minimum
    if (parameters[FIELD_VALIDATOR_DECIMAL_PART_MAX_DIGITS] != nil
        && [parameters[FIELD_VALIDATOR_DECIMAL_PART_MAX_DIGITS] intValue] >= [parameters[FIELD_VALIDATOR_DECIMAL_PART_MIN_DIGITS] intValue]) {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"%@%@", quantificateurPartieDecimale, parameters[FIELD_VALIDATOR_DECIMAL_PART_MAX_DIGITS]];
    }
    else {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"%@2", quantificateurPartieDecimale];
    }
    
    //Génération de la regex de vérification
    return [NSString stringWithFormat:@"^-?[0-9]{%@}([,\.][0-9]{%@})?$", quantificateurPartieEntiere, quantificateurPartieDecimale];
}

@end

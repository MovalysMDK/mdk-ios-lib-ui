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


#import <MFCore/MFCoreI18n.h>
#import "MFUILabel.h"

@implementation MFUILabel


NSString * const MF_MANDATORY_INDICATOR = @"MandatoryIndicator";
@synthesize mandatory = _mandatory;
@synthesize inInitMode = _inInitMode;
@synthesize tooltipView = _tooltipView;

#pragma mark - Constructeurs et initialisation

-(void) initialize {
    
    [super initialize];
#if !TARGET_INTERFACE_BUILDER
    //Récupération de la mention obligatoire
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    self.mandatoryIndicator = [registry getStringProperty:MF_MANDATORY_INDICATOR];
//    self.baseErrorButton.hidden = YES;
    self.userInteractionEnabled = YES;
    
#else
#endif
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.label.tag == 0) {
        [self.label setTag:TAG_MFLABEL_LABEL];
    }
}

#pragma mark - Getter/Setter des bindable properties

/**
 * @brief Cette méthode définit la valeur "mandatory" et l'affiche ou non
 * @param mandatory Nombre (0 ou 1) indiquant si la mention "obligatoire" doit être affichée ou non.
 * Le choix du NSNumber vient du fait que c'est un type plus pratique que BOOL (car dérivant de NSObject).
 */
-(void) setMandatory:(NSNumber *)mandatory {
    _mandatory = mandatory;
}

-(NSString *) insertOrRemoveMandatoryIndicator:(NSString *)data {
    //Vérification de l'état actuel du label (mandatory affiché ou non) et mise à jour du contenu du label
    if([self.mandatory isEqual: @1] && [data rangeOfString:self.mandatoryIndicator].location == NSNotFound) {
        data = [data stringByAppendingString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator]];
    }
    else if ([self.mandatory isEqual: @0] && [self.label.text rangeOfString:self.mandatoryIndicator].location != NSNotFound ) {
        data = [data stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator] withString:@""];
    }
    return data;
}

-(id)getData {
    return [self displayComponentValue];
}

-(void)setData:(id)data {
    NSString *fixedData = nil;
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        fixedData = data;
    }
    else {
        NSString *defaultValue = self.selfDescriptor.name;
        if(((MFFieldDescriptor *)self.selfDescriptor).i18nKey) {
            defaultValue = MFLocalizedStringFromKey(((MFFieldDescriptor *)self.selfDescriptor).i18nKey);
        }
        fixedData = defaultValue;
    }
    fixedData = [self insertOrRemoveMandatoryIndicator:fixedData];
    [super setData:fixedData];
    
}

-(void)setDisplayComponentValue:(id)value {
    self.label.text = value;
}

-(id)displayComponentValue {
    return self.label.text;
}

#pragma mark - Méthodes de gestion du label

+(NSString *)getDataType {
    return @"NSString";
}

@end


@implementation MFUIExternalLabel

@end

@implementation MFUIInternalLabel

@end

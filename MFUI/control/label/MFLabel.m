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
//  MFLabel.m
//  MFUI

//
//

#import <MFCore/MFCoreI18n.h>

#import "MFLabel.h"


@implementation MFLabel

NSString * const MF_MANDATORY_INDICATOR = @"MandatoryIndicator";
@synthesize mandatory = _mandatory;


#pragma mark - Constructeurs et initialisation


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
    }
    return self;
}

-(void) initialize {
    
    [super initialize];
    
#if !TARGET_INTERFACE_BUILDER
    
    //Récupération de la mention obligatoire
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    self.mandatoryIndicator = [registry getStringProperty:MF_MANDATORY_INDICATOR];
    
    // Label color : property tintColor (blue) for iOS 7+, black for prior versions
    if ([self respondsToSelector:@selector(tintColor)]) {
    }
    else {
        self.textColor = [UIColor blackColor];
    }
    self.baseErrorButton.hidden = YES;

    
    self.userInteractionEnabled = NO;
    
    [self setAllTags];
    
    #else
#endif
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.label.tag == 0) {
        [self.label setTag:TAG_MFLABEL_LABEL];
    }
}


#pragma mark - CSS customization

-(NSArray *)customizableComponents {
    return @[
             self.label
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             @"Label"
             ];
}


#pragma mark - Getter/Setter des bindable properties

/**
 * @brief Cette méthode définit la valeur "mandatory" et l'affiche ou non
 * @param mandatory Nombre (0 ou 1) indiquant si la mention "obligatoire" doit être affichée ou non.
 * Le choix du NSNumber vient du fait que c'est un type plus pratique que BOOL (car dérivant de NSObject).
 */
-(void) setMandatory:(NSNumber *)mandatory {
    _mandatory = mandatory;
    [self displayMandatory];
}

-(void) displayMandatory {
    //Vérification de l'état actuel du label (mandatory affiché ou non) et mise à jour du contenu du label
    if([self.mandatory isEqual: @1] && [self.label.text rangeOfString:self.mandatoryIndicator].location == NSNotFound) {
        self.label.text = [self.label.text stringByAppendingString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator]];
    }
    else if ([self.mandatory isEqual: @0] && [self.label.text rangeOfString:self.mandatoryIndicator].location != NSNotFound ) {
        self.label.text = [self.label.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator] withString:@""];
    }
    
    // Mise à jour graphique de la vue
    [self setNeedsDisplay];
}


#pragma mark - Méthodes de gestion du label

+(NSString *)getDataType {
    return @"NSString";
}

-(id)getData {
    return self.label.text;
}

-(void)setData:(id)data {
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        [self.label setText:(NSString *)data];
        [self displayMandatory];
    }
    else {
        NSString *defaultValue = self.selfDescriptor.name;
        if(((MFFieldDescriptor *)self.selfDescriptor).i18nKey) {
            defaultValue = MFLocalizedStringFromKey(((MFFieldDescriptor *)self.selfDescriptor).i18nKey);
        }
        [self.label setText:defaultValue];
        [self displayMandatory];
    }
}


#pragma mark - UIBaseComponentDelegate

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    return 0;
}

-(NSInteger) validate {
    return [self validateWithParameters:nil];
}


#pragma mark - Fast Forwarding UILabel methods
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.label;
}

#pragma mark - KVC magic forwarding
-(id)valueForUndefinedKey:(NSString *)key {
    id returnValue = nil;
    if([key isEqualToString:@"mf."])
    {
        returnValue = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
    }
    else {
        returnValue = [self.label valueForKey:key];
    }
    return returnValue;
}
//
//-(void)ruleForEditableStyle {
//
//}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.label setValue:value forKey:key];
}

-(void)setTextColor:(UIColor *)textColor {
    self.label.textColor = textColor;
}

-(void)setComponentAlignment:(NSNumber *)alignValue {
    [self.label setTextAlignment:[alignValue intValue]];
}

-(void)setFont:(UIFont *)font {
    [self.label setFont:font];
}

#pragma mark - LiveRendering Methods
-(void)buildDesignableComponentView {
    
    //Création du label et ajout à la vue
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.userInteractionEnabled = NO;
    [self addSubview:self.label];
    
    
    NSLayoutConstraint *insideLabelCstrtLeftMargin = [NSLayoutConstraint
                                                      constraintWithItem:self.label
                                                      attribute:NSLayoutAttributeLeft
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                      attribute:NSLayoutAttributeLeft
                                                      multiplier:1
                                                      constant:0];
    
    NSLayoutConstraint *insideLabelCstrtTopMargin = [NSLayoutConstraint
                                                     constraintWithItem:self.label
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                     multiplier:1
                                                     constant:0];
    
    NSLayoutConstraint *insideLabelCstrtHeight = [NSLayoutConstraint
                                                  constraintWithItem:self.label
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                                  attribute:NSLayoutAttributeHeight
                                                  multiplier:1
                                                  constant:0];
    
    NSLayoutConstraint *insideLabelCstrtWidth = [NSLayoutConstraint
                                                 constraintWithItem:self.label
                                                 attribute:NSLayoutAttributeWidth
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                                 attribute:NSLayoutAttributeWidth
                                                 multiplier:1
                                                 constant:0];
    
    [self addConstraints:@[insideLabelCstrtLeftMargin, insideLabelCstrtTopMargin, insideLabelCstrtHeight, insideLabelCstrtWidth]];
    
}

-(void)renderComponentFromInspectableAttributes {
    self.label.textColor = self.IB_textColor;
    self.label.font = [UIFont fontWithName:self.label.font.familyName size:self.IB_textSize];
    self.label.backgroundColor = self.IB_primaryBackgroundColor;
    self.label.textAlignment = self.IB_textAlignment;

}

-(void)initializeInspectableAttributes {
    [super initializeInspectableAttributes];
    self.IB_textColor = [UIColor colorWithRed:0 green:128.0/255.0 blue:1 alpha:1];
    self.IB_textSize = 16;
    self.IB_unbindedText = @"Unbinded label";
    self.IB_primaryBackgroundColor = [UIColor clearColor];
}

-(void)didLayoutSubviewsDesignable {
    self.backgroundColor = [UIColor clearColor];
}

-(void)didLayoutSubviewsNoDesignable {
    self.label.textColor = self.tintColor;
}

-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.label.text = self.IB_unbindedText;
    if(!self.IB_enableIBStyle) {
        self.label.textColor = [UIColor colorWithRed:0 green:128.0/255.0 blue:1 alpha:1];
        self.label.font = [UIFont fontWithName:self.label.font.familyName size:16];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentLeft;
    }
}

@end

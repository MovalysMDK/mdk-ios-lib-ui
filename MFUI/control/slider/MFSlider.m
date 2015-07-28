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
//  MFSlider.m
//  MFUI
//
//


#import "MFSlider.h"
#import "MFSlider+UISliderForwarding.h"
#include <math.h>

@implementation MFSlider
@synthesize targetDescriptors = _targetDescriptors;

//Parameters keys
NSString *const SLIDER_PARAMETER_MAX_VALUE_KEY = @"maxValue";
NSString *const SLIDER_PARAMETER_MIN_VALUE_KEY = @"minValue";
NSString *const SLIDER_PARAMETER_STEP_KEY = @"step";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialize {
    
    [super initialize];
    [self buildComponentView];
    [self setAllTags];
}


/**
 * @brief Cette méthode est appelée à chaque changement de valeur du slider
 */

-(void)sliderValueChangedAction {
    
    //On récupère la valeur en fonction de l'steple spécifié
    //self.slider.value = [self adjustValue:self.slider.value Withstep:self.step];
    //self.sliderValue.text = [NSString stringWithFormat:@"%d", (int)self.slider.value];
    //[self setValue:self.slider.value];
    [self setValue:self.innerSlider.value];
}

/**
 * @brief Cette méthode permet d'ajuster la valeur du slider en fonction du pas spécifié.
 */

- (float) adjustValue:(float)value WithStep:(float)step {
    
    float reste = fmod(value, step);
    if (reste != 0) {
        
        float valueToReturn = value - reste;
        
        //Si la valeur à retourner est inférieure à la valeur minimale du slider, celui va
        //se positionner par défaut sur la valeur minimale, qui ne respecte pas forcément le pas.
        //Cette valeur à retourner est nécessairement un multiple du pas et est la plus grande valeur
        //qui est inférieure à la dernière valeur valide du slider.
        //Il suffit donc d'ajouter le pas à cette valeur à retourner pour obtenir un nombre valide.
        if (valueToReturn < self.innerSlider.minimumValue) {
            return valueToReturn + self.step;
        }
        
        return valueToReturn;
        
    } else {
        return value;
    }
    
}

#pragma mark - Binding

//PROTODO : parameters
//minValue
//maxValue
//step

//-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
//    
//    [super didLoadFieldDescriptor:fieldDescriptor];
//    
//    //Biding des propriétés
//    
//    //Les bornes doivent toujours être entières (partie entière récupérée si nombre décimal)
//    NSNumber *minValue = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"minValue"];
//    self.innerSlider.minimumValue = [minValue intValue];
//    
//    NSNumber *maxValue = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"maxValue"];
//    self.innerSlider.maximumValue = [maxValue intValue];
//    
//    NSNumber *step = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"step"];
//    self.step = [step floatValue];
//    
//    if (self.step == 0) {
//        self.step = 1;
//    }
//    
//}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.innerSlider.tag == 0) {
        [self.innerSlider setTag:TAG_MFSLIDER_SLIDER];
    }
    if (self.innerSliderValueLabel.tag == 0) {
        [self.innerSliderValueLabel setTag:TAG_MFSLIDER_SLIDERVALUE];
    }
}


#pragma mark - CSS customization

-(NSArray *)customizableComponents {
    return @[
             self.innerSlider,
             self.innerSliderValueLabel
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             @"Slider",
             @"SliderValue"
             ];
}

#pragma mark - Custom implementation

- (void)setValue:(float)value animated:(BOOL)animated {
    
    //Mise à jour du slider
    if (animated == YES)
    {
        //Permet l'animation sur iOS 7
        [UIView animateWithDuration:1.0 animations:^{
            [self.innerSlider setValue:[self adjustValue:value WithStep:self.step] animated:animated];
        }];
    } else {
        [self.innerSlider setValue:[self adjustValue:value WithStep:self.step] animated:animated];
    }
    
    //Mise à jour de la valeur affichée
    NSNumber *number = [NSNumber numberWithFloat:self.innerSlider.value];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    //Blocage à 3 décimales car le nombre est un float avec un grand nombre de décimales
    numberFormatter.maximumFractionDigits = 3;
    [self.innerSliderValueLabel setText:[MFNumberConverter toString:number withFormatter:numberFormatter]];
}

#pragma mark - MFUIComponentProtocol implementation

+(NSString *)getDataType {
    return @"NSNumber";
}

- (void) setValue:(float)value {
    [self setValue:value animated:NO];
}

- (float) getValue {
    return (int)self.innerSlider.value;
}

-(void)setData:(id)data {
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        [self setValue:[(NSNumber *)data floatValue]];
    }
}

-(id)getData {
    return [NSNumber numberWithFloat: [self getValue]];
}



-(BOOL) isActive
{
    return self.innerSlider.enabled;
}

-(void) setIsActive:(BOOL)isActive{
    self.innerSlider.enabled = isActive;
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.innerSlider.userInteractionEnabled = ([editable isEqualToNumber:@1]) ? YES : NO;
}


#pragma mark - Fast Forwarding UISlider methods
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.innerSlider;
}


#pragma mark - IB_Designable methods

-(void)buildComponentView {
    self.innerSlider = [[UISlider alloc] init];
    self.step = 1;
    self.innerSlider.minimumValue = 0;
    self.innerSlider.maximumValue = 0;
    self.innerSlider.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Champ de texte affichant la valeur du slider
    self.innerSliderValueLabel = [[UILabel alloc] init];
    self.innerSliderValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Le slider et le label sont ajoutés à la vue du composant
    [self addSubview:self.innerSliderValueLabel];
    [self addSubview:self.innerSlider];
    [self innerComponentConstraints];
    self.backgroundColor = [UIColor whiteColor];
    
}

-(void)renderComponentFromInspectableAttributes {
}


-(void) innerComponentConstraints {
    
    self.innerSlider.translatesAutoresizingMaskIntoConstraints = NO;
    //Positionnement du slider
    
    NSLayoutConstraint *insideSliderConstraintLeftMargin = [NSLayoutConstraint constraintWithItem:self.innerSlider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *insideSliderConstraintWidth = [NSLayoutConstraint constraintWithItem:self.innerSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *insideSliderConstraintTopMargin= [NSLayoutConstraint constraintWithItem:self.innerSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *insideSlideCenterPosition = [NSLayoutConstraint constraintWithItem:self.innerSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    //Positionnement du label affichant la valeur du slider
    
    NSLayoutConstraint *insideSliderValueConstraintLeftMargin = [NSLayoutConstraint constraintWithItem:self.innerSliderValueLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.innerSlider attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *insideSliderValueConstraintTopMargin = [NSLayoutConstraint constraintWithItem:self.innerSliderValueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.innerSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *insideSliderValueConstraintWidth = [NSLayoutConstraint constraintWithItem:self.innerSliderValueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.2 constant:0];
    
    NSLayoutConstraint *insideSliderValueConstraintHeight= [NSLayoutConstraint constraintWithItem:self.innerSliderValueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.innerSlider attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    //Ajout des contraintes de positionnement pour placer les éléments
    [self addConstraints:@[insideSliderConstraintLeftMargin, insideSliderConstraintWidth, insideSliderConstraintTopMargin, insideSlideCenterPosition, insideSliderValueConstraintLeftMargin, insideSliderValueConstraintTopMargin, insideSliderValueConstraintWidth, insideSliderValueConstraintHeight]];
}


-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];

    self.innerSliderValueLabel.textAlignment = NSTextAlignmentCenter;
    self.innerSliderValueLabel.textColor = [UIColor colorWithRed:0 green:128.0/255.0 blue:1 alpha:1];
}

-(void)willLayoutSubviewsNoDesignable {
    self.innerSliderValueLabel.textAlignment = NSTextAlignmentCenter;
}

-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    [super setControlAttributes:controlAttributes];
    self.maximumValue = self.controlAttributes[SLIDER_PARAMETER_MAX_VALUE_KEY] ? [self.controlAttributes[SLIDER_PARAMETER_MAX_VALUE_KEY] integerValue] : 100;
    self.minimumValue = self.controlAttributes[SLIDER_PARAMETER_MIN_VALUE_KEY] ? [self.controlAttributes[SLIDER_PARAMETER_MIN_VALUE_KEY] integerValue] : 0;
    self.step = self.controlAttributes[SLIDER_PARAMETER_STEP_KEY] ? [self.controlAttributes[SLIDER_PARAMETER_STEP_KEY] integerValue] : 1;
}


#pragma mark - Control changes

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    
    [self.innerSlider addTarget:self action:@selector(valueChanged:) forControlEvents:controlEvents];
    [self.innerSlider addTarget:self action:@selector(valueChanged:) forControlEvents:controlEvents];
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.innerSlider.hash) : commonCCTD};
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) valueChanged:(UIView *)sender {
    [self setData:@(((UISlider *)sender).value)];
    MFControlChangedTargetDescriptor *cctd = self.targetDescriptors[@(sender.hash)];
    [cctd.target performSelector:cctd.action withObject:self];
}
#pragma clang diagnostic pop


@end

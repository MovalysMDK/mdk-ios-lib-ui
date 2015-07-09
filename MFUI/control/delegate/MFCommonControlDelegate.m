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

#import "MFCommonControlDelegate.h"
#import "MFUIComponentProtocol.h"
#import "MFStyleProtocol.h"
#import "MFConstants.h"
#import "MFErrorViewProtocol.h"
#import "UIView+Styleable.h"
#import "MFUIFieldValidator.h"
#import "MFUIOldBaseComponent.h"
#import "UIView+Binding.h"

@interface MFCommonControlDelegate ()

@property (nonatomic, weak) UIView<MFUIComponentProtocol> *component;

@end

@implementation MFCommonControlDelegate


-(instancetype)initWithComponent:(id<MFUIComponentProtocol>)component {
    self = [super init];
    if(self) {
        self.component = component;
        [self computeStyleClass];
    }
    return self;
}


-(void)clearErrors {
    [self.component setIsValid:YES];
    self.component.errors = [@[] mutableCopy];
}

-(NSMutableArray *) getErrors {
    return [@[] mutableCopy];
}



-(void)addErrors:(NSArray *)errors {
    if(errors) {
        [self.component.errors addObjectsFromArray:errors];
    }
    if([self.component isKindOfClass:[MFUIOldBaseComponent class]]) {
        [self.component performSelector:@selector(showErrorButtons)];
        
    }else {
        [self.component showError:self.component.errors.count];
    }
    [self setIsValid:(errors.count == 0)];
}

-(void)setIsValid:(BOOL)isValid {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.component applyStandardStyle];
    });
    if(isValid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.component applyValidStyle];
        });
        [self.component.tooltipView hideAnimated:YES];
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.component applyErrorStyle];
        });
    }
}

-(void) onErrorButtonClick:(id)sender {
    if(![self.component.tooltipView superview]){
        //Récupération du texte des erreurs
        NSString *errorText = @"";
        int errorNumber = 0;
        for (NSError *error in self.component.errors) {
            if(errorNumber > 0){
                errorText = [errorText stringByAppendingString: @"\n"];
            }
            errorNumber++;
            errorText= [errorText stringByAppendingString: [error localizedDescription]];
        }
        //Passage de la vue au premier plan
        UIView *currentView = self.component;
        do {
            UIView *superView = currentView.superview;
            [superView setClipsToBounds:NO];
            [superView bringSubviewToFront:currentView];
            currentView = superView;
        } while (currentView.tag != FORM_BASE_TABLEVIEW_TAG && currentView.tag != FORM_BASE_VIEW_TAG);
        
        //Création et affichage de la bulle
        self.component.tooltipView = [[JDFTooltipView alloc] initWithTargetView:((id<MFErrorViewProtocol>)self.component.styleClass).errorView hostView:currentView tooltipText:@"" arrowDirection:JDFTooltipViewArrowDirectionUp width:self.component.frame.size.width];
        [currentView bringSubviewToFront:self.component.tooltipView];
        self.component.tooltipView.tooltipText = errorText;
        self.component.tooltipView.tooltipBackgroundColour = [self defaultTooltipBackgroundColor];
        [self.component.tooltipView show];
        [self.component.tooltipView performSelector:@selector(hideAnimated:) withObject:@1 afterDelay:2];
    }
    else {
        [self.component.tooltipView hideAnimated:YES];
    }
    [self.component bringSubviewToFront:self.component.tooltipView];
}


-(UIColor *) defaultTooltipBackgroundColor {
    return [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1];
}

-(void) computeStyleClass {
    /**
     * Style priority :
     * 1. User Defined Runtime Attribute named "styleClass"
     * 2. Class style based on the component class name
     * 3. Class style defined as a bean base on the component class name
     * 4. Default Movalys style
     */
    NSString *componentClassStyleName = [NSString stringWithFormat:@"%@Style", [self.component class]];
    
    if(self.component.styleClassName) {
        self.component.styleClass = [NSClassFromString(self.component.styleClassName) new];
    }
    else if(componentClassStyleName){
        self.component.styleClass = [NSClassFromString(componentClassStyleName) new];
    }
    //TODO: Style via BeanLoader
    else {
        self.component.styleClass = [NSClassFromString(@"MFDefaultStyle") new];
    }
}

-(void)setVisible:(NSNumber *)visible {
    if([visible integerValue] == 1) {
        self.component.hidden = NO;
    }
    else {
        self.component.hidden = YES;
    }
}

-(NSInteger)validate {
    [self clearErrors];
    NSMutableArray *validators = [NSMutableArray array];
    NSMutableDictionary *validationState = [NSMutableDictionary dictionary];
    
    //Mandatory validator
    id mandatoryError = nil;
    id<MFFieldValidatorProtocol> mandatoryValidator = nil;
    if([self.component mandatory]) {
        
        mandatoryValidator = [[MFFieldValidatorHandler fieldValidatorsForAttributes:@[FIELD_VALIDATOR_ATTRIBUTE_MANDATORY] forControl:[self component]] firstObject];
        mandatoryError = [mandatoryValidator validate:[self.component getData] withCurrentState:validationState withParameters:@{FIELD_VALIDATOR_ATTRIBUTE_MANDATORY : self.component.mandatory}];
    }
    if(!mandatoryError && self.component.controlAttributes) {
        
        //Component Validators
        [validators addObjectsFromArray:[self.component controlValidators]];
        
        //Other validatos
        [validators addObjectsFromArray:[MFFieldValidatorHandler fieldValidatorsForAttributes:self.component.controlAttributes.allKeys forControl:[self component]]];
        
        
        for(id<MFFieldValidatorProtocol> fieldValidator in validators) {
            if(validationState[NSStringFromClass([fieldValidator class])]) {
                continue;
            }
            NSMutableDictionary *validatorParameters = [NSMutableDictionary dictionary];
            for(NSString *recognizedAttribute in [fieldValidator recognizedAttributes]) {
                if(self.component.controlAttributes[recognizedAttribute]) {
                    validatorParameters[recognizedAttribute] = self.component.controlAttributes[recognizedAttribute];
                }
            }
            
            //On ajoute le nom du composant
            if([self.component bindedName]) {
                validatorParameters[@"componentName"] = [self.component bindedName];
            }
            id errorResult = [fieldValidator validate:[self.component getData] withCurrentState:validationState withParameters:validatorParameters];
            if(errorResult) {
                validationState[NSStringFromClass([fieldValidator class])] = errorResult;
                if([fieldValidator isBlocking]) { break; }
            }
            else {
                validationState[NSStringFromClass([fieldValidator class])] = [NSNull null];
            }
        }
    }
    else {
        if(mandatoryError) {
            validationState[NSStringFromClass([mandatoryValidator class])] = mandatoryError;
        }
    }
    
    int numberOfErrors = 0;
    for(id result in validationState.allValues) {
        if(![result isKindOfClass:[NSNull class]]) {
            numberOfErrors++;
            [self addErrors:@[result]];
        }
    }
    return numberOfErrors;
}

-(void)addControlAttribute:(id)controlAttribute forKey:(NSString *)key {
    NSMutableDictionary *mutableControlAttributes = [self.component.controlAttributes mutableCopy];
    mutableControlAttributes[key] = controlAttribute;
    self.component.controlAttributes = mutableControlAttributes;
}
@end

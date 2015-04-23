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
//  MFUIBaseComponent.m
//  Pods
//
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreFormConfig.h>

#import "MFUIBaseComponent.h"
#import "MFFormCellProtocol.h"
#import "MFCellAbstract.h"
#import "MFUILogging.h"
#import "MFConstants.h"
#import "MFBindingViewAbstract.h"


/**
 * Constante indiquant la durée de l'animation du bouton d'erreur
 */
NSTimeInterval const ERROR_BUTTON_ANIMATION_DURATION = 0.2f;

/**
 * @brief Constante indiquant la taille (largeur et hauteur) du bouton d'erreur
 */
CGFloat const ERROR_BUTTON_SIZE = 30;


@interface MFUIBaseComponent()


@end


@implementation MFUIBaseComponent

@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize selfDescriptor = _selfDescriptor;
@synthesize isValid = _isValid;
@synthesize form = _form;
@synthesize mandatory = _mandatory;
@synthesize visible = _visible;
@synthesize componentInCellAtIndexPath = _componentInCellAtIndexPath;
@synthesize editable = _editable;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize lastUpdateSender = _lastUpdateSender;
@synthesize errors = _errors;
@synthesize inInitMode = _inInitMode;

#pragma mark - Constructeurs et initialisation
-(id)init {
    self = [super init];
    if(self) {
//        Initialisation des éléments communs
            self.sender = self;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Initialisation des éléments communs
        //        self.sender = self;
        [self initialize];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //Initialisation des éléments communs
        //        self.sender = self;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withSender:(MFUIBaseComponent *)sender
{
    self = [super initWithFrame:frame];
    if (self) {
        //Initialisation des éléments communs
        self.sender = sender;
        [self initialize];
    }
    return self;
}


-(void)initialize {
    
    [self initializeInspectableAttributes];
    [self buildDesignableComponentView];
    if([self conformsToProtocol:@protocol(MFDefaultConstraintsProtocol)]) {
        [self performSelector:@selector(applyDefaultConstraints) withObject:nil];
    }
#if !TARGET_INTERFACE_BUILDER
    
    //    self.tag = [MFApplication getViewTag];
    [self initErrors];
    
    
    //Par défaut tout composant est éditable.
    self.editable = @1;
    self.sender = self;
    //Ajout du bouton à la vue du composant
    //    [self addSubview:self.baseErrorButton];
    
#endif
}

-(void) initErrors {
    self.errors = [[NSMutableArray alloc] init];
}

#pragma mark - Méthodes communes à tous les composants


-(void)setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor {
    _selfDescriptor = selfDescriptor;
    
#warning TODO: This call should be removed
    [self didLoadFieldDescriptor:self.selfDescriptor];
    
    
}

-(void) didFinishLoadDescriptor __attribute__((deprecated("Use method didLoadFieldDescriptor: instead"))){
    [self didLoadFieldDescriptor:((MFFieldDescriptor *)self.selfDescriptor)];
}

-(void) didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    //Default : nothing
}



-(void)setIsValid:(BOOL)isValid {
    if (self.isValid != isValid) {
        _isValid = isValid;
        [self showError:!isValid];
    }
}


-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    // We remove all control's errors
    [self.errors removeAllObjects];
    return 0;
}



-(id)getData {
    
    MFCoreLogError(@"The component %@ should have implemented the method called \"getData\"",self.class);
    return nil;
}

-(void)setData:(id)data {
    //Here the data has been potentially fixed by the component
    self.componentData = data;
    
    //Update the component with this value
    [self performSelector:@selector(setDisplayComponentValue:) withObject:self.componentData];
}

+ (NSString *) getDataType {
    MFCoreLogError(@"The component %@ should have implemented the method called \"getDataType\"",self.class);
    return nil;
}

-(void) selfCustomization {
    //Nothing to do here.
}

#pragma mark - Méthodes du protocole mais non implémentées ici


-(CGRect)getErrorButtonFrameForInvalid {
    CGFloat errorButtonSize = MIN(MIN(self.bounds.size.width, self.bounds.size.height), ERROR_BUTTON_SIZE);
    
    return CGRectMake(0,
                      (self.bounds.size.height - errorButtonSize)/2.0f,
                      errorButtonSize,
                      errorButtonSize);
}

-(CGRect)getErrorButtonFrameForValid {
    CGFloat errorButtonSize = MIN(MIN(self.bounds.size.width, self.bounds.size.height), ERROR_BUTTON_SIZE);
    
    return CGRectMake(-errorButtonSize,
                      (self.bounds.size.height - errorButtonSize)/2.0f,
                      errorButtonSize,
                      errorButtonSize);
}

-(void)hideErrorTooltips {
    if (nil != self.baseTooltipView)
    {
        [self.baseTooltipView removeFromSuperview];
        self.baseTooltipView = nil;
    }
}

-(NSMutableArray *) getErrors {
    return self.errors;
}

-(void) clearErrors{
    [self clearErrors:YES];
}

-(void) clearErrors:(BOOL)anim {
    [self.errors removeAllObjects];
    [self hideErrorTooltips];
    [self setIsValid:YES];
}

-(void) addErrors:(NSArray *) errors{
    if(errors != nil && [errors count]) {
        [self setIsValid:NO];
        
        NSMutableArray *newErrors = [errors mutableCopy];
        for(NSError *error in errors) {
            if([self.errors containsObject:error]) {
                [newErrors removeObject:error];
            }
        }
        [self.errors addObjectsFromArray:newErrors];
    }
}

-(void)dispatchEventOnValueChanged {
    NSString *bindingKey = ((MFFieldDescriptor *)self.sender.selfDescriptor).bindingKey;
    if(self.form && bindingKey) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.form dispatchEventOnComponentValueChangedWithKey:bindingKey atIndexPath:self.componentInCellAtIndexPath];
        });
    }
}

-(void) onChildValueChanged:(MFUIBaseComponent *) child {
    [self updateValue:[self getData]];
}

-(void)updateValue:(id) newValue {
    [self onUpdate](newValue);
}

-(void (^)(id x))onUpdate {
    __weak MFUIBaseComponent *weakSelf = self;
    return  ^(id x) {
        if(x){
            MFUIBaseComponent *strongSelf = weakSelf;
            id value = (NSString *) x;
            if (value) {
                // We validate the value
                if([strongSelf validateWithParameters:nil] == 0) {
                    // If there aren't any errors, we clean all component's errors
                    [strongSelf clearErrors];
                }
                else {
                    [strongSelf showError:YES];
                }
            } else {
                [strongSelf clearErrors];
            }
            if (strongSelf.mfParent) {
                [strongSelf.mfParent onChildValueChanged:strongSelf];
            } else {
                if (![self inInitMode]) {
                    [strongSelf dispatchEventOnValueChanged];
                }
            }
        }
    };
}

-(void)setVisible:(NSNumber *)visible {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [self setHidden:[visible isEqual:@0]];
    [self setNeedsDisplay];
    //    });
}

//-(NSString *)description{
//    return [self.selfDescriptor description];
//}

- (void)dealloc
{
    self.sender = nil;
}

- (void)setI18nKey:(NSString *) defaultValue {
    [self setData:defaultValue];
}

-(void)setComponentParameters:(NSDictionary *)parameters {
    if(self.selfDescriptor) {
        [((MFFieldDescriptor *)self.selfDescriptor).parameters addEntriesFromDictionary:parameters];
    }
}


#pragma mark - Live Rendering Default Implementation

-(void)willLayoutSubviewsNoDesignable {
    //Default : nothing
}

-(void)didLayoutSubviewsNoDesignable {
    //Default : nothing
}

-(void)willLayoutSubviewsDesignable {
}

-(void)didLayoutSubviewsDesignable {
    //Default : nothing
}

-(void)initializeInspectableAttributes {
    self.backgroundColor = [UIColor clearColor];
}

-(void)prepareForInterfaceBuilder {
    self.backgroundColor = [UIColor clearColor];
}

-(void) buildDesignableComponentView {
    
}

-(void) renderComponentFromInspectableAttributes {
    
}


-(void)showError:(BOOL)showErrorView {
    
}

@end

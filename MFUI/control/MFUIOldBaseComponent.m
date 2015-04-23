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
//  MFUIOldBaseComponent.m
//  Pods
//
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreFormConfig.h>

#import "MFUIOldBaseComponent.h"
#import "MFFormCellProtocol.h"
#import "MFCellAbstract.h"
#import "MFUILogging.h"
#import "MFConstants.h"
#import "MFBindingViewAbstract.h"




@interface MFUIOldBaseComponent()


@end


@implementation MFUIOldBaseComponent


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
@synthesize mfParent = _mfParent;
@synthesize lastUpdateSender = _lastUpdateSender;
@synthesize inInitMode = _inInitMode;

#pragma mark - Constructeurs et initialisation
-(id)init {
    self = [super init];
    if(self) {
        //Initialisation des éléments communs
        //        self.sender = self;
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

- (instancetype)initWithFrame:(CGRect)frame withSender:(MFUIOldBaseComponent *)sender
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
    
    if([self conformsToProtocol:@protocol(MFDefaultConstraintsProtocol)]) {
        [self performSelector:@selector(applyDefaultConstraints) withObject:nil
         ];
    }
#if !TARGET_INTERFACE_BUILDER
    
    //Récupération du contexte
    //    self.tag = [MFApplication getViewTag];
    [self initErrors];
    
    self.backgroundColor = [UIColor clearColor];

    //Par défaut tout composant est éditable.
    self.editable = @1;
    self.sender = self;
    self.applySelfStyle = YES;
    //Ajout du bouton à la vue du composant
    [self addSubview:self.baseErrorButton];
#endif
}

-(void) initErrors {
    //Initialisation de la liste des erreurs et du bouton indiquant des erreurs sur le composant
    self.baseErrors = [[NSMutableArray alloc] init];
    self.baseErrorButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    self.baseErrorButton.backgroundColor = [UIColor clearColor];
    self.baseErrorButton.alpha = 0.0;
    [self.baseErrorButton addTarget:self action:@selector(toggleErrorInfo) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if(self.IB_enableIBStyle) {
        [self renderComponentFromInspectableAttributes];
    }
}

#pragma mark - Méthodes communes à tous les composants


-(void)setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor {
    _selfDescriptor = selfDescriptor;
    
#warning TODO: This call should be removed
    [self didFinishLoadDescriptor];
    [self didLoadFieldDescriptor:self.selfDescriptor];
    
    
}

-(void) didFinishLoadDescriptor __attribute__((deprecated("Use method didLoadFieldDescriptor: instead"))){
    //Default : nothing
}

-(void) didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    //Default : nothing
}



-(void)setIsValid:(BOOL)isValid {
    if (self.isValid != isValid) {
        _isValid = isValid;
        if (isValid) {
            [self hideErrorButtons];
        } else {
            [self showErrorButtons];
        }
    }
}


-(void)layoutSubviews {
    
//    if(self.IB_enableIBStyle) {
//        
//        [self willLayoutSubviewsDesignable];
//    }
#if !TARGET_INTERFACE_BUILDER
    
//    [self willLayoutSubviewsNoDesignable];
    [super layoutSubviews];
    
#else
#endif
    
//    if(self.IB_enableIBStyle) {
//        [self didLayoutSubviewsDesignable];
//    }
#if !TARGET_INTERFACE_BUILDER
    
//    [self didLayoutSubviewsNoDesignable];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self selfCustomization];
//    });
    
#else
#endif
    
    
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    // We remove all control's errors
    [self.baseErrors removeAllObjects];
    return 0;
}

-(NSInteger) validate {
    return [self validateWithParameters:nil];
}


-(id)getData {
    MFCoreLogError(@"The component %@ should have implemented the method called \"getData\"",self.class);
    return nil;
}

-(void)setData:(id)data {
    MFCoreLogError(@"The component %@ should have implemented the method called \"setData\"",self.class);
}

+ (NSString *) getDataType {
    MFCoreLogError(@"The component %@ should have implemented the method called \"getDataType\"",self.class);
    return nil;
}


#pragma mark - Customisation CSS


-(NSArray *)customizableComponents {
    return @[
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             ];
}

-(void) selfCustomization {
    //Nothing to do here.
}

#pragma mark - Méthodes du protocole mais non implémentées ici

-(BOOL)isActive {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes" userInfo:nil]);
}

-(void)setIsActive:(BOOL)isActive {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes" userInfo:nil]);
}



#pragma mark - Gestion et affichage des erreurs

-(void)showErrorButtons {
    CGFloat const value = 1.0f;
    if(value != self.baseErrorButton.alpha)
    {
        [[MFApplication getInstance] execInMainQueue:^{
            [UIView animateWithDuration:ERROR_BUTTON_ANIMATION_DURATION animations:^{
                [self bringSubviewToFront:self.baseErrorButton];
                self.baseErrorButton.frame = [self getErrorButtonFrameForInvalid];
                self.baseErrorButton.alpha = value;
                
            } completion:^(BOOL finished){
                //              self.isValid = NO;
                [self modifyComponentAfterShowErrorButtons];
            }];
        }];
    }
    
}

-(void)hideErrorButtons {
    [self hideErrorButtons:YES];
}

-(void) hideErrorButtons:(BOOL)anim {
    CGFloat const value = 0.0f;
    if(value != self.baseErrorButton.alpha)
    {
        void (^bloc)(void) = ^(void) {
            self.baseErrorButton.frame = [self getErrorButtonFrameForValid];
            //self.errorMesgLabel.hidden = YES;
            self.baseErrorButton.alpha = value;
        };
        
        [[MFApplication getInstance] execInMainQueue:^{
            if ( anim ) {
                [UIView animateWithDuration:ERROR_BUTTON_ANIMATION_DURATION animations:bloc completion:^(BOOL finished) {
                    //                    self.isValid = YES;
                    [self hideErrorTooltips];
                    [self modifyComponentAfterHideErrorButtons];
                }];
            } else {
                bloc();
            }
        }];
    }
}

-(void)modifyComponentAfterShowErrorButtons {
    //Default : nothing to do
}

-(void)modifyComponentAfterHideErrorButtons {
    //Default : nothing to do
}


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


-(void)showErrorTooltips {
    
    if( (self.baseErrors != nil) &&  [self.baseErrors count] >0) {
        if(nil == self.baseTooltipView.text){
            
            // We calculate the tooltip's anchor point
            CGPoint point = [self.baseErrorButton convertPoint:CGPointMake(0.0, self.baseErrorButton.frame.size.height - 4.0) toView:self];
            
            // We calculate the tooltip' size
            CGRect tooltipViewFrame = CGRectMake(-10, point.y, self.sender.frame.size.width, self.baseTooltipView.frame.size.height);
            
            // We create the tooltip' size
            self.baseTooltipView = [[InvalidTooltipView alloc] init];
            self.baseTooltipView.frame = tooltipViewFrame;
            
            // We build the tooltip's message : one message per line
            int errorNumber = 0;
            for (NSError *error in self.baseErrors) {
                if(errorNumber > 0){
                    self.baseTooltipView.text = [self.baseTooltipView.text stringByAppendingString: @"\n"];
                }
                errorNumber++;
                self.baseTooltipView.text = [self.baseTooltipView.text stringByAppendingString: [error localizedDescription]];
            }
            // We add tooltip to view
            [self addSubview:self.baseTooltipView];
            
            
            //Passage de la vue au premier plan
            UIView *currentView = self;
            do {
                UIView *superView = currentView.superview;
                [superView setClipsToBounds:NO];
                [superView bringSubviewToFront:currentView];
                currentView = superView;
            } while (currentView.tag != FORM_BASE_TABLEVIEW_TAG && currentView.tag != FORM_BASE_VIEW_TAG);
            [currentView bringSubviewToFront:self.baseTooltipView];
            [currentView bringSubviewToFront:self.baseErrorButton];
        }
    }
}

-(void)hideErrorTooltips {
    if (nil != self.baseTooltipView)
    {
        [self.baseTooltipView removeFromSuperview];
        self.baseTooltipView = nil;
    }
}

-(NSMutableArray *) getErrors {
    return self.baseErrors;
}

-(void) clearErrors{
    [self clearErrors:YES];
}

-(void) clearErrors:(BOOL)anim {
    [self.baseErrors removeAllObjects];
    [self hideErrorButtons:anim];
    [self hideErrorTooltips];
    [self setIsValid:YES];
}

-(void) addErrors:(NSArray *) errors{
    if(errors != nil && [errors count]) {
        [self setIsValid:NO];
        
        NSMutableArray *newErrors = [errors mutableCopy];
        for(NSError *error in errors) {
            if([self.baseErrors containsObject:error]) {
                [newErrors removeObject:error];
            }
        }
        [self.baseErrors addObjectsFromArray:newErrors];
    }
}

-(void)toggleErrorInfo {
    if (self.baseTooltipView == nil) {
        // please show error label
        [self showErrorTooltips];
    } else {
        // please hide error label
        [self hideErrorTooltips];
    }
}

-(MFConfigurationUIComponent *) loadConfiguration:(NSString *) configurationName {
    MFConfigurationUIComponent *config = nil;
    if(![NSString isNilOrEmpty:configurationName]){
        MFConfigurationHandler* registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
        config = [registry getVisualConfiguration:configurationName];
    }
    return config;
}




#pragma mark - Merge des configurations

+(NSNumber *) getBoolConfigurationWithValue:(NSNumber *)configurationValue andDefaultValue:(NSNumber *)defaultValue {
    return [self getNumberConfigurationWithValue:configurationValue andDefaultValue:defaultValue];
}

+(NSString *) getStringConfigurationWithValue:(NSString *)configurationValue andDefaultValue:(NSString *)defaultValue {
    NSString *returnValue;
    
    if(defaultValue == nil)
    {
        defaultValue = @"";
    }
    returnValue = defaultValue;
    
    if(configurationValue != nil)
    {
        returnValue = configurationValue;
    }
    
    return returnValue;
}

+(NSNumber *) getNumberConfigurationWithValue:(NSNumber *)configurationValue andDefaultValue:(NSNumber *)defaultValue {
    NSNumber *returnValue;
    
    if(defaultValue == nil)
    {
        defaultValue = [[NSNumber alloc] initWithInt:0];
    }
    returnValue = defaultValue;
    
    if(configurationValue != nil)
    {
        returnValue = configurationValue;
    }
    
    return returnValue;
}

-(void)dispatchEventOnValueChanged {
    NSString *bindingKey = ((MFFieldDescriptor *)self.sender.selfDescriptor).bindingKey;
    if(self.form && bindingKey) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.form dispatchEventOnComponentValueChangedWithKey:bindingKey atIndexPath:self.componentInCellAtIndexPath];
        });
    }
}

-(void) onChildValueChanged:(MFUIOldBaseComponent *) child {
    [self updateValue:[self getData]];
}

-(void)updateValue:(id) newValue {
    [self onUpdate](newValue);
}

-(void (^)(id x))onUpdate {
    __weak MFUIOldBaseComponent *weakSelf = self;
    return  ^(id x) {
        if(x){
            MFUIOldBaseComponent *strongSelf = weakSelf;
            id value = (NSString *) x;
            if (value) {
                // We validate the value
                if(![strongSelf validate]) {
                    // If there aren't any errors, we clean all component's errors
                    [strongSelf clearErrors];
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

-(void)setData:(id)data andUpdate:(BOOL)shouldUpdateAfterSettingData{
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        [self setData:data];
    }
    if(shouldUpdateAfterSettingData) {
        [self updateValue:data];
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//-(void) setInnerComponentsBackgroundColor:(NSDictionary *)componentsWithColors {
//    for(NSString *key in [componentsWithColors allKeys]) {
//        if([self respondsToSelector:NSSelectorFromString(key)]) {
//            MFUIOldBaseComponent *component = [self performSelector:NSSelectorFromString(key)];
//            dispatch_barrier_async(dispatch_get_main_queue(), ^{
//                [component setBackgroundColor:[componentsWithColors objectForKey:key]];
//            });
//        }
//    }
//}
#pragma clang diagnostic pop



-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.userInteractionEnabled = [editable isEqual:@1];
}



-(void)setForm:(id<MFComponentChangedListenerProtocol>)form {
    _form = form;
}


-(void) setTransitionDelegate:(id<MFUITransitionDelegate>)transitionDelegate {
    _transitionDelegate = transitionDelegate;
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
    self.IB_enableIBStyle = NO;
    self.backgroundColor = [UIColor clearColor];
}

-(void)prepareForInterfaceBuilder {
    self.backgroundColor = [UIColor clearColor];
}

@end

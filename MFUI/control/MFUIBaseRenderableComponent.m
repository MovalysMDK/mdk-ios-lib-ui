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

#import "MFUIBaseRenderableComponent.h"
#import "MFDefaultStyle.h"
#import "MFConstants.h"
#import "JDFTooltipView.h"

@interface MFUIBaseRenderableComponent ()

/**
 * @brief The view used to display that the component is in an invalid state
 */
@property (nonatomic, strong) MFUIErrorView *errorView;

/**
 * @brief The tooltip displayed when the user taps on the buttonError of the errorView
 */
@property (nonatomic, strong) JDFTooltipView *tooltipView;

/**
 * @brief The constraints applied to the internalView to this component.
 * @discussion These constraints can be modified by this class to display/hide the errorView
 */
@property (nonatomic, strong) NSLayoutConstraint *leftConstraint, *topConstraint, *rightConstraint, *bottomConstraint;

/**
 * @brief The constraints applied to the errorView to this component
 * @discussion These constraints can be modified by this class to display/hide the errorView
 */
@property (nonatomic, strong) NSLayoutConstraint *errorLeftConstraint, *errorCenterYConstraint, *errorWidthConstraint, *errorHeightConstraint;

@end


@implementation MFUIBaseRenderableComponent
@synthesize editable = _editable;

#pragma mark - Drawing component

/**
 * @brief The drawRect: UIview method
 * @discussion Following this view represents the internal view or the external view of the component,
 * this method do some specific treatments
 */
-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if([self conformsToProtocol:@protocol(MFExternalComponent)]) {
        if(self.internalView) {
            [self.internalView removeFromSuperview];
        }
        @try {
            Class bundleClass = [[self frameworkXIBs] containsObject:[self retrieveCustomXIB]] ?  NSClassFromString([self retrieveCustomXIB]) : NSClassFromString(@"AppDelegate");
            Class errorBundleClass = [[self frameworkXIBs] containsObject:[self retrieveCustomErrorXIB]] ?  NSClassFromString(@"MFUIApplication") : NSClassFromString(@"AppDelegate");
            
            self.internalView = [[[NSBundle bundleForClass:bundleClass] loadNibNamed:[self retrieveCustomXIB] owner:nil options:nil] firstObject];
            self.errorView = [[[NSBundle bundleForClass:errorBundleClass] loadNibNamed:[self retrieveCustomErrorXIB] owner:nil options:nil] firstObject];
            self.errorView.userInteractionEnabled = YES;
            [self.internalView performSelector:@selector(setExternalView:) withObject:self];
            
        }
        @catch(NSException *e) {
            NSLog(@"%@", e.description);
        }
        @finally {
            NSString *b = [NSBundle bundleForClass:NSClassFromString([self retrieveCustomXIB])].description;
            NSLog(@"%@", b);
        }
        
        [self addSubview:self.internalView];
        [self defineInternalViewConstraints];
        
        [(id<MFInternalComponent>)self.internalView forwardOutlets:self];
        if([self respondsToSelector:@selector(didInitializeOutlets)]) {
            [self performSelector:@selector(didInitializeOutlets)];
        }
        [self forwardBaseRenderableProperties];
        [self forwardSpecificRenderableProperties];
        [self setDisplayComponentValue:self.componentData];
        
    }
    else if([self conformsToProtocol:@protocol(MFInternalComponent)]){
        [self computeStyleClass];
        [self applyStandardStyle];
        [self renderComponent:self];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

/**
 * @brief Defines the constraints of the internal view in the external view
 */
-(void) defineInternalViewConstraints {
#if !TARGET_INTERFACE_BUILDER
    
    self.leftConstraint = nil;
    self.bottomConstraint = nil;
    self.rightConstraint = nil;
    self.topConstraint = nil;
    
    if(!self.leftConstraint) {
        self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:[self isValid] ? 0 : self.errorView.frame.size.width];
        [self addConstraint:self.leftConstraint];
    }
    
    if(!self.topConstraint) {
        self.topConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:self.topConstraint];
    }
    
    if(!self.rightConstraint) {
        self.rightConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        [self addConstraint:self.rightConstraint];
    }
    
    if(!self.bottomConstraint) {
        self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self addConstraint:self.bottomConstraint];
    }
#else
    self.internalView.frame = self.bounds;
#endif
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.errorView.alpha = 1.0;
                         [self layoutIfNeeded]; // Called on parent view
                     }];
}

/**
 * @brief Defines the constraints of the error view in the external view
 */
-(void) defineErrorViewConstraints {
#if !TARGET_INTERFACE_BUILDER
    self.errorView.translatesAutoresizingMaskIntoConstraints = NO;
    if(!self.errorLeftConstraint) {
        self.errorLeftConstraint = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        [self addConstraint:self.errorLeftConstraint];
    }
    
    if(!self.errorCenterYConstraint) {
        self.errorCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraint:self.errorCenterYConstraint];
    }
    
    if(!self.errorHeightConstraint) {
        self.errorHeightConstraint = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.errorView.frame.size.height];
        [self addConstraint:self.errorHeightConstraint];
    }
    
    if(!self.errorWidthConstraint) {
        self.errorWidthConstraint = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.errorView.frame.size.width];
        [self addConstraint:self.errorWidthConstraint];
    }
#else
    self.internalView.frame = self.bounds;
#endif
}

/**
 * @brief Retrieves a custom XIB if defined in InterfaceBuilder.
 * @return The name of the custom XIB to load
 */
-(NSString *)retrieveCustomXIB {
    if([((id<MFExternalComponent>)self) customXIBName]) {
        return [((id<MFExternalComponent>)self) customXIBName];
    }
    else {
        return [((id<MFExternalComponent>)self) defaultXIBName];
    }
}

/**
 * @brief Retrieves a custom XIB if defined in InterfaceBuilder.
 * @return The name of the custom XIB to load
 */
-(NSString *)retrieveCustomErrorXIB {
    if([((id<MFExternalComponent>)self) customErrorXIBName]) {
        return [((id<MFExternalComponent>)self) customErrorXIBName];
    }
    else {
        return [((id<MFExternalComponent>)self) defaultErrorXIBName];
    }
}

/**
 * @brief An array that describes the list of framework XIBs
 * @return An array that contains the files names of the framework components XIB's
 */
-(NSArray *) frameworkXIBs {
    return @[
             @"MFUILabel",
             @"MFUIErrorView",
             @"MFUITextField",
             ];
}

/**
 * @brief Returns the name of the default XIB file to render the error view
 */
-(NSString *)defaultErrorXIBName {
    return @"MFUIErrorView";
}


#pragma mark - Live Rendering
/**
 * @brief Renders the component using the specific renderable properties.
 * @discussion In this MFBaseRenderableComoponent class, the base inspectable properties are used
 * to render the global appearence of the component.
 * @discussion This method should be used to increase the rendering on components that intherits from
 * this base class
 * @discussion This method is called in the (drawRect:) UIView's method
 * @param view The renderable component view to render using specific inspectable properties
 */
-(void)renderComponent:(MFUIBaseRenderableComponent *)view {
    view.layer.borderWidth = self.IB_borderWidth;
    view.layer.borderColor = self.IB_borderColor.CGColor;
    view.layer.cornerRadius = self.IB_cornerRadius;
    view.layer.masksToBounds = YES;
    view.tooltipView.tooltipBackgroundColour = self.IB_tooltipBgColor;
}

/**
 * @brief This required method must forward specific renderable properties on
 * the internal view.
 * @discussion Due to the different possible types for IBInspectable attributes, it's actually not possible
 * to forward automatically the IBInspectable attributes from the external view to the internal view.
 * @discussion Forwarding these properties allows you to used them both on the XIB that represents the Internal view
 * and the Storyboard that contains the external view.
 * @discussion This method is called when this MFBaseRenderableComponent is an external view only.
 */
-(void)forwardSpecificRenderableProperties {
    //Exception
}


/**
 * @brief Forwards the tjhe base renderable properties on the intenal view
 */
-(void) forwardBaseRenderableProperties {
    if(self.IB_borderColor) {
        self.internalView.IB_borderColor = self.IB_borderColor;
    }
    if(self.IB_borderWidth) {
        self.internalView.IB_borderWidth = self.IB_borderWidth;
    }
    if(self.IB_cornerRadius) {
        self.internalView.IB_cornerRadius = self.IB_cornerRadius;
    }
    if(self.styleClass) {
        self.internalView.styleClass = self.styleClass;
    }
    if(self.IB_tooltipBgColor) {
        self.internalView.IB_tooltipBgColor = self.IB_tooltipBgColor;
    }
}


-(void)prepareForInterfaceBuilder {
    
    [super prepareForInterfaceBuilder];
    [(id<MFInternalComponent>)self.internalView forwardOutlets:self];
    [self computeStyleClass];
    if(self.IB_onError) {
        [self applyStandardStyle];
        [self applyErrorStyle];
    }
    else {
        [self applyStandardStyle];
        [self applyValidStyle];
    }
    [self showError:self.IB_onError];
}


#pragma mark - Style


-(void) computeStyleClass {
    /**
     * Style priority :
     * 1. User Defined Runtime Attribute named "styleClass"
     * 2. Class style based on the component class name
     * 3. Class style defined as a bean base on the component class name
     * 4. Default Movalys style
     */
    Class componentClassStyle = NSClassFromString([NSString stringWithFormat:@"%@Style", NSStringFromClass([self superclass])]);
    if(self.styleClass) {
        self.baseStyleClass = NSClassFromString(self.styleClass);
    }
    else if(componentClassStyle){
        self.baseStyleClass = componentClassStyle;
    }
    //TODO: Style via BeanLoader
    else {
        self.baseStyleClass = NSClassFromString(@"MFDefaultStyle");
    }
}


-(void)setStyleClass:(NSString *)styleClass {
    _styleClass = styleClass;
    if(_styleClass) {
        [[[NSClassFromString(self.styleClass) alloc] init] performSelector:@selector(applyStyleOnView:) withObject:self];
    }
}

-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.internalView.userInteractionEnabled = [editable isEqual:@1];
}

#pragma mark - Generic methods for ExternalComponent
/**
 * @brief This method is optional and already implemented in MFBaseRenderableComponent.
 * It allows to forward outlets from this "InternalView" to the "ExternalView". This forward
 * is automatic, but this method should be overloaded if the developer want to forward others
 * unforwarded outlets.
 * @param receiver The receiver of the forward
 */
-(void) forwardOutlets:(MFUIBaseRenderableComponent *)parent {
    //TODO: Cache
    Class clazz = [self class];
    u_int count;
    NSMutableArray* propertyArray = [NSMutableArray array];
    
    while(clazz != nil) {
        objc_property_t* properties = class_copyPropertyList(clazz, &count);
        
        for (int i = 0; i < count ; i++)
        {
            const char* propertyAttributesAsChar = property_getAttributes(properties[i]);
            const char* propertyName = property_getName(properties[i]);
            NSArray *propertyAttributes = [[NSString stringWithFormat:@"%s",propertyAttributesAsChar] componentsSeparatedByString:@","];
            BOOL isCandidate = YES;
            BOOL isView = NO;
            for(NSString *propertyAttribute in propertyAttributes) {
                if([propertyAttribute containsString:@"UILabel"]) {
                    YES;
                }
                if([propertyAttribute hasPrefix:@"T@"] && [propertyAttribute componentsSeparatedByString:@"\""].count > 1){
                    if([NSClassFromString([propertyAttribute componentsSeparatedByString:@"\""][1]) isSubclassOfClass:NSClassFromString(@"UIView")]) {
                        isView = YES;
                        break;
                    }
                }
            }
            isCandidate = isCandidate && [propertyAttributes containsObject:@"W"];
            isCandidate = isCandidate && isView;
            if(isCandidate) {
                [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            }
        }
        free(properties);
        clazz = [clazz superclass];
    }
    
    NSArray *forbiddenCandidate = @[@"sender", @"mfParent", @"scrollingTableView", @"internalView", @"externalView"];
    for(NSString *candidatePropertyForForwarding in propertyArray) {
        if([forbiddenCandidate containsObject:candidatePropertyForForwarding]) {
            continue;
        }
        NSString *getterSelectorAsString = [NSString stringWithFormat:@"%@", candidatePropertyForForwarding];
        
        NSString *capitalizedSentence = [getterSelectorAsString stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                        withString:[[getterSelectorAsString substringToIndex:1] capitalizedString]];
        NSString *setterSelectorAsString = [NSString stringWithFormat:@"set%@:", capitalizedSentence];
        SEL setterSelector = NSSelectorFromString(setterSelectorAsString);
        SEL getterSelector = NSSelectorFromString(getterSelectorAsString);
        if([parent respondsToSelector:setterSelector]) {
            [parent performSelector:setterSelector withObject:[self performSelector:getterSelector]];
        }
    }
    
    //Automatic test
    if([self respondsToSelector:@selector(setAllTags)]) {
        [self performSelector:@selector(setAllTags)];
    }
    
}

#pragma mark - Managing error

/**
 * @brief Allows to display or not the view that indicates that the component is in an invalid state
 * @param showErrorView A BOOL value that indicates if the component is in an invalid state or not
 */
-(void) showError:(BOOL)showError {
    if([self conformsToProtocol:@protocol(MFExternalComponent) ] && self.errorView) {
        
        if(showError) {
            [self addSubview:self.errorView];
            self.tooltipView = [[JDFTooltipView alloc] initWithTargetView:self.errorView.errorButton hostView:self tooltipText:@"" arrowDirection:JDFTooltipViewArrowDirectionUp width:self.frame.size.width];
            
            [self defineErrorViewConstraints];
            self.leftConstraint.constant  = self.errorView.frame.size.width;
            
            self.errorView.alpha = 0.0;
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.errorView.alpha = 1.0;
                                 [self layoutIfNeeded]; // Called on parent view
                             }];
        }
        else {
            [self.tooltipView hideAnimated:YES];
            [self.errorView removeFromSuperview];
            if(self.errorWidthConstraint) [self removeConstraint:self.errorWidthConstraint];
            if(self.errorLeftConstraint) [self removeConstraint:self.errorLeftConstraint];
            if(self.errorHeightConstraint) [self removeConstraint:self.errorHeightConstraint];
            if(self.errorCenterYConstraint) [self removeConstraint:self.errorCenterYConstraint];
            
            self.errorCenterYConstraint = nil;
            self.errorHeightConstraint = nil;
            self.errorLeftConstraint = nil;
            self.errorWidthConstraint = nil;
            self.leftConstraint.constant  = 0;
            [UIView animateWithDuration:0.25
                             animations:^{
                                 [self layoutIfNeeded];
                             }
             ];
        }
        [self bringSubviewToFront:self.errorView];
    }
    
}

/**
 * @brief This method describes the treatment to do when the user click the error button of this component
 * @discussion By default, this method displays the error information
 */
-(void)doOnErrorButtonClicked {
    if(![self.tooltipView superview]) {
        NSString *errorText = @"";
        
        int errorNumber = 0;
        for (NSError *error in self.baseErrors) {
            if(errorNumber > 0){
                errorText = [errorText stringByAppendingString: @"\n"];
            }
            errorNumber++;
            errorText= [errorText stringByAppendingString: [error localizedDescription]];
        }
        //Passage de la vue au premier plan
        UIView *currentView = self;
        do {
            UIView *superView = currentView.superview;
            [superView setClipsToBounds:NO];
            [superView bringSubviewToFront:currentView];
            currentView = superView;
        } while (currentView.tag != FORM_BASE_TABLEVIEW_TAG && currentView.tag != FORM_BASE_VIEW_TAG);
        [currentView bringSubviewToFront:self.tooltipView];
        [currentView bringSubviewToFront:self.errorView];
        self.tooltipView.tooltipText = errorText;
        self.tooltipView.tooltipBackgroundColour = self.IB_tooltipBgColor ? self.IB_tooltipBgColor : [self defaultTooltipBackgroundColor];
        
        [self.tooltipView show];
        [self bringSubviewToFront:self.tooltipView];
    }
    else {
        [self.tooltipView hideAnimated:YES];
    }
    [self bringSubviewToFront:self.tooltipView];
}

-(UIColor *) defaultTooltipBackgroundColor {
    return [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1];
}

-(void)setForm:(id<MFComponentChangedListenerProtocol>)form {
    [super setForm:form];
    if([self conformsToProtocol:@protocol(MFExternalComponent)]) {
        [self.internalView setForm:form];
    }
}

-(void)setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor {
    [super setSelfDescriptor:selfDescriptor];
    if([self conformsToProtocol:@protocol(MFExternalComponent)]) {
        [self.internalView setSelfDescriptor:selfDescriptor];
    }
}

@end

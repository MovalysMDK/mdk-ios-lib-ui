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
 * @brief This dictionary contains the name of the XIBs used to load base MDK iOS components.
 * @discussion It is loaded from the "Framework-components.plist" file from the generated project
 * @discussion The developer can modify this file to use a custom XIB for a MDK Component Type.
 */
@property (nonatomic, strong) NSDictionary *baseMDKComponentsXIBsName;

/**
 * @brief The constraints applied to the internalView to this component.
 * @discussion These constraints can be modified by this class to display/hide the errorView
 */
@property (nonatomic, weak) NSLayoutConstraint *leftConstraint, *topConstraint, *rightConstraint, *bottomConstraint;

/**
 * @brief The constraints applied to the errorView to this component
 * @discussion These constraints can be modified by this class to display/hide the errorView
 */
@property (nonatomic, weak) NSLayoutConstraint *errorLeftConstraint, *errorCenterYConstraint, *errorWidthConstraint, *errorHeightConstraint;

@end


@implementation MFUIBaseRenderableComponent
@synthesize editable = _editable;
@synthesize styleClass = _styleClass;
@synthesize tooltipView = _tooltipView;

const struct ErrorPositionParameters_Struct ErrorPositionParameters = {
    .ErrorView = @"ErrorView",
    .ParentView = @"ParentView",
    .InternalViewLeftConstraint = @"InternalViewLeftConstraint",
    .InternalViewTopConstraint = @"InternalViewTopConstraint",
    .InternalViewRightConstraint = @"InternalViewRightConstraint",
    .InternalViewBottomConstraint = @"InternalViewbottomConstraint"
};

-(void)initialize {
    self.baseMDKComponentsXIBsName = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:NSClassFromString(@"AppDelegate")] pathForResource:@"Framework-components" ofType:@"plist"]];
    [super initialize];
}

-(void) commonInit {
    if([self conformsToProtocol:@protocol(MFExternalComponent)]) {
        
        if(self.internalView) {
            [self.internalView removeFromSuperview];
        }
        @try {
            Class bundleClass = [[self retrieveCustomXIB] hasPrefix:MDK_XIB_IDENTIFIER] ?  NSClassFromString(@"MFUIApplication") : NSClassFromString(@"AppDelegate");

            
            self.internalView = [[[NSBundle bundleForClass:bundleClass] loadNibNamed:[self retrieveCustomXIB] owner:self options:nil] firstObject];

            [self.internalView performSelector:@selector(setExternalView:) withObject:self];
            
        }
        @catch(NSException *e) {
            NSLog(@"%@", e.description);
        }
        
        [self addSubview:self.internalView];
        if(self.internalView) {
            [self setNeedsUpdateConstraints];
        }
        [self setDisplayComponentValue:self.componentData];
        [self forwardBaseRenderableProperties];
        [self forwardSpecificRenderableProperties];
        
    }
    else if([self conformsToProtocol:@protocol(MFInternalComponent)]){
        [self applyStandardStyle];
        [self renderComponent:self];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self computeStyleClass];
    
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
    [self didInitializeOutlets];
}


-(void)updateConstraints {
    [self defineInternalViewConstraints];
    [super updateConstraints];
}

-(void) didInitializeOutlets {
    //    [self commonInit];
}

#pragma mark - Drawing component


/**
 * @brief Defines the constraints of the internal view in the external view
 */
-(void) defineInternalViewConstraints {
    
    self.leftConstraint = nil;
    self.bottomConstraint = nil;
    self.rightConstraint = nil;
    self.topConstraint = nil;
    
    if(self.internalView) {
#if TARGET_INTERFACE_BUILDER
        if(!self.leftConstraint) {
            self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:![self onError_MDK] ? 0 : self.errorView.frame.size.width];
            [self addConstraint:self.leftConstraint];
        }
#else
        if(!self.leftConstraint) {
            self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.internalView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:[self isValid] ? 0 : self.errorView.frame.size.width];
            [self addConstraint:self.leftConstraint];
        }
#endif
        
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
    }
    //    self.internalView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [UIView animateWithDuration:0.0
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
        return [self.baseMDKComponentsXIBsName objectForKey:[((id<MFExternalComponent>)self) defaultXIBName]];
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
 * @brief Returns the name of the default XIB file to render the error view
 */
-(NSString *)defaultErrorXIBName {
    return @"MDK_MFUIErrorView";
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
    view.layer.borderWidth = self.borderWidth_MDK;
    view.layer.borderColor = self.borderColor_MDK.CGColor;
    view.layer.cornerRadius = self.cornerRadius_MDK;
    view.layer.masksToBounds = YES;
    view.tooltipView.tooltipBackgroundColour = self.tooltipColor_MDK;
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
 * @brief Forwards the the base renderable properties on the intenal view
 */
-(void) forwardBaseRenderableProperties {
    if(self.borderColor_MDK) {
        self.internalView.borderColor_MDK = self.borderColor_MDK;
    }
    if(self.borderWidth_MDK) {
        self.internalView.borderWidth_MDK = self.borderWidth_MDK;
    }
    if(self.cornerRadius_MDK) {
        self.internalView.cornerRadius_MDK = self.cornerRadius_MDK;
    }
    if(self.tooltipColor_MDK) {
        self.internalView.tooltipColor_MDK = self.tooltipColor_MDK;
    }
    if(self.styleClass) {
        self.internalView.styleClass = self.styleClass;
    }
    [self.internalView renderComponent:self.internalView];
}


-(void)prepareForInterfaceBuilder {
    
    [super prepareForInterfaceBuilder];
    [self commonInit];
    [self computeStyleClass];
    if(self.onError_MDK) {
        [self applyStandardStyle];
        [self applyErrorStyle];
    }
    else {
        [self applyStandardStyle];
        [self applyValidStyle];
    }
    [self showError:self.onError_MDK];
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
    NSString *componentClassStyleName = [NSString stringWithFormat:@"%@Style", [self class]];
    
    if(self.styleClassName) {
        self.styleClass = [NSClassFromString(self.styleClassName) new];
    }
    else if(componentClassStyleName){
        self.styleClass = [NSClassFromString(componentClassStyleName) new];
    }
    //TODO: Style via BeanLoader
    else {
        self.styleClass = [NSClassFromString(@"MFDefaultStyle") new];
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)setStyleClass:(NSString *)styleClass {
    _styleClass = styleClass;
    if(_styleClass) {
        [[[NSClassFromString(self.styleClass) alloc] init] performSelector:@selector(applyStyleOnView:) withObject:self];
    }
}
#pragma clang diagnostic pop


-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.internalView.userInteractionEnabled = [editable isEqual:@1];
}

#pragma mark - Generic methods for ExternalComponent

#pragma mark - Managing error

/**
 * @brief Allows to display or not the view that indicates that the component is in an invalid state
 * @param showErrorView A BOOL value that indicates if the component is in an invalid state or not
 */
-(void) showError:(BOOL)showError {

    if([self conformsToProtocol:@protocol(MFExternalComponent) ]) {
        
        if(showError) {
            if(!self.errorView) {
                Class errorBundleClass = [[self retrieveCustomErrorXIB] hasPrefix:MDK_XIB_IDENTIFIER] ?  NSClassFromString(@"MFUIApplication") : NSClassFromString(@"AppDelegate");
                self.errorView = [[[NSBundle bundleForClass:errorBundleClass] loadNibNamed:[self retrieveCustomErrorXIB] owner:nil options:nil] firstObject];
            }
            self.errorView.userInteractionEnabled = YES;
            [self addSubview:self.errorView];
            self.tooltipView = [[JDFTooltipView alloc] initWithTargetView:self.errorView.errorButton hostView:self tooltipText:@"" arrowDirection:JDFTooltipViewArrowDirectionUp width:self.frame.size.width];
            
            if([self respondsToSelector:@selector(definePositionOfErrorViewWithParameters:whenShown:)]) {
#if !TARGET_INTERFACE_BUILDER
                NSDictionary *errorPositionParameters = [NSDictionary
                                                         dictionaryWithObjects:@[self.errorView,
                                                                                 self,
                                                                                 self.leftConstraint,
                                                                                 self.topConstraint,
                                                                                 self.rightConstraint,
                                                                                 self.bottomConstraint]
                                                         forKeys:@[ErrorPositionParameters.ErrorView,
                                                                   ErrorPositionParameters.ParentView,
                                                                   ErrorPositionParameters.InternalViewLeftConstraint,
                                                                   ErrorPositionParameters.InternalViewTopConstraint,
                                                                   ErrorPositionParameters.InternalViewRightConstraint,
                                                                   ErrorPositionParameters.InternalViewBottomConstraint]];
                
                [self definePositionOfErrorViewWithParameters:errorPositionParameters whenShown:showError];
#endif

            }
            else {
                [self defineErrorViewConstraints];
                self.leftConstraint.constant  = self.errorView.frame.size.width;
            }
            
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
            if([self respondsToSelector:@selector(definePositionOfErrorViewWithParameters:whenShown:)]) {
#if !TARGET_INTERFACE_BUILDER

                NSDictionary *errorPositionParameters = [NSDictionary
                                                         dictionaryWithObjects:@[self.errorView,
                                                                                 self,
                                                                                 self.leftConstraint,
                                                                                 self.topConstraint,
                                                                                 self.rightConstraint,
                                                                                 self.bottomConstraint]
                                                         forKeys:@[ErrorPositionParameters.ErrorView,
                                                                   ErrorPositionParameters.ParentView,
                                                                   ErrorPositionParameters.InternalViewLeftConstraint,
                                                                   ErrorPositionParameters.InternalViewTopConstraint,
                                                                   ErrorPositionParameters.InternalViewRightConstraint,
                                                                   ErrorPositionParameters.InternalViewBottomConstraint]];
                
                [self definePositionOfErrorViewWithParameters:errorPositionParameters whenShown:showError];
#endif
            }
            else {
                if(self.errorWidthConstraint) [self removeConstraint:self.errorWidthConstraint];
                if(self.errorLeftConstraint) [self removeConstraint:self.errorLeftConstraint];
                if(self.errorHeightConstraint) [self removeConstraint:self.errorHeightConstraint];
                if(self.errorCenterYConstraint) [self removeConstraint:self.errorCenterYConstraint];
                
                self.errorCenterYConstraint = nil;
                self.errorHeightConstraint = nil;
                self.errorLeftConstraint = nil;
                self.errorWidthConstraint = nil;
                self.leftConstraint.constant  = 0;
            }

            

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
        for (NSError *error in self.errors) {
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
        self.tooltipView.tooltipBackgroundColour = self.tooltipColor_MDK ? self.tooltipColor_MDK : [self defaultTooltipBackgroundColor];
        
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


-(NSString *)className {
    return [self respondsToSelector:@selector(defaultXIBName)] ? [[self performSelector:@selector(defaultXIBName)] stringByReplacingOccurrencesOfString:MDK_XIB_IDENTIFIER withString:@""] : nil;
}

-(void)addErrors:(NSArray *)errors {
    [super addErrors:errors];
    [self applyErrorStyle];
}

-(void)clearErrors {
    [super clearErrors];
    [self applyValidStyle];
}


-(NSString *)defaultXIBName {
    return NSStringFromClass(self.class);
}

-(void)setDisplayComponentValue:(id)value {
    
}

-(void)definePositionOfErrorViewWithParameters:(NSDictionary *)parameters whenShown:(BOOL)isShown {
    
}
#pragma mark - LiveRendering

@end

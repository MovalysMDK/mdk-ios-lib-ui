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

#import "MFComponentBindingDelegate.h"
#import "MFUIComponentProtocol.h"
#import "MFStyleProtocol.h"
#import "MFConstants.h"
#import "MFErrorViewProtocol.h"
#import "UIView+Styleable.h"

@interface MFComponentBindingDelegate ()

@property (nonatomic, weak) UIView<MFUIComponentProtocol> *component;

@end

@implementation MFComponentBindingDelegate


-(instancetype)initWithComponent:(id<MFUIComponentProtocol>)component {
    self = [super init];
    if(self) {
        self.component = component;
        [self computeStyleClass];
#if !TARGET_INTERFACE_BUILDER
        [self.component addObserver:self forKeyPath:@"selfDescriptor" options:NSKeyValueObservingOptionNew context:NULL];
#endif
    }
    return self;
}


-(void)clearErrors {
    [self.component setIsValid:YES];
}

-(void)updateValue:(id) newValue {
    [self onUpdate](newValue);
}

-(void (^)(id x))onUpdate {
    __weak id<MFUIComponentProtocol> weakSelf = self.component;
    return  ^(id x) {
        if(x){
            id<MFUIComponentProtocol> strongSelf = weakSelf;
            id value = (NSString *) x;
            if (value) {
                // We validate the value
                if([strongSelf validateWithParameters:nil] == 0) {
                    // If there aren't any errors, we clean all component's errors
                    [strongSelf.bindingDelegate clearErrors];
                }
                else {
                    [strongSelf showError:YES];
                }
            }
            else {
                [strongSelf showError:YES];
            }
            if (![self.component inInitMode]) {
                [strongSelf.bindingDelegate dispatchEventOnValueChanged];
            }
            
        }
    };
}

-(void)dispatchEventOnValueChanged {
    NSString *bindingKey = ((MFFieldDescriptor *)self.component.selfDescriptor).bindingKey;
    if(self.component.form && bindingKey) {
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.component.form dispatchEventOnComponentValueChangedWithKey:bindingKey atIndexPath:self.component.componentInCellAtIndexPath];
        });
    }
}

-(NSMutableArray *) getErrors {
    return [@[] mutableCopy];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"selfDescriptor"]) {
        [(id<MFUIComponentProtocol>)object didLoadFieldDescriptor:change[NSKeyValueChangeNewKey]];
    }
    
}

-(void)dealloc {
    [self.component removeObserver:self forKeyPath:@"selfDescriptor"];
}

-(NSInteger)validate {
    return [self.component validateWithParameters:nil];
}

-(void)addErrors:(NSArray *)errors {
    if(errors) {
        [self.component.errors addObjectsFromArray:errors];
    }
    [self.component showError:self.component.errors.count];
}

-(void)setIsValid:(BOOL)isValid {
    [self.component applyStandardStyle];
    if(isValid) {
        [self.component applyValidStyle];
        [self.component.tooltipView hideAnimated:YES];
        
    }
    else{
        [self.component applyErrorStyle];
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
@end

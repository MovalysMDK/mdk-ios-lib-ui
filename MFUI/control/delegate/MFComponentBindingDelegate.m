//
//  MFComponentBindingDelegate.m
//  MFUI
//
//  Created by Quentin Lagarde on 21/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFComponentBindingDelegate.h"
#import "MFUIComponentProtocol.h"
#import "MFStyleProtocol.h"
#import "MFConstants.h"
#import "MFErrorViewProtocol.h"

@interface MFComponentBindingDelegate ()

@property (nonatomic, weak) UIView<MFUIComponentProtocol> *component;

@end

@implementation MFComponentBindingDelegate


-(instancetype)initWithComponent:(id<MFUIComponentProtocol>)component {
    self = [super init];
    if(self) {
        self.component = component;
        
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
    [self.component.styleClass applyStandardStyleOnComponent:self.component];
    if(isValid) {
        [self.component.styleClass applyValidStyleOnComponent:self.component];
        [self.component.tooltipView hideAnimated:YES];
        
    }
    else{
        [self.component.styleClass applyErrorStyleOnComponent:self.component];
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
@end

    //
//  MFButton.m
//  MFUI
//
//  Created by Sébastien Pacreau on 10/06/13.
//  Copyright (c) 2013 Sopra Consulting. All rights reserved.
//

#import <MFCore/MFCoreBean.h>


#import "MFButton.h"


@interface MFButton()

@property (nonatomic, strong) NSString *selectorName;

@property (nonatomic, weak) id temporaryTarget;

@end


@implementation MFButton

#pragma mark - Constructeurs et initialisation


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        //        [self initialize];
    }
    return self;
}



-(void) initialize {
    //Création du bouton et ajout à la vue
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.button.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.button];
    
    
    NSLayoutConstraint *insideButtonConstraintLeftMargin = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *insideButtonConstraintTopMargin = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *insideButtonConstraintRight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.button attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *insideButtonConstraintBottom = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraints:@[insideButtonConstraintLeftMargin, insideButtonConstraintTopMargin, insideButtonConstraintBottom, insideButtonConstraintRight]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self respondsToSelector:@selector(mf)]) {
            NSString *buttonTitle = self.mf.title;
            if(buttonTitle) {
                [self.button setTitle:buttonTitle forState:UIControlStateNormal];
            }
        }
    });
    
    [self.button addTarget:self action:@selector(launchAction) forControlEvents:UIControlEventTouchDown];
    
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.button.tag == 0) {
        [self.button setTag:TAG_MFBUTTON_BUTTON];
    }
}



#pragma mark - Fast Forwarding UIButton methods
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.button;
}


#pragma mark - KVC magic forwarding
-(id)valueForUndefinedKey:(NSString *)key {
    if(![key isEqualToString:@"mf."])
    {
        return [self.button valueForKey:key];
    }
    else {
        return [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.button setValue:value forKey:key];
    
}

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    self.selectorName = NSStringFromSelector(action);
    self.temporaryTarget = target;
    [self.button addTarget:self action:@selector(customAction) forControlEvents:controlEvents];
}

-(void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    self.selectorName = nil;
    self.temporaryTarget = nil;
    [self.button removeTarget:self action:@selector(customAction) forControlEvents:controlEvents];
}

-(void) customAction {
    if([self.temporaryTarget respondsToSelector:NSSelectorFromString(self.selectorName)]) {
        [self.temporaryTarget performSelector:NSSelectorFromString(self.selectorName) withObject:self afterDelay:0];
    }
}


-(void) launchAction {
    if (self.mf.actionName != nil) {
        Class actionClass = NSClassFromString(self.mf.actionName);
        if (actionClass != nil) {
            [[MFApplication getInstance] launchAction:self.mf.actionName withCaller:self withInParameter:nil];
        }
    }
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.button setEnabled:([editable isEqualToNumber:@1]? YES : NO)];
}


@end

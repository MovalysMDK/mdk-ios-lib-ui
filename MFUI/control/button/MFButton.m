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
    [super initialize];
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
        return [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
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

-(void)prepareForInterfaceBuilder {
    UILabel *innerDescriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    innerDescriptionLabel.text = self.mf.title;
    innerDescriptionLabel.textColor = self.tintColor;
    innerDescriptionLabel.textAlignment = NSTextAlignmentCenter;
//    innerDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    innerDescriptionLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:innerDescriptionLabel];
}


@end

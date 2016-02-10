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
//  MFAutoLayoutHelper.m
//  MFCore
//
//

#import "MFAutoLayoutHelper.h"

@implementation MFAutoLayoutHelper

-(id) initWithReferenceView:(UIView*) view {
    self = [super init];
    if (self) {
        self.referenceView = view;
        self.referenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

-(void) addSubview:(UIView *)view {
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.referenceView addSubview:view];
}

-(void) addSubviewWithFullSize:(UIView *)view {
    [self addSubview:view];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.referenceView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.referenceView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.referenceView addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.referenceView addConstraint:constraint];
}

-(UIView*) createGhost {
    UIView *ghost = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    ghost.backgroundColor = [UIColor clearColor];
    [self addSubview:ghost];
    return ghost;
}

-(float) computeRatio:(UIView *)component {
    if(component) {
        if(component.bounds.size.height != 0) {
            return component.bounds.size.width/component.bounds.size.height;
        }
        else {
            return 0;
        }
    }
    return 0;
    //UIImageView *tempView = component;
    //return tempView.image.size.width/tempView.image.size.height;
}

-(void) setFixedHeightInPercentFromParent:(float)heightInPercent toComponent:(UIView*)component withRatio:(float) ratio{
    if(component) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeHeight multiplier:heightInPercent/100 constant:0];
        [self.referenceView addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeHeight multiplier:ratio constant:0];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setFixedWidthInPercentFromParent:(float)widthInPercent andFixedHeight:(float) height toComponent:(UIView*)component{
    if(component) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeWidth multiplier:widthInPercent/100 constant:0];
        [self.referenceView addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setFixedHeightInPercentFromParent:(float)heightInPercent andFixedWidth:(float) width toComponent:(UIView*)component{
    if(component) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeHeight multiplier:heightInPercent/100 constant:0];
        [self.referenceView addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setCenterXToComponent:(UIView*)component {
    if(component) {
        NSLayoutConstraint *constraint  = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setCenterYToComponent:(UIView*)component {
    if(component) {
        NSLayoutConstraint *constraint  = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setYFlexSpace:(float)space betweenTop:(UIView*) component1 andTop:(UIView*) component2 {
    if(component1 && component2) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:component2 attribute:NSLayoutAttributeTop multiplier:1 constant:space];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setYFixedSpace:(float)space betweenTop:(UIView*) component1 andTop:(UIView*) component2 {
    if(component1 && component2) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:component2 attribute:NSLayoutAttributeTop multiplier:1 constant:space];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setYFixedSpace:(float)space betweenTop:(UIView*) component1 andBottom:(UIView*) component2 {
    if(component1 && component2) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:component2 attribute:NSLayoutAttributeBottom multiplier:1 constant:space];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setYFixedSpace:(float)space betweenBottom:(UIView*) component1 andBottom:(UIView*) component2 {
    if(component1 && component2) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:component2 attribute:NSLayoutAttributeBottom multiplier:1 constant:space];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setYFlexSpace:(float)space betweenTop:(UIView*) component1 andBottom:(UIView*) component2 {
    if(component1 && component2) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:component2 attribute:NSLayoutAttributeBottom multiplier:1 constant:space];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setFixedHeightInPercentFromParent:(float)heightInPercent toComponent:(UIView*)component {
    if(component) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeHeight multiplier:heightInPercent/100 constant:0];
        [self.referenceView addConstraint:constraint];
    }
}

-(void) setFixedWidthInPercentFromParent:(float)widthInPercent toComponent:(UIView*)component {
    if(component) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:component attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.referenceView attribute:NSLayoutAttributeWidth multiplier:widthInPercent/100 constant:0];
        [self.referenceView addConstraint:constraint];
    }
}

@end

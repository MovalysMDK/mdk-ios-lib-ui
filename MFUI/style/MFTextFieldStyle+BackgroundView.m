//
//  MFTextFieldStyle+BackgroundView.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle+BackgroundView.h"
#import "MFTextField.h"

const NSString * BACKGROUND_VIEW_WIDTH_CONSTRAINT = @"BACKGROUND_VIEW_WIDTH_CONSTRAINT";
const NSString * BACKGROUND_VIEW_HEIGHT_CONSTRAINT = @"BACKGROUND_VIEW_HEIGHT_CONSTRAINT";
const NSString * BACKGROUND_VIEW_CENTER_Y_CONSTRAINT = @"BACKGROUND_VIEW_CENTER_Y_CONSTRAINT";
const NSString * BACKGROUND_VIEW_LEFT_CONSTRAINT = @"BACKGROUND_VIEW_LEFT_CONSTRAINT";

@implementation MFTextFieldStyle (BackgroundView)

-(void)displayBackgroundViewOnComponent:(MFTextField *)component {
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.backgroundView.layer.borderWidth = 1.0f;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.userInteractionEnabled = NO;
    self.backgroundView.layer.cornerRadius = 5.0f;
    
    [component addSubview:self.backgroundView];
    [component sendSubviewToBack:self.backgroundView];
    
    NSDictionary *backgroundViewConstraints = [self defineBackgroundViewConstraintsOnComponent:component];

    backgroundViewConstraints = [self customizeBackgroundViewConstraints:backgroundViewConstraints onComponent:component];
    
    [component addConstraints:backgroundViewConstraints.allValues];
}

-(NSDictionary *)defineBackgroundViewConstraintsOnComponent:(UIView *)component {
    NSDictionary *backgroundViewConstraints = [NSDictionary new];
    
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    
    backgroundViewConstraints = @{
                             BACKGROUND_VIEW_WIDTH_CONSTRAINT:width,
                             BACKGROUND_VIEW_HEIGHT_CONSTRAINT:height,
                             BACKGROUND_VIEW_CENTER_Y_CONSTRAINT:centerY,
                             BACKGROUND_VIEW_LEFT_CONSTRAINT:left
                             };
    
    return backgroundViewConstraints;
    
}

-(void)removeBackgroundViewOnComponent:(MFTextField *)component {
    if(self.backgroundView) {
        component.backgroundColor = self.backgroundView.backgroundColor;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

-(NSDictionary *)customizeBackgroundViewConstraints:(NSDictionary *)backgroundViewConstraints onComponent:(MFTextField *)component {
    return backgroundViewConstraints;
}

@end

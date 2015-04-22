//
//  AdvancedTextFieldStyle+ErrorView.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 16/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle+ErrorView.h"
#import "MFTextField.h"

NSInteger DEFAULT_CLEAR_BUTTON_CONTAINER = 19;
NSInteger DEFAULT_ERROR_VIEW_SQUARE_SIZE = 22;

/**
 * Width constraint : errorView.width = 22;
 */
NSString * ERROR_VIEW_WIDTH_CONSTRAINT = @"ERROR_VIEW_WIDTH_CONSTRAINT";

/**
 * Height constraint : height == 22;
 */
NSString * ERROR_VIEW_HEIGHT_CONSTRAINT = @"ERROR_VIEW_HEIGHT_CONSTRAINT";

/**
 * CenterY constraint : errorView.centerY == component.centerY;
 */
NSString * ERROR_VIEW_CENTER_Y_CONSTRAINT = @"ERROR_VIEW_CENTER_Y_CONSTRAINT";

/**
 * CenterY constraint : errorView.right == component.right - 2;
 */
NSString * ERROR_VIEW_RIGHT_CONSTRAINT = @"ERROR_VIEW_RIGHT_CONSTRAINT";


@implementation MFTextFieldStyle (ErrorView)

-(void) addErrorViewOnComponent:(MFTextField *)component {
    if(!self.errorView) {
        UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [errorButton addTarget:component action:@selector(onErrorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.errorView = errorButton;
        self.errorView.alpha = 0.0;
        [component addSubview:self.errorView];
        
        NSDictionary *errorViewConstraints = [self defineErrorViewConstraintsOnComponent:component];
        errorViewConstraints = [self customizeErrorViewConstraints:errorViewConstraints onComponent:component];
        [component addConstraints:errorViewConstraints.allValues];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.errorView.alpha = 1.0;
                         }];
    }
}

-(void) removeErrorViewOnComponent:(MFTextField *)component {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.errorView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.errorView removeFromSuperview];
                         self.errorView = nil;
                     }];
}


-(NSDictionary *)defineErrorViewConstraintsOnComponent:(UIView *)component {
    NSDictionary *errorViewConstraints = [NSDictionary new];
    
    component.translatesAutoresizingMaskIntoConstraints = NO;
    self.errorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeRight multiplier:1 constant:-DEFAULT_ACCESSORIES_MARGIN];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    
    errorViewConstraints = @{
                             ERROR_VIEW_CENTER_Y_CONSTRAINT:centerY,
                             ERROR_VIEW_HEIGHT_CONSTRAINT:height,
                             ERROR_VIEW_RIGHT_CONSTRAINT:right,
                             ERROR_VIEW_WIDTH_CONSTRAINT:width
                             };
    
    return errorViewConstraints;
    
}


#pragma mark - Public Methods
                                                

-(NSDictionary *) customizeErrorViewConstraints:(NSDictionary *)errorViewConstraints onComponent:(MFTextField *)component{
    return errorViewConstraints;
}




@end

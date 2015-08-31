
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
        UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        errorButton.clipsToBounds = YES;
        [errorButton addTarget:component action:@selector(onErrorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.errorView = errorButton;
        self.errorView.alpha = 0.0;
        self.errorView.tintColor = [UIColor redColor];
        [component addSubview:self.errorView];
        
        NSDictionary *errorViewConstraints = [self defineErrorViewConstraintsOnComponent:component];
        errorViewConstraints = [self customizeErrorViewConstraints:errorViewConstraints onComponent:component];
        [component addConstraints:errorViewConstraints.allValues];
        
    }
    [component layoutIfNeeded];
    
    self.errorView.alpha = 1.0;
    
}

-(void) removeErrorViewOnComponent:(MFTextField *)component {
    [self.errorView removeFromSuperview];
    self.errorView = nil;
}


-(NSDictionary *)defineErrorViewConstraintsOnComponent:(UIView *)component {
    
    component.translatesAutoresizingMaskIntoConstraints = NO;
    self.errorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeRight multiplier:1 constant:-DEFAULT_ACCESSORIES_MARGIN];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.errorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    
    NSDictionary *errorViewConstraints = @{
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

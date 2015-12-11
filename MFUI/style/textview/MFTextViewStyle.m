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

#import "MFTextViewStyle.h"
#import "MFTextView.h"

@implementation MFTextViewStyle
@synthesize messageView;

-(void)applyErrorStyleOnComponent:(MFTextView *)component {
    [super applyErrorStyleOnComponent:component];
    [self performSelector:@selector(addErrorViewOnComponent:) withObject:component];
}

-(void)applyValidStyleOnComponent:(MFTextView *) component {
    [super applyValidStyleOnComponent:component];
    [self performSelector:@selector(removeErrorViewOnComponent:) withObject:component];
}

-(void)applyStandardStyleOnComponent:(MFTextView *)component {
    [super applyStandardStyleOnComponent:component];
    if([component.editable isEqualToNumber:@1]) {
        if(!component.backgroundColor) {
            component.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
    }
}

-(void) addErrorViewOnComponent:(MFTextView *)component {
    if(!self.messageView) {
        UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        errorButton.clipsToBounds = YES;
        [errorButton addTarget:component action:@selector(onMessageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.messageView = errorButton;
        self.messageView.alpha = 0.0;
        self.messageView.tintColor = [UIColor redColor];
        [component addSubview:self.messageView];
        
        NSDictionary *messageViewConstraints = [self defineErrorViewConstraintsOnComponent:component];
        messageViewConstraints = [self customizeErrorViewConstraints:messageViewConstraints onComponent:component];
        [component addConstraints:messageViewConstraints.allValues];
        
    }
    [component layoutIfNeeded];
    
    self.messageView.alpha = 1.0;
    
}

-(void) removeErrorViewOnComponent:(MFTextView *)component {
    if (!self.messageView) {
        return;
    }
    [self.messageView removeFromSuperview];
    self.messageView = nil;
}

-(NSDictionary *)defineErrorViewConstraintsOnComponent:(UIView *)component {
    
    component.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.messageView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual toItem:component
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1 constant:0];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.messageView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual toItem:component
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1 constant:-DEFAULT_ACCESSORIES_MARGIN];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.messageView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.messageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0 constant:DEFAULT_ERROR_VIEW_SQUARE_SIZE];
    NSDictionary *messageViewConstraints = @{
                                           ERROR_VIEW_CENTER_Y_CONSTRAINT:centerY,
                                           ERROR_VIEW_HEIGHT_CONSTRAINT:height,
                                           ERROR_VIEW_RIGHT_CONSTRAINT:right,
                                           ERROR_VIEW_WIDTH_CONSTRAINT:width
                                           };
    
    return messageViewConstraints;
    
}


#pragma mark - Public Methods


-(NSDictionary *) customizeErrorViewConstraints:(NSDictionary *)messageViewConstraints onComponent:(MFTextView *)component{
    return messageViewConstraints;
}


@end

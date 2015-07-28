
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

#import "MFRegexTextFieldStyle+Button.h"
#import "MFRegexTextField.h"


NSInteger REGEX_BUTTON_SQUARE_SIZE = 22;

/**
 * Width constraint : errorView.width = 22;
 */
NSString * REGEX_BUTTON_WIDTH_CONSTRAINT = @"REGEX_BUTTON_WIDTH_CONSTRAINT";

/**
 * Height constraint : height == 22;
 */
NSString * REGEX_BUTTON_HEIGHT_CONSTRAINT = @"REGEX_BUTTON_HEIGHT_CONSTRAINT";

/**
 * CenterY constraint : errorView.centerY == component.centerY;
 */
NSString * REGEX_BUTTON_CENTER_Y_CONSTRAINT = @"REGEX_BUTTON_CENTER_Y_CONSTRAINT";

/**
 * CenterY constraint : errorView.right == component.right - 2;
 */
NSString * REGEX_BUTTON_RIGHT_CONSTRAINT = @"REGEX_BUTTON_RIGHT_CONSTRAINT";



@implementation MFRegexTextFieldStyle (Button)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)addButtonOnTextField:(MFRegexTextField *)component {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"MFUIApplication")];
    NSString *activeImageName = [NSString stringWithFormat:@"ios_ic_%@_active@2x", [self accessoryButtonImageName]];
    NSString *unactiveImageName = [NSString stringWithFormat:@"ios_ic_%@_unactive@2x", [self accessoryButtonImageName]];
    NSString *pressedImageName = [NSString stringWithFormat:@"ios_ic_%@_pressed@2x", [self accessoryButtonImageName]];
    
    NSString *activeImagePath = [bundle pathForResource:activeImageName ofType:@"png"];
    NSString *unactiveImagePath = [bundle pathForResource:unactiveImageName ofType:@"png"];
    NSString *pressedImagePath = [bundle pathForResource:pressedImageName ofType:@"png"];
    self.hasAccessoryButton = NO;
    
    if(activeImagePath) {
        UIButton *button = [[UIButton alloc] init];
        UIImage *btnImageActive = [UIImage imageWithContentsOfFile:activeImagePath];
        UIImage *btnImageUnactive = [UIImage imageWithContentsOfFile:unactiveImagePath];
        UIImage *btnImagePressed = [UIImage imageWithContentsOfFile:pressedImagePath];
        
        [button setImage:btnImageActive forState:UIControlStateNormal];
        [button setImage:btnImageUnactive forState:UIControlStateDisabled];
        [button setImage:btnImagePressed forState:UIControlStateHighlighted];
        
        [component addSubview:button];
        
        [button addTarget:component action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *buttonConstraints = [self defineButton:button constraintsOnComponent:component];
        buttonConstraints = [self customizeButtonConstraints:buttonConstraints onComponent:component];
        [component addConstraints:buttonConstraints.allValues];
        self.hasAccessoryButton = YES;
    }
}
#pragma clang diagnostic pop


-(NSDictionary *)defineButton:(UIButton *)button constraintsOnComponent:(MFRegexTextField *)component {
    
    NSDictionary *buttonConstraints = [NSDictionary new];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    if(button) {
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:component attribute:NSLayoutAttributeRight multiplier:1 constant:-DEFAULT_ACCESSORIES_MARGIN];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:REGEX_BUTTON_SQUARE_SIZE];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:REGEX_BUTTON_SQUARE_SIZE];
        
        buttonConstraints = @{
                              REGEX_BUTTON_CENTER_Y_CONSTRAINT:centerY,
                              REGEX_BUTTON_HEIGHT_CONSTRAINT:height,
                              REGEX_BUTTON_RIGHT_CONSTRAINT:right,
                              REGEX_BUTTON_WIDTH_CONSTRAINT:width
                              };
    }
    return buttonConstraints;
}

#pragma mark - Public methods

-(NSDictionary *)customizeButtonConstraints:(NSDictionary *)buttonConstraints onComponent:(MFRegexTextField *)component {
    return buttonConstraints;
}

-(NSString *) accessoryButtonImageName {
    @throw [[NSException alloc] initWithName:@"Unimplemented" reason:@"You should implement \"accessoryButtonName\"" userInfo:nil];
    return nil;
}
@end

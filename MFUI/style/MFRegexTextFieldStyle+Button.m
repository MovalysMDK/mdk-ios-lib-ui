//
//  MFEmailTextFieldStyle+MailButton.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

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

-(void)addButtonOnTextField:(MFRegexTextField *)component {
    UIButton *button = [[UIButton alloc] init];
    NSBundle
     *bundle = [NSBundle bundleForClass:NSClassFromString(@"MFUIApplication")];
    NSString *imagePath = [bundle pathForResource:[self accessoryButtonImageName] ofType:@"png"];
    UIImage *btnImage = [UIImage imageWithContentsOfFile:imagePath];
    
    [button setImage:btnImage forState:UIControlStateNormal];
    [component addSubview:button];
    
    NSDictionary *buttonConstraints = [self defineButton:button constraintsOnComponent:component];
    buttonConstraints = [self customizeButtonConstraints:buttonConstraints onComponent:component];
    [component addConstraints:buttonConstraints.allValues];

    
}

-(NSDictionary *)defineButton:(UIButton *)button constraintsOnComponent:(MFRegexTextField *)component {
    
    NSDictionary *buttonConstraints = [NSDictionary new];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
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

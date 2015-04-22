//
//  AdvancedTextFieldStyle.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 15/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle+ErrorView.h"
#import "MFTextField.h"

NSInteger DEFAULT_ACCESSORIES_MARGIN = 2;

@implementation MFTextFieldStyle
@synthesize errorView;
@synthesize backgroundView;

-(void)applyErrorStyleOnComponent:(MFTextField *)component {
    [self performSelector:@selector(addErrorViewOnComponent:) withObject:component];
}

-(void)applyStandardStyleOnComponent:(MFTextField *)component {
}

-(void)applyValidStyleOnComponent:(MFTextField *) component {
    [self performSelector:@selector(removeErrorViewOnComponent:) withObject:component];
}

-(NSArray *)defineConstraintsForAccessoryView:(UIView *)accessory withIdentifier:(NSString *)identifier onComponent:(MFTextField *)component {
    return @[];
}
@end

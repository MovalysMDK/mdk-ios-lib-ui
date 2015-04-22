//
//  MFTextFieldStyle+TextLayouting.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextFieldStyle+TextLayouting.h"
#import "MFTextFieldStyle+ErrorView.h"

@implementation MFTextFieldStyle (TextLayouting)


-(CGRect) textRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component{
    NSInteger width = bounds.size.width;
    if(component.clearButtonMode == UITextFieldViewModeUnlessEditing ||
       component.clearButtonMode == UITextFieldViewModeAlways) {
        width -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_CLEAR_BUTTON_CONTAINER);
    }
    if(self.errorView) {
        width -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_ERROR_VIEW_SQUARE_SIZE);
    }
    return CGRectMake(0, 0 , width, bounds.size.height);
}

-(CGRect) editingRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component{
    NSInteger width = bounds.size.width;
    if(component.clearButtonMode == UITextFieldViewModeWhileEditing ||
       component.clearButtonMode == UITextFieldViewModeAlways) {
        width -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_CLEAR_BUTTON_CONTAINER);
    }
    if(self.errorView) {
        width -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_ERROR_VIEW_SQUARE_SIZE);
    }
    return CGRectMake(0, 0 , width, bounds.size.height);
    
}

-(CGRect) clearButtonRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component{
    if(self.errorView) {
        bounds.origin.x -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_ERROR_VIEW_SQUARE_SIZE);
    }
    return bounds;
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component {
    NSInteger width = bounds.size.width;
    if(self.errorView) {
        width -= (2*DEFAULT_ACCESSORIES_MARGIN + DEFAULT_ERROR_VIEW_SQUARE_SIZE);
    }
    return CGRectMake(0, 0 , width, bounds.size.height);
}

-(CGRect)borderRectForBounds:(CGRect)bounds onComponent:(MFTextField *)component {
    return bounds;
}

@end

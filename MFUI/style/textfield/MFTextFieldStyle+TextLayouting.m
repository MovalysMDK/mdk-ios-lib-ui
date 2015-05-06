
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

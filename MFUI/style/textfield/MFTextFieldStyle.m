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

NSInteger DEFAULT_ACCESSORIES_MARGIN = 2;

@implementation MFTextFieldStyle
@synthesize errorView;
@synthesize backgroundView;

#pragma mark - Standard Style
-(void)applyStandardStyleOnComponent:(MFTextField *)component {
    [super applyStandardStyleOnComponent:component];
    if([component.editable isEqualToNumber:@1]) {
        if([component.backgroundColor isEqual:[UIColor clearColor]]) {
            component.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
    }
}

#pragma mark - Error Style

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)applyErrorStyleOnComponent:(MFTextField *)component {
    [super applyErrorStyleOnComponent:component];
    [self performSelector:@selector(addErrorViewOnComponent:) withObject:component];
    
}

-(void)applyValidStyleOnComponent:(MFTextField *) component {
    [super applyValidStyleOnComponent:component];
    [self performSelector:@selector(removeErrorViewOnComponent:) withObject:component];
}
#pragma clang diagnostic pop



-(NSArray *)defineConstraintsForAccessoryView:(UIView *)accessory withIdentifier:(NSString *)identifier onComponent:(MFTextField *)component {
    return @[];
}
@end

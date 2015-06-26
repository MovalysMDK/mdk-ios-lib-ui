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

-(void)applyStandardStyleOnComponent:(MFTextView *)component {
    [super applyStandardStyleOnComponent:component];
    if([component.editable isEqualToNumber:@1]) {
        if(!component.backgroundColor) {
            component.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
    }
}


@end

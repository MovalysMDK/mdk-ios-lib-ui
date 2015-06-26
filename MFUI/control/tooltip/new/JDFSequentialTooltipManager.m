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
//
//  JDFSequentialTooltipManager.m
//  JoeTooltips
//
//  Created by Joe Fryer on 17/11/2014.
//  Copyright (c) 2014 Joe Fryer. All rights reserved.
//

#import "JDFSequentialTooltipManager.h"


@interface JDFSequentialTooltipManager ()

@property (nonatomic, strong) JDFTooltipView *currentlyShowingTooltip;

@end


@implementation JDFSequentialTooltipManager

#pragma mark - Showing Tooltips

- (void)showNextTooltip
{
    if (self.tooltips.count < 1) {
        return;
    }
    
    if (!self.currentlyShowingTooltip) {
        [self showBackdropViewIfEnabled];
        self.currentlyShowingTooltip = [self.tooltips firstObject];
        [self.currentlyShowingTooltip addTapTarget:self action:@selector(handleTooltipTap:)];
        [self showTooltip:self.currentlyShowingTooltip];
    } else {
        [self.currentlyShowingTooltip hideAnimated:YES];
        
        NSUInteger i = [self.tooltips indexOfObject:self.currentlyShowingTooltip] + 1;
        if (i < self.tooltips.count) {
            self.currentlyShowingTooltip = self.tooltips[i];
            [self.currentlyShowingTooltip addTapTarget:self action:@selector(handleTooltipTap:)];
            [self showTooltip:self.currentlyShowingTooltip];
        } else {
            [self hideBackdropView];
        }
    }
}

- (void)showTooltip:(JDFTooltipView *)tooltip
{
    if (self.showsBackdropView) {
        [tooltip showInView:self.backdropView];
    } else {
        [tooltip show];
    }
}

- (void)showAllTooltips
{
    [self showNextTooltip];
}


#pragma mark - Gesture Recognisers

- (void)handleBackdropTap:(UIGestureRecognizer *)gestureRecogniser
{
    if (self.backdropTapActionEnabled) {
        [self showNextTooltip];
    }
}

- (void)handleTooltipTap:(UIGestureRecognizer *)gestureRecogniser
{
    [self showNextTooltip];
}

@end

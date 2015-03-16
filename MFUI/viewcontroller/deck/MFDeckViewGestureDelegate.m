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
//  MFDeckViewGestureDelegate.m
//  MFCore
//
//

#import "MFDeckViewGestureDelegate.h"
#import <ViewDeck/IIViewDeckController.h>

@implementation MFDeckViewGestureDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    float originX = [touch locationInView:self.slidingControllerView].x;
    if ([((IIViewDeckController*) self.deckViewController) isSideOpen:IIViewDeckLeftSide]) {
        return YES;
    } else {
        return (originX <= 20);
    }
   
}

- (id) init {
    if (self = [super init]) {
    }
    return self;
}


- (id) initWithViewController:(MFDeckViewController *)viewController {
    if (self = [super init]) {
        self.deckViewController = viewController;
    }
    return self;
}
@end

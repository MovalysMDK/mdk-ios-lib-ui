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
//  MFDeckViewController.m
//  MFUI
//
//

#import "MFDeckViewController.h"
#import "MFDeckViewGestureDelegate.h"


@implementation MFDeckViewController {
    MFDeckViewGestureDelegate *viewDeckGestureDelegate;
}


/*
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    float originX = [touch locationInView:self.centerController.view].x;
    if (originX <= 16) {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return NO;
}*/

- (void) commonInitGestureDelegate {
    viewDeckGestureDelegate = [[MFDeckViewGestureDelegate alloc] initWithViewController:self];
    viewDeckGestureDelegate.slidingControllerView = self.centerController.view;
    self.panningGestureDelegate = viewDeckGestureDelegate;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self commonInitGestureDelegate];
    //self.panningGestureDelegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait ||
        fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.leftSize = screenRect.size.height - 200;
    } else {
        self.leftSize = screenRect.size.width - 200;
    }
}
@end

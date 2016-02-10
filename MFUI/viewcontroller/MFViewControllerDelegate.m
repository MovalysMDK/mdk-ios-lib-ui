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
//  MFViewControllerDelegate.m
//  MFCore
//
//

#import "MFViewControllerDelegate.h"

@implementation MFViewControllerDelegate

-(id) initWithViewController:(UIViewController*) viewController {
    self = [super init];
    if (self) {
        // Custom implementation
        self.viewController = viewController ;
    }
    return self;
}

-(IBAction)genericButtonPressed:(id)sender {
    // Implementation is in the category MFViewControllerDelegate+MFUIViewControllerDelegate
}

-(void) showWaitingView{
    // Implementation is in the category MFViewControllerDelegate+MFUIViewControllerDelegate
}

-(void) showWaitingViewWithMessageKey:(NSString *) key{
    // Implementation is in the category MFViewControllerDelegate+MFUIViewControllerDelegate
}

-(void) dismissWaitingView{
    // Implementation is in the category MFViewControllerDelegate+MFUIViewControllerDelegate  
}

-(void) showWaitingViewDuring:(int)seconds {
    // Implementation is in the category MFViewControllerDelegate+MFUIViewControllerDelegate
}

@end

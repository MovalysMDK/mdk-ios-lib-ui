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


//Main interface
#import "MFOrientationChangedDelegate.h"

//Log
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"



#pragma mark MFOrientationChangedDelegate: Implementation

@implementation MFOrientationChangedDelegate



#pragma mark Life cycle

- (id)initWithListener:(id<MFOrientationChangedProtocol>) listener {
    self = [super init];
    if(self) {
        self.listener = listener;
    }
    return self;
}



#pragma mark Public API

- (void)registerOrientationChanges {
    if([self.listener respondsToSelector:@selector(orientationDidChanged:)]) {
        self.listener.currentOrientation = [[UIDevice currentDevice] orientation];
        [[NSNotificationCenter defaultCenter] addObserver:self.listener selector: @selector(orientationDidChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    else {
        MFUILogError(@"The delegate \"%@\" indicates that its listener \"%@\" should implement the method named \"orientationDidChanged:\"", self, self.listener);
    }
}

- (BOOL)checkIfOrientationChangeIsAScreenNormalRotation {
    UIDeviceOrientation newOrientation  = [[UIDevice currentDevice] orientation];
    UIDeviceOrientation lastOrientation = self.listener.currentOrientation;
    return ( newOrientation != lastOrientation );
}

- (void) unregisterOrientationChanges {
    [[NSNotificationCenter defaultCenter] removeObserver:self.listener name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.listener];
}

@end

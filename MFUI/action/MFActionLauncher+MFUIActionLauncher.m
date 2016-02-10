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
//  MFActionLauncher.m
//  MFCore
//
//

#import "MFActionLauncher.h"
#import "MFUIApplication.h"
#import "MFViewController.h"
#import "MFChildViewControllerProtocol.h"

@implementation MFActionLauncher (MFUIActionLauncher)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void) showWaitingView {
    UIViewController *controller = [[MFUIApplication getInstance] lastAppearViewController];
    while ([controller conformsToProtocol:@protocol(MFChildViewControllerProtocol)]) {
        controller = [(id<MFChildViewControllerProtocol>) controller containerViewController];
    }
    if ([controller isKindOfClass:[MFViewController class]]) {
        [(MFViewController *) controller showWaitingView];
    }
}

- (void) dismissWaitingView {
    UIViewController *controller = [[MFUIApplication getInstance] lastAppearViewController];
    while ([controller conformsToProtocol:@protocol(MFChildViewControllerProtocol)]) {
        controller = [(id<MFChildViewControllerProtocol>) controller containerViewController];
    }
    if ([controller isKindOfClass:[MFViewController class]]) {
        [(MFViewController *) controller dismissWaitingView];
    }
}
#pragma clang diagnostic pop

@end

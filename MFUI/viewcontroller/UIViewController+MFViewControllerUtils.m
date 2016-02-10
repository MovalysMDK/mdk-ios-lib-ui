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
//  UIViewController+MFViewControllerUtils.m
//  MFCore
//
//

#import "UIViewController+MFViewControllerUtils.h"
#import "MFUIApplication.h"
#import <objc/runtime.h>
#import "MFMenuViewController.h"
#import "MFChildViewControllerProtocol.h"

const void *extMFViewControllerKey = &extMFViewControllerKey;


@implementation MFViewControllerUtils_Private

-(id) initWithViewController:(UIViewController *) viewController {
    if (self = [super init]) {
        self.viewControllerDelegate = [[MFViewControllerDelegate alloc] initWithViewController:viewController];
    }
    return self;
}
@end




@implementation UIViewController (MFViewControllerUtils)

-(MFViewControllerUtils_Private *) extendsMFViewController {
    MFViewControllerUtils_Private *ext = objc_getAssociatedObject(self, &extMFViewControllerKey);
    if (ext==nil) {
        ext = [[MFViewControllerUtils_Private alloc] initWithViewController:self];
        [self setExtendsMFViewController:ext];
    }
    return ext;
}

-(void) setExtendsMFViewController:(MFViewControllerUtils_Private *) newMFViewControllerUtils {
    objc_setAssociatedObject(self, &extMFViewControllerKey, newMFViewControllerUtils ,  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma  mark - Override of UIViewController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

-(void)viewDidAppear:(BOOL)animated {
    if([self conformsToProtocol:@protocol(MFViewControllerProtocol)]  &&
       ![self conformsToProtocol:@protocol(MFChildViewControllerProtocol)]) {
        [MFUIApplication getInstance].lastAppearViewController = self;
    }}

#pragma clang diagnostic pop

@end

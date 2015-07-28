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
//  TransitionController.m
//  MMCore
//
//

#import <objc/runtime.h>

#import "MFTransitionController.h"
#import "MFAppDelegate.h"

const void *transitionKey = &transitionKey;

@interface UIViewController (MFTransitionController_Private)

@property(nonatomic, strong) MFTransitionController *transitionController;

@end

@implementation MFTransitionController

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        
        self.viewController = viewController;
        self.viewController.transitionController = self;
    }
    return self;
}


- (void)loadView
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    _containerView = [[UIView alloc] initWithFrame:view.frame];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_containerView];
    [self.view setHidden:YES];
    
    [self addChildViewController:self.viewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewController.view.frame = self.view.frame;
        [self.view setHidden:NO];
    });
    [_containerView addSubview:self.viewController.view];
    
    
}


-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view setTag:NSIntegerMax];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewController.view.frame = self.view.frame;
    });
    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    
}

- (void)transitionToViewController:(UIViewController *)newViewController
                       withOptions:(UIViewAnimationOptions)options
{
    newViewController.view.frame = self.containerView.bounds;
    
    [self addChildViewController:newViewController];
    
    [self.viewController willMoveToParentViewController:nil];
    
    [UIView transitionWithView:self.containerView
                      duration:0.65f
                       options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:newViewController.view];
                    }
                    completion:^(BOOL finished){
                        
                        self.viewController.transitionController = nil;
                        [self.viewController didMoveToParentViewController:nil];
                        [self.viewController removeFromParentViewController];
                        
                        self.viewController = newViewController;
                        self.viewController.transitionController = self;
                        [self.viewController didMoveToParentViewController:self];
                    }];
}

@end

@implementation UIViewController (MFTransitionController)

-(MFTransitionController*)transitionController {
    
    UIViewController *currentVC = self;
    
    MFTransitionController *transitionController = nil;
    
    while (!transitionController && currentVC) {
        transitionController = objc_getAssociatedObject(currentVC, &transitionKey);
        
        currentVC = currentVC.parentViewController;
    }
    
    return transitionController;
}

-(void)setTransitionController:(MFTransitionController *)transitionController {
    MFTransitionController *currentTransitionController = objc_getAssociatedObject(self, &transitionKey);
    
    if (!currentTransitionController) {
        objc_setAssociatedObject(self, &transitionKey, transitionController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(void) pushCenterViewController:(UIViewController *)viewController animated:(BOOL)animated {
    MFTransitionController *currentTransitionController = ((MFAppDelegate *)[[UIApplication sharedApplication] delegate]).transitionController;
    UINavigationController *navigationController = (UINavigationController *) currentTransitionController.viewController;
    if([navigationController isKindOfClass:[UINavigationController class]]) {
        [navigationController pushViewController:viewController animated:animated];
    }
}
@end

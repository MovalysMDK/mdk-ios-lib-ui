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
//  MFViewController.m
//  MMControls
//
//

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreError.h>

#import "MFViewController.h"
#import "MFViewControllerDelegate.h"
#import "MFButton.h"
#import "MFUILogging.h"
#import <MFCore/MFCoreApplication.h>
#import "UIViewController+MFViewControllerUtils.h"
#import "MFMenuViewController.h"
#import "MFWorkspaceViewController.h"
#import "MFFormDetailViewController.h"
#import  <MFCore/MFCoreError.h>


@interface MFViewController()
@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation MFViewController

@synthesize mf = _mf;
@synthesize defaultConstraints = _defaultConstraints;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        _mf = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_FORM_EXTEND];
    }
    return self;
}

#pragma mark - button methods

- (IBAction)genericButtonPressed:(id)sender {
    [[self extendsMFViewController].viewControllerDelegate genericButtonPressed:sender];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Si le contrôleur n'est pas surchargé par défaut, on met le nom du storyboard qui le contient.
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![self isKindOfClass:[MFWorkspaceViewController class]] &&
           ![self isKindOfClass:[MFFormDetailViewController class]] &&
           ![self.parentViewController isKindOfClass:[UITabBarController class]]) {
            [self computeScreenTitle];
        }
    });
    
    self.view.autoresizesSubviews = YES;
    
    [self performSelector:@selector(checkIfComment) withObject:nil afterDelay:0.5];
    
}




- (void)applyDefaultConstraints {
    // does nothing
}

- (void) mFViewControllerViewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    MFMenuViewController *mfViewController = [MFMenuViewController getInstance];
    NSArray* menuActions = [self getOptionMenuIds];
    [mfViewController setMenuWithActions:menuActions];
    
    [self setButtonsActions];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self viewDidAppear:animated withOberversParameters:nil];
}

-(void)viewDidAppear:(BOOL)animated withOberversParameters: (NSDictionary *) parameters {
    //[super viewDidAppear:animated];
    [self mFViewControllerViewDidAppear: animated];
    if (self.observers) {
        for (id<MFViewControllerObserverProtocol> observer in self.observers) {
            [observer onObservedViewController: self didAppear:parameters];
        }
    }
}


- (NSArray *) getOptionMenuIds {
    MFUILogVerbose(@"getOptionMenuIds: %@", [self.storyboard valueForKey:@"name"]);
    
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    NSArray *commonMenuActions = [registry getArrayProperty:@"Menu_common"];
    NSString *screenMenuActionsTitle = [NSString stringWithFormat:@"%@%@", @"Menu_", [self.storyboard valueForKey:@"name"]];
    NSArray *screenMenuActions = [registry getArrayProperty:screenMenuActionsTitle];
    
    NSArray *menuActions = [commonMenuActions arrayByAddingObjectsFromArray:screenMenuActions];
    return menuActions;
}

-(void) setButtonsActions {
    //Sorting the buttons (Because IBoutletCollection produces a random order).
    NSArray *sortedButtons;
    sortedButtons = [self.buttons sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithInteger:[(MFButton*)a tag]];
        NSNumber *second = [NSNumber numberWithInteger:[(MFButton*)b tag]];
        return [first compare:second];
    }];
    for(MFButton *mfbutton in sortedButtons) {
        [mfbutton addTarget:self action:@selector(genericButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}



#pragma mark - Waiting Dialog methods

-(void)viewWillDisappear:(BOOL)animated {
    [self viewWillDisappear:animated withOberversParameters:nil];
}

-(void)viewWillDisappear:(BOOL)animated withOberversParameters:(NSDictionary *) parameters {
    [super viewDidDisappear:animated];
    if (self.observers) {
        for (id<MFViewControllerObserverProtocol> observer in self.observers) {
            [observer onObservedViewController: self willDisappear:parameters];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self extendsMFViewController].viewControllerDelegate setFullFrame:self.view.bounds];
}


-(void) showWaitingView {
    /*
     MFWaitingView * waitingView = [[MFWaitingView alloc] initWithFrame:_fullFrame];
     [waitingView setAlpha:0.0];
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:0.5];
     [waitingView setAlpha:1.0];
     [UIView commitAnimations];
     
     [self.view addSubview:waitingView];
     self.isWaitingViewShown = YES;
     */
    [[self extendsMFViewController ].viewControllerDelegate showWaitingView];
}

-(void) showWaitingViewWithMessageKey:(NSString *) key {
    /*
     MFWaitingView * waitingView = [[MFWaitingView alloc] initWithFrame:_fullFrame];
     [waitingView setAlpha:0.0];
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDuration:0.5];
     [waitingView setAlpha:1.0];
     [UIView commitAnimations];
     
     [self.view addSubview:waitingView];
     self.isWaitingViewShown = YES;
     */
    [[self extendsMFViewController ].viewControllerDelegate showWaitingViewWithMessageKey:key];
}


-(void) dismissWaitingView {
    
    [[self extendsMFViewController].viewControllerDelegate dismissWaitingView];
    /*
     if(!self.isWaitingViewShown)
     return;
     
     for(UIView * candidateView in self.view.subviews)
     {
     if([[candidateView class] isSubclassOfClass:[MFWaitingView  class ]])
     {
     [UIView beginAnimations:nil context:NULL];
     [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
     animations:^{
     [candidateView setAlpha:0.0];
     }
     completion:^(BOOL finished){
     if (finished) {
     [candidateView removeFromSuperview];
     self.isWaitingViewShown = NO;
     }
     }];
     [UIView commitAnimations];
     break;
     
     
     }
     }*/
}

-(void) showWaitingViewDuring:(int)seconds {
    [[self extendsMFViewController].viewControllerDelegate showWaitingViewDuring:seconds];
    /*
     [self showWaitingView];
     [self performSelector:@selector(dismissWaitingView) withObject:nil afterDelay:seconds];*/
}

- (void) registerObserver:(id<MFViewControllerObserverProtocol>) observer {
    if (!self.observers) {
        self.observers = [[NSMutableArray alloc] init];
    }
    if ([self.observers indexOfObject:observer] == NSNotFound) {
        [self.observers addObject:observer];
    }
}

- (void) unregisterObserver:(id<MFViewControllerObserverProtocol>) observer {
    if ([self.observers indexOfObject:observer] != NSNotFound) {
        [self.observers removeObject:observer];
    }
}

-(void) computeScreenTitle {
    if(!self.title) {
        if([self customTitle]) {
            self.title = [self customTitle];
        }
        else {
            NSString *screenTitleLocalized = [NSString stringWithFormat:@"screen_title_M%@%@", [self.storyboard valueForKey:@"name"], @"Controller"] ;
            self.title = MFLocalizedStringFromKey( screenTitleLocalized );
        }
    }

}

-(NSString *) customTitle {
    return nil;
}


- (void) seeScreenInfo
{
    UIViewController *screenInfoController = [[UIViewController alloc] init];
    screenInfoController.title = @"Info";
    [screenInfoController setEdgesForExtendedLayout:UIRectEdgeNone];
    [self.navigationController pushViewController:screenInfoController animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:screenInfoController.view.frame];
        [screenInfoController.view addSubview:webView];
        NSString *htmlString =
        [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.mf.commentHTMLFileName ofType:@"html"] encoding:
         NSUTF8StringEncoding            error:nil];
        [webView loadHTMLString:htmlString baseURL:nil];
    });
    
}

-(void) checkIfComment {
    BOOL fileExists = self.mf.commentHTMLFileName && [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:self.mf.commentHTMLFileName  ofType:@"html"] ];
    if(fileExists) {
        UIBarButtonItem *infoItem =
        [[UIBarButtonItem alloc] initWithTitle:@"   ?   " style:UIBarButtonItemStyleBordered target:self action:@selector(seeScreenInfo)];
        infoItem.tintColor = [UIColor redColor];
        NSMutableArray *rbbi = [self.navigationItem.rightBarButtonItems mutableCopy];
        if(!rbbi) {
            rbbi = [NSMutableArray array];
        }
        [rbbi addObject:infoItem];
        self.navigationItem.rightBarButtonItems = rbbi;
    }
}



@end

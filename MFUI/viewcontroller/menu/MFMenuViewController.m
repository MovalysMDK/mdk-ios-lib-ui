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
//  MFMenuViewController.m
//  MFCore
//
//
//


#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreLogging.h>
#import "UIViewController+MFViewControllerUtils.h"
#import "MFViewController.h"
#import "MFTransitionController.h"
#import "MFMenuViewController.h"
@import MDKControl.MDKTheme;

const int MARGIN = 10 ;
const int BUTTON_WIDTH = 160 ;
const int BUTTON_HEIGHT = 33 ;

static MFMenuViewController * getMenuViewController() {
    static MFMenuViewController *menuViewController = NULL;
    
    if (!menuViewController) {
        menuViewController = [[MFMenuViewController alloc] init];
    }
    return menuViewController;
}

@interface MFMenuViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation MFMenuViewController

+ (id) getInstance {
    return getMenuViewController();
}

-(id) init {
    self = [super init];
    if (self) {
        // Custom initialization
        self.menuButtons = [NSMutableArray array] ;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.menuButtons = [NSMutableArray array] ;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    self.firstLaunching = YES ;
}
/**
 * Listener of click on a button of the menu
 */


-(void) clickOnButton:(id)sender {
    MFCoreLogVerbose(@"click on %@ " ,[sender description] );
    if ( [sender isKindOfClass:[UIButton class]] ){
        UIButton *clickedButton =(UIButton *) sender ;
        NSString *actionName = [self.menuButtons objectAtIndex:[clickedButton tag]];
       
        if ([actionName hasPrefix: @"action_"]) {
            NSString *action = [actionName substringFromIndex:7];
            Class actionClass = NSClassFromString(action);
            if ( actionClass == nil) {
                MFCoreLogInfo(@" actionName '%@' doesn't exist as a class ", actionName);
            } else {
                MFCoreLogVerbose(@" Let's go : actionName '%@' will be launched ", actionName);
                [[MFApplication getInstance] launchAction:action withCaller:self withInParameter:nil];
            }
        } else if ([actionName hasPrefix: @"nav_"]) {
            NSString *storyboardName = [actionName substringFromIndex:4];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            MFViewController *vc = [storyboard instantiateInitialViewController];
            UINavigationController *navigationController = (UINavigationController *) self.navigationController;
            
            if ([vc isKindOfClass:[UINavigationController class]]) {
                [navigationController popToRootViewControllerAnimated:YES];
            } else {
                [navigationController popToRootViewControllerAnimated:NO];
                [navigationController pushViewController:vc animated:YES];
            }
            
        } else if ([actionName hasPrefix: @"method_"]) {
            //TODO NSString *method = [actionName substringFromIndex:7];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = true ;
    [[MDKTheme sharedTheme] applyThemeOnNavigationBar:self];

    //self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}


- (void) setMenuWithActions:(NSArray *) menuActions {
    menuActions = [self sortActions:menuActions];
    
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollview.showsVerticalScrollIndicator = YES;
    scrollview.scrollEnabled = YES;
    scrollview.userInteractionEnabled = YES;
    scrollview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    NSUInteger index = 0;
    UIView *formerElement = NULL;
    for (NSString *actionName in menuActions) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self initButton:button withActionName:actionName];
        [scrollview addSubview:button];
        button.tag = index;
        button.frame = (formerElement) ?
            CGRectMake(MARGIN, formerElement.frame.origin.y + formerElement.frame.size.height + MARGIN, button.frame.size.width, button.frame.size.height)
        :
            CGRectMake(MARGIN, 6*MARGIN, button.frame.size.width, button.frame.size.height);
        
        [self.menuButtons insertObject:actionName atIndex:index];
        formerElement = button;
        index++; // definit le tag de l'objet bouton
    }
    scrollview.contentSize = CGSizeMake(self.view.frame.size.width, formerElement.frame.origin.y + formerElement.frame.size.height + MARGIN);
    self.scrollView = scrollview;
    [self.view addSubview:self.scrollView];
}

- (NSArray *) sortActions:(NSArray *) menuActions {
    NSMutableArray *sortedMenuActions = [[NSMutableArray alloc] init];
    for (NSString *actionName in menuActions) {
        if ([actionName hasPrefix: @"nav_"]) {
            [sortedMenuActions insertObject:actionName atIndex:0];
        } else {
            [sortedMenuActions addObject:actionName];
        }
    }
    return [sortedMenuActions copy];
}

- (void) initButton:(UIButton *) button withActionName:(NSString *) actionName  {
    NSString *actionButtonImage = [[NSString alloc] initWithFormat:@"menu__%@__image", actionName];
    NSString *actionpath = [[NSBundle mainBundle] pathForResource:actionButtonImage ofType:@"png"];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:actionpath] ) {
        UIImageView *defaultButtonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:actionButtonImage]];
        defaultButtonImage.frame = CGRectMake( MARGIN/2, MARGIN , BUTTON_HEIGHT - MARGIN , BUTTON_HEIGHT - MARGIN );
        [button addSubview:defaultButtonImage];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, MARGIN/2 + BUTTON_HEIGHT - MARGIN ,0.0, 0.0)];
    }
 
    NSString *actionButtonLabel = [[NSString alloc] initWithFormat:@"menu__%@__label", actionName];
    NSString *buttonLabel = MFLocalizedStringFromKey(actionButtonLabel);
    
    if ([buttonLabel isEqualToString:actionButtonLabel]) {
        if ([actionName hasPrefix: @"action_"]) {
            buttonLabel = actionName;
        } else if ([actionName hasPrefix: @"nav_"]) {
            buttonLabel = [actionName substringFromIndex:4];
        } else if ([actionName hasPrefix: @"method_"]) {
            buttonLabel = actionName;
        }
    }
    
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button setAccessibilityLabel:buttonLabel];
    
    button.enabled = true ;
    button.userInteractionEnabled = true ;
    
    [button addTarget:self action:@selector(clickOnButton:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, BUTTON_WIDTH, BUTTON_HEIGHT + MARGIN);
}

-(void) showWaitingView {
    [[self extendsMFViewController].viewControllerDelegate showWaitingView];
}

-(void) showWaitingViewWithMessageKey:(NSString *)key {
    [[self extendsMFViewController].viewControllerDelegate showWaitingViewWithMessageKey:key];
}

-(void) dismissWaitingView {
    [[self extendsMFViewController].viewControllerDelegate dismissWaitingView];
}

-(void) showWaitingViewDuring:(int)seconds {
    [[self extendsMFViewController].viewControllerDelegate showWaitingViewDuring:seconds];
}

-(IBAction)genericButtonPressed:(id)sender
{
    [[self extendsMFViewController].viewControllerDelegate genericButtonPressed:sender];
}

@end

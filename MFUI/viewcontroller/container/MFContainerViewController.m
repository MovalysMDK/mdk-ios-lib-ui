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

//MFCore imports
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreConfig.h>


//ViewModel
#import "MFUIBaseViewModel.h"

//View
#import "MFWorkspaceView.h"

//Protocol
#import "MFChildSaveProtocol.h"

//Action
#import "MFChainSaveDetailAction.h"
#import "MFChainSaveActionDetailParameter.h"

//ViewControllers
#import "MFFormViewController.h"

@import MDKControl.AlertView;


@interface MFContainerViewController ()

/**
 * @brief Indicated if the controller should be popped after a specific treatment
 */
@property (nonatomic) BOOL hasRequestPopViewController;

@end

@implementation MFContainerViewController

#pragma mark - Initialization

-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    self.hasRequestPopViewController = NO;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBarItems];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MFActionLauncher getInstance] MF_register:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[MFActionLauncher getInstance] MF_unregister:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[MFActionLauncher getInstance] MF_unregister:self];
}

-(void) setupBarItems {
    self.navigationItem.hidesBackButton = YES;
    UIViewController *topController  = self;
    if(self.navigationController.viewControllers.count > 0 ) {
        topController = [self.navigationController.viewControllers objectAtIndex:0];
    }
    
    //Si le contrôleur courant est au sommet de la pile de navigation, on masque le bouton de retour car il n'y aucune
    //vue sur laquelle retourner.
    if (![self isEqual:topController] || [self isKindOfClass:[MFWorkspaceViewController class]]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self backButtonTitle] style:UIBarButtonItemStylePlain target:self action:@selector(onBackPressed:)];
        self.navigationItem.leftBarButtonItem.tag = BACK_BUTTON_TAG;
        
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self saveButtonTitle] style:UIBarButtonItemStylePlain target:self action:@selector(onSavePressed:)];
    self.navigationItem.rightBarButtonItem.tag = SAVE_BUTTON_TAG;
    
    [self updateController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Resgister Actions

/**
 * @brief Register success and fail action events
 */
-(void) registerChildrenActions {
    //    [[MFActionLauncher getInstance] MF_register:self];
}


/**
 * @brief Event called when one of the launched actions succeeded
 * @param context The current context
 * @param caller The caller of the action
 * @param result The result of the action
 */
MFRegister_ActionListenerOnSuccess(MFAction_MFChainSaveDetailAction, succeedSaveAction)
- (void) succeedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result {
    
    BOOL isExiting = NO;
    if(self.hasRequestPopViewController &&
       [self isKindOfClass:[MFWorkspaceViewController class]] &&
       [[((MFWorkspaceViewController*)self) getWorkspaceView] isMasterColumnVisible]) {
        [((MFWorkspaceViewController*)self) releaseRetainedObjects];
        [self popViewControllerAndReleaseObjects];
        isExiting = YES;
    }
    
    if(!isExiting && [self isKindOfClass:[MFWorkspaceViewController class]]) {
        for(MFFormBaseViewController *baseViewController in self.childViewControllers) {
            [baseViewController.formValidation resetValidation];
            //refresh content
            if([baseViewController conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)] &&
               [baseViewController respondsToSelector:@selector(doFillAction)]) {
                [baseViewController performSelector:@selector(doFillAction)];
            }
            [baseViewController.viewModel resetChanged];
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


/**
 * @brief Event called when one of the launched actions failed
 * @param context The current context
 * @param caller The caller of the action
 * @param result The result of the action
 */
MFRegister_ActionListenerOnFailed(MFAction_MFChainSaveDetailAction, failedSaveAction)
- (void) failedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result {
    
    if(context && context.errors && context.errors.count >0) {
        NSError *error = [context.errors objectAtIndex:0];
        
        MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:[error.userInfo objectForKey:NSLocalizedDescriptionKey] message:[error.userInfo objectForKey:NSLocalizedDescriptionKey] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL];
        [alertController addAction:alertAction];
        [self.parentViewController presentViewController:alertController animated:true completion:NULL];
        
        self.hasRequestPopViewController = NO;
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}


- (void) refreshSubViews {
    // to override
}

#pragma mark - ViewModel Management
/**
 * @brief Check if a detail has changed
 * @return YES if one of the details view controller has changed, NO otherwhise.
 */
-(BOOL) checkHasChangedOrAsInvalidValues {
    BOOL hasChanged = NO;
    BOOL hasInvalidValues = NO;
    for(UIViewController *subViewController in self.childViewControllers) {
        if([subViewController conformsToProtocol:@protocol(MFChildSaveProtocol) ]) {
            MFFormViewController *childViewController = (MFFormViewController *)subViewController;
            if([childViewController usePartialViewModel]) {
                for(NSString *viewModelKey in [childViewController partialViewModelKeys]) {
                    MFUIBaseViewModel *viewModel = [(MFUIBaseViewModel *)[childViewController getViewModel] valueForKey:viewModelKey];
                    hasChanged = hasChanged || [viewModel hasChanged];
                    if(hasChanged) {
                        break;
                    }
                }
            }
            if([[childViewController getViewModel] hasChanged]) {
                hasChanged = YES;
                break;
            }
            if([childViewController conformsToProtocol:@protocol(MFCommonFormProtocol)]) {
                id<MFCommonFormProtocol> chilFormBindingDelegate = (id<MFCommonFormProtocol>)childViewController;
                if(chilFormBindingDelegate.formValidation && [chilFormBindingDelegate.formValidation hasInvalidValues]) {
                    hasInvalidValues = YES;
                }
            }
        }
    }
    return hasChanged || hasInvalidValues;
}



#pragma mark - Customization

-(NSString *) backButtonTitle {
    return MFLocalizedStringFromKey(@"form_back");
}

-(NSString *) saveButtonTitle {
    return MFLocalizedStringFromKey(@"form_save");
}

#pragma mark - UI management

/**
 * @brief Some custom treatments could be done here to refresh the workspace view controller
 */
-(void) updateController {
    self.navigationItem.leftBarButtonItem.title = [self backButtonTitle];
}

-(void)onBackPressed:(id)sender {
    
    if([sender isEqual:self.navigationItem.leftBarButtonItem]){
        self.hasRequestPopViewController = YES;;
    }
    
    MFConfigurationHandler *registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    NSString *actionType = [registry getStringProperty:MFPROP_FORM_ONUNSAVEDCHANGES];
    bool doShowAlert = NO;
    bool doSave = NO;
    if (actionType && [actionType isEqualToString:@"DiscardChangesAlert"]) {
        doShowAlert = YES;
    }
    if (actionType && [actionType isEqualToString:@"SaveChangesAlert"]) {
        doShowAlert = YES;
        doSave = YES ;
    }
    if (actionType && [actionType isEqualToString:@"AutomaticSave"]) {
        doSave = YES ;
    }
    
    if([self checkHasChangedOrAsInvalidValues]) {
        if ( doShowAlert ) {
            if ( !doSave) {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"alert_discardchanges_title") message:MFLocalizedStringFromKey(@"alert_discardchanges_message") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertNoAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"alert_discardchanges_no") style:UIAlertActionStyleCancel handler:NULL];
                UIAlertAction *alertYesAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"alert_discardchanges_yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self popViewControllerAndReleaseObjects];
                }];
                [alertController addAction:alertNoAction];
                [alertController addAction:alertYesAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
            else {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"alert_savechanges_title") message:MFLocalizedStringFromKey(@"alert_savechanges_message") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertNoAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"alert_savechanges_no") style:UIAlertActionStyleCancel handler:NULL];
                UIAlertAction *alertYesAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"alert_savechanges_yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self onSavePressed:self.navigationItem.leftBarButtonItem];
                    self.hasRequestPopViewController = YES;
                }];
                [alertController addAction:alertNoAction];
                [alertController addAction:alertYesAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
        } else if ( doSave ) {
            [self onSavePressed:self.navigationItem.rightBarButtonItem];
        }
    }
    else {
        [self popViewControllerAndReleaseObjects];
    }
    
}

/**
 * @brief Action called when the save button is pressed
 * @param sender The sender of the action
 */
-(void)onSavePressed:(id)sender {
    NSMutableArray *namesOfSaveActions = [NSMutableArray array];
    for(UIViewController *subViewController in self.childViewControllers) {
        if([subViewController conformsToProtocol:@protocol(MFChildSaveProtocol) ]) {
            id<MFChildSaveProtocol> childViewController = (id<MFChildSaveProtocol>)subViewController;
            if([childViewController respondsToSelector:@selector(saveActionsNames)]) {
                for (NSString *actionName in [childViewController saveActionsNames]) {
                    [namesOfSaveActions addObject:actionName];
                }
            }
        }
    }
    
    if(namesOfSaveActions.count > 0  ) {
        if(self.navigationItem.rightBarButtonItem.tag == SAVE_BUTTON_TAG) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        MFChainSaveActionDetailParameter *parameters = [[MFChainSaveActionDetailParameter alloc] init];
        parameters.actions = namesOfSaveActions;
        
        [[MFActionLauncher getInstance] launchAction:@"MFChainSaveDetailAction" withCaller:sender withInParameter:parameters];
    }
    
}

-(void) popViewControllerAndReleaseObjects {
    [self releaseRetainedObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) releaseRetainedObjects {
    //Should be implemented in child classes if needed.
}


@end

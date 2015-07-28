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
//  MFWorkspaceViewController.m
//  MFUI
//
//

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreApplication.h>

#import "MFUILog.h"

#import "MFWorkspaceViewController.h"
#import "MFWorkspaceView.h"
#import "MFUIBaseViewModel.h"
#import "MFChildSaveProtocol.h"
#import "MFFormViewController.h"
#import "MFViewController.h"

#define POR_IDAP_COLUMN_NUMBER 2
#define PAY_IDAP_COLUMN_NUMBER 4
#define PAY_COLUMN_NUMBER 2
#define POR_COLUMN_NUMBER 1


const int kMasterSelectSaveChangesAlert = 12 ;

@interface MFWorkspaceViewController ()

@property(nonatomic, strong) MFUIBaseViewModel *currentMasterViewModel;

@property BOOL isChangingMasterIndex;

@property (nonatomic, strong) MFWorkspaceViewControllerState *workspaceState;

@end



@implementation MFWorkspaceViewController
@synthesize mf = _mf;

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
    [super initialize];
    self.isChangingMasterIndex = NO;
    self.workspaceState = [MFWorkspaceViewControllerState new];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateController) name:WORKSPACE_VIEW_DID_SCROLL_NOTIFICATION_KEY object:nil];
    self.mf = [MFViewControllerAttributes_Workspace new];
}

-(void)updateController {
    [super updateController];
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isTopController = NO;
        
        UIViewController *topController  = self;
        if(self.navigationController.viewControllers.count > 0 ) {
            topController = [self.navigationController.viewControllers objectAtIndex:0];
        }
        isTopController = [self isEqual:topController];
        BOOL isMasterVisibile = [[self getWorkspaceView] isMasterColumnVisible];
        
        [self.navigationItem.leftBarButtonItem setEnabled:!(isMasterVisibile && isTopController)];
    });
    
}


#pragma mark - UIViewController methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    if (self.workspaceAttributes.formDescriptorName) {
        
        NSString *localizedControllerKey = [NSString stringWithFormat:@"workspace_title_%@", [self.storyboard valueForKey:@"name"]];
        self.title = MFLocalizedStringFromKey(localizedControllerKey);
        MFUILogInfo(@"formDescName : %@", self.workspaceAttributes.formDescriptorName.description);
        
        NSString *plistFileName = [@"work-" stringByAppendingString:self.workspaceAttributes.formDescriptorName];
        NSDictionary *workspaceDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"]];
        
        
        MFUILogInfo(@"formDesc : %@", workspaceDictionary[@"description"]);
        
        for (NSDictionary *columnDictionary in workspaceDictionary[@"columns"]) {
            
            [self performSegueWithIdentifier:columnDictionary[@"segueIdentifier"] sender:self];
            
            MFUILogVerbose(@"perform segue : %@", columnDictionary[@"segueIdentifier"]);
            
        }
        if(self.segueColumns) {
            [self registerColumnsFromSegues:self.segueColumns];
            [self registerChildrenActions];
        }
        else {
            MFUILogWarn(@"No detail view controller seem to be linked with a workspace segue in the storyboard.");
        }
        
    } else {
        MFUILogError(@"mf.formDescriptorName is missing");
        [MFException throwExceptionWithName:@"MissingFormDescriptorName" andReason:@"The form descriptor name is missing" andUserInfo:nil];
    }
    [[self getWorkspaceView] scrollToMasterColumn];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    MFUILogVerbose(@"prepare segue");
    
    if (!self.segueColumns) {
        self.segueColumns = [NSMutableArray array];
    }
    
    [self.segueColumns addObject:segue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.segueColumns removeAllObjects];
}


#pragma mark - Workspace management

- (void) didSelectMasterIndex:(NSIndexPath *)indexPath from:(id<MFWorkspaceMasterColumnProtocol>)sourceController {
    
    if(!self.workspaceState.lastSelectedIndexPath) {
        self.workspaceState.lastSelectedIndexPath = indexPath;
    }
    
    self.workspaceState.currentSelectedIndexPath = indexPath;
    MFUIBaseViewModel *selectedViewModel = (MFUIBaseViewModel *)[sourceController viewModelAtIndexPath:indexPath];
    // if the view model is the same to nothing
    if (![selectedViewModel isEqual:self.currentMasterViewModel]) {
        
        // change the current master view model
        self.currentMasterViewModel = selectedViewModel;
        
        // if the view model have change show popup to save change
        if ([self checkHasChangedOrAsInvalidValues]) {
            // show popup
            UIAlertView *cancelSaveAlert = [[UIAlertView alloc]
                                            initWithTitle:MFLocalizedStringFromKey(@"alert_savechanges_title")
                                            message:MFLocalizedStringFromKey(@"alert_savechanges_message")
                                            delegate:self cancelButtonTitle:MFLocalizedStringFromKey(@"alert_savechanges_no") otherButtonTitles:MFLocalizedStringFromKey(@"alert_savechanges_yes"), nil];
            cancelSaveAlert.tag = kMasterSelectSaveChangesAlert;
            // show the popup
            [cancelSaveAlert show];
            // do not forward yet
        } else {
            // forward selected ViewModel
            [self changeViewModelInColumns:self.currentMasterViewModel];
        }
        
    } else {
        [[self getWorkspaceView] scrollToDetailColumnWithIndex:1];
    }
    
}

- (void) changeViewModelInColumns:(MFUIBaseViewModel*) selectedViewModel
{
    
    for(MFWorkspaceColumnSegue *segue in self.segueColumns) {
        if([segue.destinationViewController conformsToProtocol:@protocol(MFWorkspaceDetailColumnProtocol) ]) {
            MFFormViewController *detailViewController = (MFFormViewController *)segue.destinationViewController;
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
            
            if(selectedViewModel && [selectedViewModel respondsToSelector:@selector(id_identifier)]) {
                detailViewController.ids = @[[selectedViewModel performSelector:@selector(id_identifier) withObject:nil]];
            }
            else {
                detailViewController.ids = @[];
            }
#pragma clang diagnostic pop
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [detailViewController doFillAction];
            });
        }
        
    }
    
    [[self getWorkspaceView] scrollToDetailColumnWithIndex:1];
}

/**
 * @brief Register the columns from an array os WorkspaceSegue
 * @param columnSegues An array containing the segue that identify the columns of this workspace
 */
-(void) registerColumnsFromSegues:(NSArray *)columnSegues {
    for (UIStoryboardSegue *segue in columnSegues) {
        [segue.sourceViewController addChildViewController:(UIViewController *)segue.destinationViewController];
        if([segue isKindOfClass:[MFWorkspaceColumnSegue class]]) {
            [[self getWorkspaceView] addColumnFromSegue:(MFWorkspaceColumnSegue *)segue];
            if([segue.destinationViewController conformsToProtocol:@protocol(MFWorkspaceDetailColumnProtocol)]) {
                id<MFWorkspaceDetailColumnProtocol> detailColumn = (id<MFWorkspaceDetailColumnProtocol>) segue.destinationViewController;
                [detailColumn setColumnIndex:[columnSegues indexOfObject:detailColumn]];
            }
        }
    }
    [[self getWorkspaceView] refreshViewFromSegues:columnSegues];
}




-(void) createMasterItem {
    [self changeViewModelInColumns:nil];
}

#pragma mark - Resgister Actions

/**
 * @brief Event called when one of the launched actions succeeded
 * @param context The current context
 * @param caller The caller of the action
 * @param result The result of the action
 */
- (void) succeedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result{
    
    [super succeedSaveAction:context withCaller:caller andResult:result];
    [[self getWorkspaceView] scrollToMasterColumn];
    
    if([self.navigationItem.leftBarButtonItem isEqual:caller]) {
        //L'action vient du bouton save. Si on est sur un détail, on retourne au master
        [self popViewControllerAndReleaseObjects];
    }
    
    // save on index vm change
    if (self.isChangingMasterIndex) {
        // forward selected ViewModel
        [self changeViewModelInColumns:self.currentMasterViewModel];
        self.isChangingMasterIndex = NO;
    }
}

-(void)failedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result {
    [super failedSaveAction:context withCaller:caller andResult:result];
    
    [[self masterColumnViewcontroller].tableView selectRowAtIndexPath:self.workspaceState.lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.workspaceState.currentSelectedIndexPath = self.workspaceState.lastSelectedIndexPath;
    [[self getWorkspaceView] scrollToDetailColumnWithIndex:1];
}



#pragma mark - UIBarButtonItem events
/**
 * @brief Action called when the back button is pressed
 * @param sender The sender of the action
 */
-(void)onBackPressed:(id)sender {
    if([[self getWorkspaceView] isMasterColumnVisible]) {
        [super onBackPressed:sender];
    }
    else {
        [[self getWorkspaceView] scrollToDetailColumnWithIndex:0];
    }
    [[self getWorkspaceView] hideAnyModalInput];
}

-(void)onSavePressed:(id)sender {
    [super onSavePressed:sender];
    if(![sender isEqual:self]) {
        self.workspaceState.currentSelectedIndexPath = [[self masterColumnViewcontroller].tableView indexPathForSelectedRow];
    }
}



#pragma mark - Dialogs method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if (alertView.tag == kMasterSelectSaveChangesAlert) {
        if (buttonIndex == 0) { //Don't save
            [self resetDetailFormValidation];
            // forward selected ViewModel
            [self changeViewModelInColumns:self.currentMasterViewModel];
        }
        else { //OK save
            self.isChangingMasterIndex = YES;
            [self onSavePressed:self];
            // forward after saving
        }
    }
}


#pragma mark - Validation
/**
 * @brief Resets the details form validation in order to show a new item
 * @discussion This method shouyld be called when an invalid item is not saved, and that a new item
 * is requested. This case need to reset the validation state of the form.
 */
-(void) resetDetailFormValidation {
    for(MFWorkspaceColumnSegue *segue in self.segueColumns) {
        if([segue.destinationViewController conformsToProtocol:@protocol(MFWorkspaceDetailColumnProtocol) ]) {
            MFFormViewController *detailViewController = (MFFormViewController *)segue.destinationViewController;
            [detailViewController.formValidation resetValidation];
        }
    }
}


# pragma mark - Utils

/**
 * @brief Returns the ViewController that corresponds to the master View Controller of this worksapce
 * @return A MFFormBaseviewController that is the master view controller of this workspace
 */
-(MFFormBaseViewController<MFWorkspaceMasterColumnProtocol> *) masterColumnViewcontroller {
    for(UIStoryboardSegue *segue in self.segueColumns) {
        MFFormBaseViewController *columnViewcontroller = (MFFormBaseViewController *)segue.destinationViewController;
        if([columnViewcontroller conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
            return (MFFormBaseViewController<MFWorkspaceMasterColumnProtocol> *)columnViewcontroller;
        }
    }
    return nil;
}

/**
 * @brief Returns the view of this controller as a MFWorkspaceView
 * @return the MFWorkspaceView that is the main view of the WorkspaceViewController
 */
-(MFWorkspaceView *)getWorkspaceView {
    return (MFWorkspaceView *)self.view;
}

-(void) refreshSubViews {
    for(MFWorkspaceColumnSegue *segue in self.segueColumns) {
        if([segue.destinationViewController conformsToProtocol:@protocol(MFWorkspaceDetailColumnProtocol) ]) {
            MFFormBaseViewController *detailColumn = (MFFormBaseViewController *) segue.destinationViewController;
            dispatch_async(dispatch_get_main_queue(), ^{
                [detailColumn.tableView reloadData];
            });
        }
    }
}

-(void) releaseRetainedObjects {
    [[self getWorkspaceView] unregisterColumnsReferences];
    
    for(UIStoryboardSegue *segue in self.segueColumns) {
        MFFormBaseViewController *columnViewcontroller = (MFFormBaseViewController *)segue.destinationViewController;
        [[MFActionLauncher getInstance] MF_unregister:columnViewcontroller];
        
        [columnViewcontroller removeFromParentViewController];
        columnViewcontroller.formBindingDelegate = nil;
        ((id<MFUIBaseViewModelProtocol>)columnViewcontroller.viewModel).form = nil;
        columnViewcontroller.onDestroy = NO;
    }
    [self.segueColumns removeAllObjects];
}

-(MFViewControllerAttributes_Workspace *) workspaceAttributes {
    return (MFViewControllerAttributes_Workspace *)_mf;
}

@end





@implementation MFWorkspaceViewControllerState

/**
 * @brief Sets the current selected indexPath of the master view controller
 * @discussion This methods allows to update the current selected indexPath, after
 * updating the last selected index Path
 * @param currentSelectedIndexPath The new current selected indexPath of the master view controller.
 */
-(void)setCurrentSelectedIndexPath:(NSIndexPath *)currentSelectedIndexPath {
    self.lastSelectedIndexPath = _currentSelectedIndexPath;
    _currentSelectedIndexPath = currentSelectedIndexPath;
}

@end

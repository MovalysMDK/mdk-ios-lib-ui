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


//Imports MFCore
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreAction.h>

//Main interface
#import "MFFormViewController.h"

//Delegate & Protocol
#import "MFAppDelegate.h"
#import "MFFormValidationDelegate.h"
#import "MFTypeValueProcessingProtocol.h"

//Cells
#import "MFFormCellProtocol.h"
#import "MFCellAbstract.h"

//ViewControllers
#import "MFFormDetailViewController.h"
#import "MFMapViewController.h"
#import "MFPhotoDetailViewController.h"

//Utils
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import "MFUIApplication.h"
#import "MFConstants.h"
#import "MFConfigurationHandler.h"


//Binding and form
#import "MFUIBaseViewModel.h"

// Allowed values : (DiscardChangesAlert,SaveChangesAlert, AutomaticSave)
NSString *const MFPROP_FORM_ONUNSAVEDCHANGES = @"FormOnUnsavedChanges";

@interface MFFormViewController () <CLLocationManagerDelegate,UIAlertViewDelegate>

@property(nonatomic, strong) MFApplication *applicationContext;

@property(nonatomic) CGFloat keyboardVisibleHeight;

@property (nonatomic, strong) NSIndexPath *screenIndexPath;

@end

@implementation MFFormViewController

@synthesize viewModel = _viewModel;
@synthesize loadingOptions = _loadingOptions;
@synthesize ids = _ids;


/**
 Initialise le controlleur :
 - allocation de l'extension du formulaire
 */
-(void) initialize {
    [super initialize];
    self.keyboardVisibleHeight = CGFLOAT_MAX ;
    
    //Initializing FormValidation
    if([self usePartialViewModel]) {
        self.formValidation = [[MFFormViewControllerPartialValidationDelegate alloc] initWithFormController:self];
    }
    else {
        self.formValidation = [[MFFormViewControllerValidationDelegate alloc] initWithFormController:self];
    }
    
    //Initilizing fake "creen" indexpath. This corresponds to a fake indexpath associated ro
    self.screenIndexPath = [NSIndexPath indexPathForRow:SCREEN_INDEXPATH_ROW_IDENTIFIER inSection:SCREEN_INDEXPATH_SECTION_IDENTIFIER];
}


#pragma mark - Cycle de vie du controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //PROTODO : FAIRE CA + TARD ?
    MFAppDelegate *mfDelegate = nil;
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate isKindOfClass:[MFAppDelegate class]]){
        mfDelegate = (MFAppDelegate *) appDelegate;
    }
    
    //Setup bar items (back, save...)
    if(![self isKindOfClass:[MFFormDetailViewController class]]) {
        [self setupBarItems];
    }
    
    
    // fix separator display at the bottom of the tableview
    UIView *f = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    f.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:f];
}


- (void) setupBarItems {
    // Add back button on the left bar
    
    UIViewController *topController = [self.navigationController.viewControllers objectAtIndex:0];
    
    //Si le contrôleur courant est au sommet de la pile de navigation, on masque le bouton de retour car il n'y aucune
    //vue sur laquelle retourner.
    if (![self isEqual:topController]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:MFLocalizedStringFromKey(@"form_back") style: UIBarButtonItemStylePlain
                                                 target:self action:@selector(dismissMyView)];
        
    }
    
    // Add save button on right bar
    if([self showSaveButton]) {
        // Add save button on right bar
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"form_save")
                                                                       style:UIBarButtonItemStylePlain target:self action:@selector(doOnKeepModification:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
}


- (void)dealloc {
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    self.formValidation = nil;
}

-(void)doFillAction {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (doFillAction)" userInfo:nil]);
}

-(NSString *) nameOfDataLoader{
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (nameOfDataLoader)" userInfo:nil]);}

-(id<MFUIBaseViewModelProtocol>) createViewModel{
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (createViewModel)" userInfo:nil]);
}


#pragma mark - TableView DataSource

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // alert for discard changes
    if (alertView.tag == kDiscardChangesAlert && buttonIndex == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    // alert for save changes
    if (alertView.tag == kSaveChangesAlert ){
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self doOnKeepModification: self];
        }
    }
}

- (void)dismissMyView {
    
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
    
    if (!actionType || ![[self getFormValidation] onCloseFormDoAlert:doShowAlert andSave:doSave] ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) doOnKeepModification:(id)sender {
    MFUILogVerbose(@"doOnKeepModification");
}

-(MFFormViewControllerValidationDelegate *)getFormValidation {
    return (MFFormViewControllerValidationDelegate *)self.formValidation;
}


#pragma mark - Unimplemented


-(NSString *)nameOfViewModel {
    //Should be implemented in child classes if necessary
    return nil;
}

-(BOOL) usePartialViewModel {
    return NO;
}

//-(NSArray *) partialViewModelKeys {
//    return  @[];
//}

-(void)removeFromParentViewController {
    [super removeFromParentViewController];
    
}

-(BOOL) showSaveButton {
    //PROTODO : Compter le nombre de Champs éditables
    return YES;
}


@end

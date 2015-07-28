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


#import <CoreLocation/CoreLocation.h>

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreLog.h>

#import "MFFormListViewController.h"
#import "MFFormCellProtocol.h"
#import "MFPosition.h"
#import "MFMapViewController.h"
#import "MFTextField.h"
#import "MFConstants.h"
#import "MFUIBaseViewModel.h"
#import "MFCellAbstract.h"
#import "MFTypeValueProcessingProtocol.h"
#import "MFWorkspaceViewController.h"
#import "MFAppDelegate.h"
#import "MFDeleteDetailActionParamIn.h"
#import "MFDeleteDetailActionParamOut.h"
#import "MFUIBaseListViewModel.h"
#import "MFFormViewController.h"
#import "MFLocalizedString.h"
#import "MFAbstractComponentWrapper.h"
#import "MFObjectWithBindingProtocol.h"

#pragma mark - Interface privée

@interface MFFormListViewController () <CLLocationManagerDelegate>

/**
 * @brief the application context 
 */
@property(nonatomic, strong) MFApplication *applicationContext;

@end





@implementation MFFormListViewController {
    MFFormViewController *detailViewController;
}

@synthesize viewModel = _viewModel;
@synthesize showAddItemButton = _showAddItemButton;
@synthesize longPressToDelete = _longPressToDelete;
@synthesize detailStoryboardName = _detailStoryboardName;


#pragma mark - Constructeurs et initialisation

/**
 Initialise le controlleur :
 - allocation de l'extension du formulaire
 */
-(void) initialize {
    [super initialize];
    
    // Form's location manager init
    self.applicationContext = [MFApplication getInstance];
    self.viewModel.form = self;
    self.showAddItemButton = NO;
    self.longPressToDelete = NO;
}


#pragma mark - Cycle de vie du controller


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBarItems];

    
    // fix separator display at the bottom of the tableview
    UIView *tableViewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    tableViewFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:tableViewFooter];
}


- (void)dealloc
{
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    self.mf = nil;
}

- (void) setupBarItems
{
    // Add back button on the left bar
    
    UIViewController *topController = [self.navigationController.viewControllers objectAtIndex:0];
    
    //Si le contrôleur courant est au sommet de la pile de navigation, on masque le bouton de retour car il n'y aucune
    //vue sur laquelle retourner.
    if (![self isEqual:topController]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:MFLocalizedStringFromKey(@"form_back") style: UIBarButtonItemStyleBordered
                                                 target:self action:@selector(dismissMyView)];
    }
    
    // Add + button on right bar (to add an new item on the list)
    if ( self.showAddItemButton ) {
        UIBarButtonItem *uiButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                     target:self action:@selector(doOnCreateItem)];
        
        if(![self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
            self.navigationItem.rightBarButtonItem = uiButton;
        }
        else {
            [self addToolBarWithItems:@[uiButton]];
        }
    }

}

#pragma mark - TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int value  = ((MFUIBaseListViewModel *)[self getViewModel]).viewModels ? 1 : 0;
    return value;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger value = 0 ;
    MFUIBaseListViewModel *lvm = ((MFUIBaseListViewModel *)[self getViewModel]);
    NSFetchedResultsController *fetch =lvm.fetch;
    if ( fetch != nil ) {
        // mode curseur (le view model est construit au fur et à mesure)
        id <NSFetchedResultsSectionInfo> sectionInfo = [fetch.sections objectAtIndex:section];
        value  = sectionInfo ? [sectionInfo numberOfObjects]  : 0;
    }
    else {
        // mode direct (le view model est complet tout de suite)
        value = (lvm.viewModels == nil)?0:lvm.viewModels.count;
    }
    return value;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_1D_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    bindingData.cellIndexPath = indexPath;
    [cell bindCellFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData atIndexPath:indexPath];
    
    return cell;
}

-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_1D_DESCRIPTOR];
    return [bindingData.cellHeight floatValue];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.deleteAction )
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

/**
 * @brief Indique que cette cellule est éditable
 */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.deleteAction != nil;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( self.deleteAction != nil) {
        
        if(editingStyle == UITableViewCellEditingStyleDelete) {
            
            MFUIBaseListViewModel *listViewmodel = ((MFUIBaseListViewModel *)[self getViewModel]);
            MFUIBaseViewModel *selectedVm = [listViewmodel.viewModels objectAtIndex:indexPath.row];
            
            MFDeleteDetailActionParamIn *paramIn = [[MFDeleteDetailActionParamIn alloc] initWithIdentifier:[selectedVm valueForKey: self.itemIdentifier] andIndexPath:indexPath];
            
            id<MFContextFactoryProtocol> contextFactory = [[MFBeanLoader getInstance] getBeanWithType:@protocol(MFContextFactoryProtocol)];
            
            id<MFContextProtocol> mfContext = [contextFactory createMFContextWithChildCoreDataContextWithParent:listViewmodel.fetch.managedObjectContext];
            
            [[MFActionLauncher getInstance] launchAction:
            self.deleteAction withCaller:self withInParameter:paramIn andContext:mfContext];
            
            
            if (self.longPressToDelete) [self.tableView setEditing:NO animated:YES];
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
        id<MFWorkspaceMasterColumnProtocol> masterColumn = (id<MFWorkspaceMasterColumnProtocol>) self;
        [[masterColumn containerViewController] didSelectMasterIndex:indexPath from:masterColumn];
    } else {
        if ( self.detailStoryboardName != nil ) {
            UIStoryboard *detailStoryboard = [UIStoryboard storyboardWithName:self.detailStoryboardName bundle:nil];
            detailViewController = [detailStoryboard instantiateInitialViewController];
            MFUIBaseViewModel *vmItem = (MFUIBaseViewModel *) [self viewModelAtIndexPath:indexPath];
            detailViewController.ids = @[[vmItem valueForKey:self.itemIdentifier]];
            [detailViewController registerObserver:self];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_1D_DESCRIPTOR];
    bindingData.cellIndexPath = indexPath;
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingData generatedBindingKey]];
}


#pragma mark - Implémentation de  MFUITransitionDelegate


- (void)showViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion
{
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(void) navigateTo:(UIViewController *) toController
{
    
}

- (void)dismissMyView
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ViewModels management

-(NSObject<MFUIBaseViewModelProtocol> *) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<MFUIBaseViewModelProtocol> *vmItem = nil;
    MFUIBaseListViewModel *listVm = ((MFUIBaseListViewModel *)[self getViewModel]);
    
    
    if ( [listVm.viewModels count]>indexPath.row) {
        vmItem = [listVm.viewModels objectAtIndex:indexPath.row];
        if ( [[NSNull null] isEqual: vmItem]) {
            vmItem = nil ;
        }
    }
    
    
    if (vmItem == nil ) {
        
        id vmCreator = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
        if([[listVm.fetch.sections objectAtIndex:0] objects].count > indexPath.row) {
            id temp = [listVm.fetch objectAtIndexPath:indexPath];

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
            id tempVM =[vmCreator performSelector:@selector(createOrUpdateItemVM:withData:) withObject:[listVm defineViewModelName] withObject: temp];
#pragma clang diagnostic pop

            [listVm add:tempVM atIndex:indexPath.row];
            vmItem = tempVM ; //[listVm.viewModels objectAtIndex:indexPath.row];
        }
    }
    return vmItem;
}

-(MFUIBaseListViewModel *)getViewModel
{
    return (MFUIBaseListViewModel *)_viewModel;
}


-(void)setViewModel:(MFUIBaseListViewModel *)listViewModel
{
    _viewModel.form = self;
    _viewModel = listViewModel;
    ((MFUIBaseListViewModel *)[self getViewModel]).viewModels = listViewModel.viewModels;
}

-(void) refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if(self.searchDelegate) {
            [self.searchDelegate actualizePrompt];
        }
    });
    
}

- (void) doOnCreateItem
{
    if ( self.detailStoryboardName != nil ) {
        UIStoryboard *detailStoryboard = [UIStoryboard storyboardWithName:self.detailStoryboardName bundle:nil];
        detailViewController = [detailStoryboard instantiateInitialViewController];
        detailViewController.ids = @[];
        [detailViewController registerObserver:self];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if([self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
        MFWorkspaceViewController *parentWorkspaceViewController = (MFWorkspaceViewController *)[((id<MFWorkspaceMasterColumnProtocol>)self) containerViewController];
        [parentWorkspaceViewController createMasterItem];
        [self.tableView reloadData];
    }
}


-(void)deleteCell:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.tableView isEditing]) {
            [self.tableView setEditing:NO animated:YES];
            [(UITableViewCell *)gestureRecognizer.view setEditing:NO animated:YES];
        } else {
            [self.tableView setEditing:YES animated:YES];
            [(UITableViewCell *)gestureRecognizer.view setEditing:YES animated:YES];
        }
    }
}

#pragma mark - Methods from NSFetchedResultsControllerDelegate protocol

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [[MFApplication getInstance] execInMainQueue:^{
        [self.tableView beginUpdates];
    }];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    [[MFApplication getInstance] execInMainQueue:^{
        
        UITableView *tableView = self.tableView;
        
        MFUIBaseListViewModel *listViewmodel = nil;
        NSMutableArray *tempData = nil;
        
        switch(type) {
            case NSFetchedResultsChangeDelete:
                
                listViewmodel = (MFUIBaseListViewModel *) [self getViewModel];
                tempData = [listViewmodel.viewModels mutableCopy];
                [tempData removeObjectAtIndex:indexPath.row];
                listViewmodel.viewModels = tempData;
                listViewmodel.hasChanged = YES ;
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;

        }
        
    }];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    [[MFApplication getInstance] execInMainQueue:^{
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [[MFApplication getInstance] execInMainQueue:^{
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }];
}


#pragma mark - Unimplemented methods


-(void)doFillAction
{
    //The method is declared to avoid warnings of unimplemented methods.
    //The method coulb be implemented in child classes
}


- (void) onObservedViewController: (MFViewController *) viewController willDisappear: (NSDictionary *) parameters {
    if ([viewController isEqual:detailViewController]) {
        self.needDoFillAction = YES;
    }
}


- (void) onObservedViewController: (MFViewController *) viewController didAppear: (NSDictionary *) parameters {
    
}

-(void) addToolBarWithItems:(NSArray *)items {
    if([self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.items = items;
        
        toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        //id<MFWorkspaceMasterColumnProtocol> masterColumn = (id<MFWorkspaceMasterColumnProtocol>)self;
        
        NSLayoutConstraint *toolbarHeight = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:44];
        
        NSLayoutConstraint *toolbarWidth = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        
        NSLayoutConstraint *toolbarBottom = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        NSLayoutConstraint *toolbarLeft = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        
        
        NSLayoutConstraint *tableViewheight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-44];
        
        [self.view addSubview:toolbar];
        [self.view addConstraints:@[toolbarHeight, toolbarWidth, toolbarLeft, toolbarBottom, tableViewheight]];
        
        [self.view setNeedsUpdateConstraints];
    }
}

@end

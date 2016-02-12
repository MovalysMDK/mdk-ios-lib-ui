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
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreLog.h>

//Main interface
#import "MFForm2DListViewController.h"

//MFUI imports
#import "MFAppDelegate.h"
#import "MFUIApplication.h"

//ViewModels
#import "MFBaseViewModelWithSublistProtocol.h"
#import "MFUIBaseViewModel.h"

//Cells
#import "MFCellAbstract.h"
#import "MFFormCellProtocol.h"

//Workspace
#import "MFWorkspaceMasterColumnProtocol.h"
#import "MFWorkspaceViewController.h"

//Views and controllers
#import "MFFormSectionHeaderView.h"
#import "MFMapViewController.h"

//Utils
#import <MFCore/MFCoreI18n.h>
#import "MFConstants.h"
#import "MFTypeValueProcessingProtocol.h"
#import "MFAbstractControlWrapper.h"
#import "UIView+Binding.h"
#import "MFObjectWithBindingProtocol.h"

#pragma mark - Interface privée
@interface MFForm2DListViewController ()

/**
 * @brief The application context
 */
@property (nonatomic, strong) MFApplication *applicationContext;

/**
 * @brief A dictionnary that contains the reusable section views
 */
@property (nonatomic, strong) NSMutableDictionary *reusableSectionViews;

/**
 * @brief The total number of rows (only rows, no section).
 */
@property (nonatomic) NSInteger totalNumberOfRows;

/**
 * @brief An array that contains the liste of indexPathes to animate
 */
@property (nonatomic, strong) NSMutableArray *animatedSectionsIndexPath;

/**
 * @brief An array that contains the liste of indexPathes to animate
 */
@property (nonatomic, strong) NSMutableArray *alreadyBindedSections;

@end




@implementation MFForm2DListViewController {
    MFFormViewController *detailViewController;
}
@dynamic viewModel;
@dynamic bindingDelegate;

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
    self.reusableSectionViews = [NSMutableDictionary dictionary];
    self.filterParameters = [NSDictionary dictionary];
    self.animatedSectionsIndexPath = [[NSMutableArray alloc] init];
    self.showAddItemButton = NO;
    self.longPressToDelete = NO;
    self.alreadyBindedSections = [NSMutableArray array];
}

- (void) setupBarItems {
    
    // Add + button on right bar (to add an new item on the list)
    if ( self.showAddItemButton ) {
        UIBarButtonItem *uiButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                     
                                     target:self action:@selector(doOnCreateItem)];
        if([self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
            [self addToolBarWithItems:@[uiButton]];
        }
        else {
            self.navigationItem.rightBarButtonItem = uiButton;
            
        }
    }
    
}

-(void) didCreateBindingStructure {
    MFBindingViewDescriptor *bindingDataSection = self.bindingDelegate.structure[SECTION_HEADER_VIEW_2D_DESCRIPTOR];
    UINib *sectionHeaderViewNib = [UINib nibWithNibName:bindingDataSection.viewIdentifier bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:sectionHeaderViewNib forHeaderFooterViewReuseIdentifier:[NSString stringWithFormat:@"%@", SECTION_HEADER_VIEW_2D_DESCRIPTOR]];
}

#pragma mark - Cycle de vie du controller

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.tableView.scrollsToTop = YES;
    
    
    // fix separator display at the bottom of the tableview
    UIView *footerDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    footerDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:footerDivider];
    
    [self setupBarItems];
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    self.mf = nil;
    
}



#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger returnValue = 0;
    MFUIBaseListViewModel *lvm = [self sectionViewModelsList];
    NSFetchedResultsController *fetch = lvm.fetch;
    if (fetch) {
        // mode curseur (le view model est construit au fur et à mesure)
        id <NSFetchedResultsSectionInfo> sectionInfo = [fetch.sections objectAtIndex:0];
        //        self.sectionsViewModelList = [sectionInfo objects];
        returnValue = sectionInfo ? [sectionInfo numberOfObjects]  : 0;
    }
    else {
        returnValue = lvm.viewModels.count;
    }
    
    return returnValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    if(!self.openedSectionStates) {
        self.openedSectionStates = [NSMutableDictionary dictionary];
    }
    
    NSNumber *isOpened = @0;
    if([self.openedSectionStates objectForKey:[NSNumber numberWithInteger:section]]) {
        isOpened = [self.openedSectionStates objectForKey:[NSNumber numberWithInteger:section]];
    }
    else {
        isOpened = @([self allSectionsOpenedFirst]);
        [self.openedSectionStates setObject:isOpened forKey:[NSNumber numberWithInteger:section]];
    }
    
    if([isOpened isEqualToNumber:@1]) {
        MFUIBaseListViewModel *subListViewModel = nil;
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForRow:section inSection:SECTION_INDEXPATH_IDENTIFIER];
        subListViewModel = ((id<MFBaseViewModelWithSublistProtocol>)[self viewModelAtIndexPath:sectionIndexPath]).subList;
        returnValue = subListViewModel.viewModels.count;
    }
    else {
        returnValue = 0;
    }
    self.totalNumberOfRows += returnValue;
    return returnValue;
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
    
    if([cell respondsToSelector:@selector(didConfigureCell)]) {
        [cell performSelector:@selector(didConfigureCell)];
    }
    
    return cell;
}

-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
}

-(void) updateViewFromBindingData:(MFBindingViewDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[SECTION_HEADER_VIEW_2D_DESCRIPTOR];
    return [bindingData.viewHeight floatValue];
}


-(void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    MFBindingViewDescriptor *bindingDataSection = self.bindingDelegate.structure[SECTION_HEADER_VIEW_2D_DESCRIPTOR];
    bindingDataSection.viewIndexPath = [NSIndexPath indexPathForRow:section inSection:SECTION_INDEXPATH_IDENTIFIER];
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingDataSection generatedBindingKey]];
    [self.alreadyBindedSections removeObject:@(section)];

}


-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingDataCell = self.bindingDelegate.structure[CELL_1D_DESCRIPTOR];
    bindingDataCell.cellIndexPath = indexPath;
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingDataCell generatedBindingKey]];
    
    
   }

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[SECTION_HEADER_VIEW_2D_DESCRIPTOR];
    MFFormSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[NSString stringWithFormat:@"%@", SECTION_HEADER_VIEW_2D_DESCRIPTOR]];
    if(!view) {
        view = [self sectionView];

    }
    bindingData.viewIndexPath = [NSIndexPath indexPathForRow:section inSection:SECTION_INDEXPATH_IDENTIFIER];
    [view bindViewFromDescriptor:bindingData onObjectWithBinding:self];
    [self.alreadyBindedSections addObject:@(section)];

    
    [self updateViewFromBindingData:bindingData atIndexPath:bindingData.viewIndexPath];
    view.sender = self;
    view.identifier = @(section);
    view.isOpened = [self.openedSectionStates[@(section)] boolValue];
    return view;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

#pragma mark - Implémentation de  MFUITransitionDelegate

-(void) navigateTo:(UIViewController *) toController
{
    
}

- (void)showViewController:(UIViewController *)viewControllerToPresent
                  animated: (BOOL)flag
                completion:(void (^)(void))completion;
{
    
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

#pragma mark - ViewModels management

/**
 * @brief Returns the list of sections view models
 */
-(MFUIBaseListViewModel *) sectionViewModelsList {
    return ((MFUIBaseListViewModel *)self.viewModel);
}

/**
 * @brief Returns the list of sections view models
 */
-(MFUIBaseListViewModel *) itemsViewModelsListOfSection:(int)section {
    return ((id<MFBaseViewModelWithSublistProtocol>)[[self sectionViewModelsList].viewModels objectAtIndex:section]).subList;
}

-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath {
    
    id<MFUIBaseViewModelProtocol> returnViewModel = nil;
    MFUIBaseListViewModel *parentListViewModel = nil;
    
    // Récupération du bon ListViewModel
    // Si l'indexpath correspond à une section (section = SECTION_INDEXPATH_IDENTIFIER ; row = numéro de la section de la tableView),
    // on récupère le ViewModel du controller.
    // Si l'indexPath correspond à un item (section = numéro de la section de la tableView dans laquelle se trouve l'item, row = position de l'item
    // dans la section)
    if(indexPath.section == SECTION_INDEXPATH_IDENTIFIER ) {
        parentListViewModel = [self sectionViewModelsList];
        if ([parentListViewModel.viewModels count]>indexPath.row) {
            returnViewModel = [parentListViewModel.viewModels objectAtIndex:indexPath.row];
            //Récupération du ViewModel de la section, ou mise à nil si le viewModel retourné vaut NSNUll
            if ( [[NSNull null] isEqual:returnViewModel]) {
                returnViewModel = nil ;
            }
        }
    }
    else {
        //Récupération du ViewModel de la section dans lequel se trouve l'item
        id<MFBaseViewModelWithSublistProtocol> sectionViewModel = nil;
        if(indexPath.section < [self sectionViewModelsList].viewModels.count) {
            sectionViewModel = (id<MFBaseViewModelWithSublistProtocol>)[[self sectionViewModelsList].viewModels objectAtIndex:indexPath.section];
            
            if(![[NSNull null] isEqual:sectionViewModel]) {
                //Récupération du sous-ListViewModel de ce ViewModel de section.
                parentListViewModel = sectionViewModel.subList;
                if ([parentListViewModel.viewModels count]>indexPath.row) {
                    returnViewModel = [parentListViewModel.viewModels objectAtIndex:indexPath.row];
                    //Récupération du ViewModel de l'item, ou mise à nil si le viewModel retourné vaut NSNUll
                    if ( [[NSNull null] isEqual: returnViewModel]) {
                        returnViewModel = nil ;
                    }
                }
            }
        }
        else {
            returnViewModel = nil;
        }
    }
    
    //Si aucun ViewModel n'a été créé, on le créé via le ViewModelCreator
    if (!returnViewModel) {
        MFDefaultViewModelCreator *vmCreator = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
        
        // On corrige l'indexPath transmis (dans le cas où l'on veut récupérer un ViewModel de section,
        // on a indexPath.section = SECTION_INDEXPATH_IDENTIFIER;
        // On le corrige donc pour récupérer les données du fetchResultController avec indexPath.section = 0
        // et indexPath.row = numéro de section demandé.
        NSIndexPath *fetchIndexPath = indexPath;
        if(indexPath.section == SECTION_INDEXPATH_IDENTIFIER ) {
            fetchIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        }
        
        //Récupération des données du fetch, nécessaire pour créer le ViewModel
        id fetchedData = [parentListViewModel.fetch objectAtIndexPath:fetchIndexPath];
        
        //Récupération du nom de ViewModel a créer
        NSString *viewModelName = [parentListViewModel defineViewModelName];
        
        //Si les données du fetch et le nom du ViewModel ne sont pas nul, on le crée.
        if(fetchedData && viewModelName) {
            returnViewModel =[vmCreator createOrUpdateItemVM:viewModelName withData:fetchedData withFilterParameters:self.filterParameters];
            [parentListViewModel add:(MFUIBaseViewModel *)returnViewModel atIndex:fetchIndexPath.row];
        }
    }
    return returnViewModel;
}




-(void) refresh {
    self.filterParameters = nil;
    [self.tableView reloadData];
}

-(void) refreshWithParameters:(NSDictionary *)parameters {
    self.filterParameters = parameters;
    [self reloadDataWithAnimationFromRight:NO];
    
}


-(MFFormSectionHeaderView *) sectionView {
    MFFormSectionHeaderView *view = [[MFFormSectionHeaderView alloc] initWithReuseIdentifier:[NSString stringWithFormat:@"%@", SECTION_HEADER_VIEW_2D_DESCRIPTOR]];
    return view;
}



#pragma mark - Closing and opening sections

-(void)closeSectionAtIndex:(NSNumber *)section {
    
    NSInteger numberOfCellToDelete = [self.tableView numberOfRowsInSection:[section intValue]];
    for(int i = 0 ; i < numberOfCellToDelete ; i++) {
        [self.animatedSectionsIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:[section intValue]]];
    }
    
    //Update the tableView
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:self.animatedSectionsIndexPath withRowAnimation:UITableViewRowAnimationMiddle];
    
    
    [self.openedSectionStates setObject:@0 forKey:section];
    [self.animatedSectionsIndexPath removeAllObjects];
    [self.tableView endUpdates];
    
}

-(void)openSectionAtIndex:(NSNumber *)section {
    
    //getting the indexPath of this sections
    NSInteger numberOfCellsToInsert = 0;
    NSIndexPath *virtualSectionIndexPath = [NSIndexPath indexPathForRow:[section intValue] inSection:SECTION_INDEXPATH_IDENTIFIER];
    MFUIBaseViewModel *viewModel = (MFUIBaseViewModel *)[self viewModelAtIndexPath:virtualSectionIndexPath];
    if([viewModel conformsToProtocol:@protocol(MFBaseViewModelWithSublistProtocol)]) {
        MFUIBaseListViewModel *subList = ((id<MFBaseViewModelWithSublistProtocol>)viewModel).subList;
        numberOfCellsToInsert =  subList.viewModels.count;
    }
    for(int i = 0 ; i < numberOfCellsToInsert ; i++) {
        [self.animatedSectionsIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:[section intValue]]];
        [[self.tableView cellForRowAtIndexPath:self.animatedSectionsIndexPath[i]] setNeedsDisplay];
    }
    
    //Update the tableView
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:self.animatedSectionsIndexPath withRowAnimation:UITableViewRowAnimationMiddle];
    [self.openedSectionStates setObject:@1 forKey:section];
    [self.animatedSectionsIndexPath removeAllObjects];
    [self.tableView endUpdates];
    
    
    
}



-(void)reloadDataWithAnimationFromRight:(BOOL)fromRight {
    
    [self.openedSectionStates removeAllObjects];
    for(NSString *key in self.reusableSectionViews.allKeys) {
        MFFormSectionHeaderView *sectionView = [self.reusableSectionViews objectForKey:key];
        [sectionView reinit];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    self.totalNumberOfRows = 0;
    [super reloadData];
}



-(void)doFillAction {
    
}


#pragma mark - Test methods

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
        MFWorkspaceViewController *parentWorkspaceViewController =
        (MFWorkspaceViewController *)[((id<MFWorkspaceMasterColumnProtocol>)self) containerViewController];
        [parentWorkspaceViewController createMasterItem];
        [self.tableView reloadData];
    }
}


-(void) addToolBarWithItems:(NSArray *)items {
    if([self conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.items = items;
        
        toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *toolbarHeight =
        [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                     attribute:NSLayoutAttributeHeight multiplier:0 constant:44];
        
        NSLayoutConstraint *toolbarWidth =
        [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                     attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        
        NSLayoutConstraint *toolbarBottom =
        [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                     attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        NSLayoutConstraint *toolbarLeft =
        [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                     attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        
        
        NSLayoutConstraint *tableViewheight =
        [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual toItem:self.view
                                     attribute:NSLayoutAttributeHeight multiplier:1 constant:-44];
        
        [self.view addSubview:toolbar];
        [self.view addConstraints:@[toolbarHeight, toolbarWidth, toolbarLeft, toolbarBottom, tableViewheight]];
        
        [self.view setNeedsUpdateConstraints];
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


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [[MFApplication getInstance] execInMainQueue:^{
        
        UITableView *tableView = self.tableView;
        
        MFUIBaseListViewModel *listViewmodel = nil;
        NSMutableArray *tempData = nil;
        
        switch(type) {
            case NSFetchedResultsChangeDelete:
                [[self getListViewModel] deleteItemAtIndex:indexPath.row];
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }];
}

-(MFUIBaseListViewModel *) getListViewModel {
    return (MFUIBaseListViewModel *)self.viewModel;
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    [[MFApplication getInstance] execInMainQueue:^{
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
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



- (void) onObservedViewController: (MFViewController *) viewController willDisappear: (NSDictionary *) parameters {
    if ([viewController isEqual:detailViewController]) {
        self.needDoFillAction = YES;
    }
}


- (void) onObservedViewController: (MFViewController *) viewController didAppear: (NSDictionary *) parameters {
    
}

-(BOOL) allSectionsOpenedFirst {
    return NO;
}

-(void)setOpenedSectionStates:(NSMutableDictionary *)openedSectionStates {
    _openedSectionStates = openedSectionStates;
}


@end

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
//  MFForm3DListViewController.m
//  MFUI
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreLog.h>

#import "MFConstants.h"
#import "MFForm3DListViewController.h"
#import "MFBaseViewModelWithSublistProtocol.h"
#import "MFBindingViewAbstract.h"
#import "MFBaseViewModelWithSublistProtocol.h"



@interface MFForm3DListViewController ()

/**
 * @brief The descriptor of the header of this 3D List
 */
@property (nonatomic, strong) MFFormDescriptor *headerDescriptor;

/**
 * @brief The current displayedPage of the 3D List
 */
@property (nonatomic) int currentPage;

/**
 * @brief The reusable view for header.
 */
@property (nonatomic, strong) NSMutableDictionary *reusableHeaderViews;


@property (nonatomic) NSInteger totalNumberOfRows;


@end



@implementation MFForm3DListViewController
@synthesize viewModel =_viewModel;

#pragma mark - Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reusableHeaderViews = [NSMutableDictionary dictionary];
    self.headerView.delegate = self;
    
    self.headerDescriptor = [self loadDescriptorWithName:@"headerFormDescriptorName"];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Specific method to bind headerView to ViewModel
/**
 * @brief Refreshs the header view when needed (after select a new page for example)
 */
-(void) refreshHeaderView {
    if(!self.headerView.contentView) {
        self.headerView.contentView = [self buildHeaderView];
    }
    
    [self bindHeaderView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headerView.arrowPrevious setEnabled:(self.currentPage != 0)];
        [self.headerView.arrowNext setEnabled:!(self.currentPage+1 == [[[((MFUIBaseListViewModel *)self.viewModel).fetch sections] objectAtIndex:0] objects].count)];
    });
        if(self.headerDescriptor) {
        [self setScreenTitle];
    }
    
}

/**
 * @brief Refreshs the list of the controller.
 * This method is called at load, and each time the user selects a new page.
 * An animation is played from left or right following the event (next or previous page).
 * @param fromRight A boolean that indicates if the animation should be played from right (YES) or left (NO)
 */
-(void) refreshViewModelListFromRight:(BOOL)fromRight {
    self.sectionsViewModelList = ((id<MFBaseViewModelWithSublistProtocol>)[self viewModelAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:HEADER_INDEXPATH_IDENTIFIER]]).subList.viewModels;
    
    self.totalNumberOfRows = 0;
    [self reloadDataWithAnimationFromRight:fromRight];
    [self .tableView scrollsToTop];

    
    MFBindingViewAbstract *reusableHeaderView = [self.reusableHeaderViews objectForKey:[NSNumber numberWithInteger:self.currentPage]];
    UIView *returnView = nil;
    if(reusableHeaderView) {
        returnView = reusableHeaderView;
        ((MFBindingViewAbstract *)returnView).identifier = [NSNumber numberWithInteger:self.currentPage];
    }
    else {
        returnView = [self buildHeaderView];
        ((MFBindingViewAbstract *)returnView).sender = self;
        ((MFBindingViewAbstract *)returnView).identifier = [NSNumber numberWithInteger:self.currentPage];
        [self.reusableHeaderViews setObject:returnView forKey:[NSNumber numberWithInteger:self.currentPage]];
    }
}

/**
 * @brief Builds the header view if nil
 * @return A bindalbe headerView with controls to select previous and next page
 */
-(MFBindingViewAbstract *) buildHeaderView {
    
    MFBindingViewAbstract * view = nil;
    if(self.headerDescriptor) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:self.headerDescriptor.uitype owner:self options:nil];
        if(topLevelObjects && topLevelObjects.count >0) {
            view = [topLevelObjects objectAtIndex:0];
        }
    }
    
    return view;
}


/**
 * @brief Binds the headerView to ViewModel
 */
-(void) bindHeaderView {
    [self.headerView.contentView unregisterComponents:self.formBindingDelegate];
    
    self.headerView.contentView.formController = self;
    NSIndexPath *virtualIndexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:HEADER_INDEXPATH_IDENTIFIER];
    
    MFSectionDescriptor *currentSection = self.headerDescriptor.sections[0];
    MFGroupDescriptor *currentGd = nil;
    currentGd = currentSection.orderedGroups[0];
    
    if([self.headerView.contentView conformsToProtocol:@protocol(MFBindingViewProtocol)]) {
        
        //Réinitialisation de la vue
        id<MFFormCellProtocol> formView = (id<MFFormCellProtocol>)self.headerView.contentView;
        ((MFBindingViewAbstract *)formView).formController = self;
        [((MFBindingViewAbstract *)formView) refreshComponents];
        
        //Style de la cellule
        [formView configureByGroupDescriptor:currentGd andFormDescriptor:self.sectionDescriptor];
        [formView setCellIndexPath:virtualIndexPath];
        //Enregistrement des composants graphiques de la vue
        NSDictionary *newRegisteredComponents = [self registerComponentsFromCell:formView];

        for(NSString *key in [newRegisteredComponents allKeys]) {
            //Récupération de la liste des composants associé à ce keyPath
            MFCoreLogVerbose(@" key : %@" , key);
            NSMutableArray *componentList = [[self.binding componentsArrayAtIndexPath:virtualIndexPath] mutableCopy];
            if(componentList) {
                for( NSString *fieldName in currentGd.fieldNames) {
                    MFUIBaseComponent *component = [self.headerView.contentView valueForKey:fieldName];
                    [self initComponent:component atIndexPath:virtualIndexPath];
                }
            }
        }
        [self setDataOnView:formView withOptionalViewModel:(MFUIBaseViewModel *)[self viewModelAtIndexPath:virtualIndexPath]];
    }
}


-(void)refreshWithParameters:(NSDictionary *)parameters {
    self.filterParameters = parameters;
    self.currentPage = 0;
}

#pragma mark - MFForm3DControlsDelegate methods


-(void)onNext {
    NSFetchedResultsController *fetchedController = ((MFUIBaseListViewModel *)self.viewModel).fetch;
    if([[fetchedController.sections objectAtIndex:0] objects].count > self.currentPage+1) {
        self.currentPage++;
    }
}

-(void)onPrevious {
    if(self.currentPage > 0) {
        self.currentPage--;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger returnValue = 0;
    if(self.sectionsViewModelList) {
        returnValue = self.sectionsViewModelList.count;
    }
    return returnValue;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    if(self.sectionsViewModelList && self.sectionsViewModelList.count > 0) {
        if(!self.openedSectionStates) {
            self.openedSectionStates = [NSMutableDictionary dictionary];
        }
        
        NSNumber *isOpened = @0;
        if([self.openedSectionStates objectForKey:[NSNumber numberWithInteger:section]]) {
            isOpened = [self.openedSectionStates objectForKey:[NSNumber numberWithInteger:section]];
        }
        else {
            isOpened = @1;
            [self.openedSectionStates setObject:isOpened forKey:[NSNumber numberWithInteger:section]];
        }
        
        if([isOpened isEqualToNumber:@1]) {
            MFUIBaseListViewModel *lvm = ((id<MFBaseViewModelWithSublistProtocol>)[self viewModelAtIndexPath:[NSIndexPath indexPathForRow:section inSection:SECTION_INDEXPATH_IDENTIFIER]]).subList;
            returnValue = lvm.viewModels.count;
        }
        else {
            returnValue = 0;
        }
    }
    self.totalNumberOfRows += returnValue;
    return returnValue;
}

#pragma mark - Custom methods

/**
 * @brief Override of currentPage setter. Allow to do specific action when a new page is selected
 * @param currentPage The new currentPage to set
 */
-(void)setCurrentPage:(int)currentPage {
    BOOL fromRight = currentPage > _currentPage;
    _currentPage = currentPage;
    [self refreshHeaderView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshViewModelListFromRight:fromRight];
        
    });
}

-(void)setScreenTitle {
    NSFetchedResultsController *fetchedController = ((MFUIBaseListViewModel *)self.viewModel).fetch;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%i/%lu)", self.headerDescriptor.name, self.currentPage+1, (unsigned long)[[fetchedController.sections objectAtIndex:0] objects].count ];
}

/**
 * @brief Get a viewModel depending on an indexPath
 * @param indexPath The indexPath to the view/cell binded at the ViewModel that we want to get
 * @return A viewModel corresponding to the passed indexPath
 */
-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    //Le ViewModel d'un header est récupéré depuis le fetch du ViewModel associé à ce formulaire, car ils 'agit des ViewModels
    //du plus haut niveaiu.
    id<MFUIBaseViewModelProtocol> vmItem = nil;
    MFUIBaseListViewModel *listVM = nil;
    if(indexPath.section == HEADER_INDEXPATH_IDENTIFIER ) {
        listVM = ((MFUIBaseListViewModel *)self.viewModel);
        if ( [listVM.viewModels count]>indexPath.row) {
            vmItem = [listVM.viewModels objectAtIndex:self.currentPage];
        }
        if (!vmItem || [[NSNull null] isEqual: vmItem]) {
            vmItem = [self createViewModelItemAtIndexPath:indexPath fromListViewModel:listVM];
        }
    }
    
    //Le viewModel d'une section est récupréré à partir de la liste des ViewModels du header courant.
    //Comme le viewModel du header courant n'est pas nul, celui contenu à la position donné dans la liste
    //de ses viewModels est forcément non nul
    else if(indexPath.section == SECTION_INDEXPATH_IDENTIFIER ) {
        if(((MFUIBaseListViewModel *)self.viewModel).viewModels.count > self.currentPage) {
            listVM = ((id<MFBaseViewModelWithSublistProtocol>) [((MFUIBaseListViewModel *)self.viewModel).viewModels objectAtIndex:self.currentPage]).subList;
            if ( [listVM.viewModels count]>indexPath.row) {
                vmItem = [listVM.viewModels objectAtIndex:indexPath.row];
            }
        }
        
    }
    
    //Idem
    else {
        listVM = ((MFUIBaseListViewModel *)self.viewModel);
        if(listVM.viewModels.count > self.currentPage) {
            listVM = ((id<MFBaseViewModelWithSublistProtocol>)[((MFUIBaseListViewModel *)self.viewModel).viewModels objectAtIndex:self.currentPage]).subList;
            if(listVM.viewModels.count > indexPath.section) {
                listVM = ((id<MFBaseViewModelWithSublistProtocol>)[listVM.viewModels objectAtIndex:indexPath.section]).subList;
                if ( [listVM.viewModels count]>indexPath.row) {
                    vmItem = [listVM.viewModels objectAtIndex:indexPath.row];
                }
            }
        }
    }
    return vmItem;
}



-(MFUIBaseViewModel *) createViewModelItemAtIndexPath:(NSIndexPath *)indexPath fromListViewModel:(MFUIBaseListViewModel *)listVM{
    MFUIBaseViewModel *vmItem = nil;
    
    //On crée le ViewModel en le récupérant dans le fetch de la liste de plus haut niveau.
    MFDefaultViewModelCreator *vmCreator = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
    NSIndexPath *realIndexPath = indexPath;
    
    //On corrige son indexPath. Sa section est forcément 0 car la liste des headers
    //représente une section dans le fetch retourné par le dataLoader de ce niveau
    if(indexPath.section == HEADER_INDEXPATH_IDENTIFIER ) {
        realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    }
    
    if(listVM.fetch.fetchedObjects.count > indexPath.row) {
        id temp = [listVM.fetch objectAtIndexPath:realIndexPath];
        NSString *viewModelName = [listVM defineViewModelName];
        id tempVM =[vmCreator createOrUpdateItemVM:viewModelName withData:temp withFilterParameters:self.filterParameters];
        [listVM add:tempVM atIndex:realIndexPath.row];
        vmItem = tempVM;
    }
    return vmItem;
}



/**
 * @see MFForm2DListViewController.h
 */
-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender{
    
    if([((MFUIBaseListViewModel *)self.viewModel).viewModels containsObject:viewModelSender]) {
        
        NSIndexPath *componentIndexPath = [NSIndexPath indexPathForRow:self.currentPage inSection:HEADER_INDEXPATH_IDENTIFIER];

        NSMutableArray *componentList = [[self.binding componentsAtIndexPath:componentIndexPath withBindingKey:bindingKey] mutableCopy];
        
        //Si la ressource n'est pas déja tenue par un autre évènement
        if([self.formBindingDelegate mutexForProperty:bindingKey]) {
            
            //Récupération et application du filtre ppour ce composant
            MFValueChangedFilter applyFilter = [[self filtersFromViewModelToForm] objectForKey:bindingKey];
            BOOL continueDispatch = YES;
            if(applyFilter)
                continueDispatch = applyFilter(bindingKey, viewModelSender, self.binding);
            
            
            //Si la mise a jour n'est pas bloquée par le filtre
            if(continueDispatch) {
                if(componentList) {
                    for(id<MFUIComponentProtocol> component in componentList) {
                        id oldValue = [component getData];
                        id newValue =[viewModelSender valueForKeyPath:bindingKey];
                        newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:NO];
                        MFNonEqual(oldValue, newValue, ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [component setData:newValue];
                            });
                        });
                        
                    }
                }
                else {
                    [self performSelectorForPropertyBinding:bindingKey onViewModel:viewModelSender withIndexPath:componentIndexPath];
                }
            }
            // On lâche la ressource à la fin du traitement
            [self releasePropertyFromMutex:bindingKey];
        }
        else {
            // Si on passe ici, c'est que le champ vient d'être modifié dans le viewModel suite à une modif du formulaire.
            // On peut donc maintenant appliquer la modification la m"thode custom appelée quand le champ est modifié dans le modèle
            [self applyCustomValueChangedMethodForComponents:componentList atIndexPath:componentIndexPath];
            [self releasePropertyFromMutex:bindingKey];
        }
    }
    else {
        [super dispatchEventOnViewModelPropertyValueChangedWithKey:bindingKey sender:viewModelSender];
    }
}

-(void)setViewModel:(MFUIBaseListViewModel *)listViewModel {
    //dès lors que le ViewModel est mis, on force la première page pour afficher les premières données
    _viewModel.form = self;
    _viewModel = listViewModel;
    ((MFUIBaseListViewModel *)[self getViewModel]).viewModels = listViewModel.viewModels;
    self.currentPage = 0;
    [self.headerView.arrowPrevious setEnabled:(self.currentPage != 0)];
    
}

-(void)setHeaderDescriptor:(MFFormDescriptor *)headerDescriptor {
    // dès lors que le headerDescriptor est mis, on rafraîchit la vue du header pour afficher ses données
    _headerDescriptor = headerDescriptor;
    [self refreshHeaderView];
}

-(void)unregisterAllComponents {
    [super unregisterAllComponents];
    [self.reusableHeaderViews removeAllObjects];
    self.reusableHeaderViews = nil;
}

@end

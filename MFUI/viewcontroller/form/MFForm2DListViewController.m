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
//  MFForm2DListViewController.m
//  MFUI
//
//

//MFCore imports
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreFormDescriptor.h>
#import <MFCore/MFCoreFormConfig.h>
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

//Binding
#import "MFBaseBindingForm.h"

//Utils
#import "MFLocalizedString.h"
#import "MFConstants.h"
#import "MFTypeValueProcessingProtocol.h"

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

@end




@implementation MFForm2DListViewController {
    MFFormViewController *detailViewController;
}

@synthesize viewModel = _viewModel;
@synthesize formDescriptor;
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


#pragma mark - Cycle de vie du controller

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.tableView.scrollsToTop = YES;
    
    self.sectionDescriptor = [self loadDescriptorWithName:@"sectionFormDescriptorName"];
    self.cellDescriptor = [self loadDescriptorWithName:@"formDescriptorName"];
    self.formDescriptor = self.cellDescriptor;
    
    // fix separator display at the bottom of the tableview
    UIView *footerDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    footerDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:footerDivider];
    
    if(self.sectionDescriptor) {
        self.navigationItem.title = self.sectionDescriptor.name;
    }
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
    self.formDescriptor = nil;
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
        isOpened = @1;
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
    //    }
    self.totalNumberOfRows += returnValue;
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Récupération de la cellule créée par le BaseFormController
    id<MFFormCellProtocol> formCell = (id<MFFormCellProtocol>)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //Mise à jour des données des composants de la cellule
    [self setDataOnView:formCell];
    return (UITableViewCell *)formCell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *reusableheaderView = [self.reusableSectionViews objectForKey:[NSNumber numberWithInteger:section]];
    UIView *returnView = nil;
    if(reusableheaderView) {
        returnView = reusableheaderView;
        ((MFFormSectionHeaderView *)returnView).identifier = [NSNumber numberWithInteger:section];
    }
    else {
        returnView = [self sectionView];
        ((MFFormSectionHeaderView *)returnView).sender = self;
        ((MFFormSectionHeaderView *)returnView).identifier = [NSNumber numberWithInteger:section];
        [self.reusableSectionViews setObject:returnView forKey:[NSNumber numberWithInteger:section]];
    }
    
    MFFormSectionHeaderView * view =  (MFFormSectionHeaderView *)returnView;
    
    MFSectionDescriptor *currentSection = self.sectionDescriptor.sections[0];
    MFGroupDescriptor *currentGd = nil;
    currentGd = currentSection.orderedGroups[0];
    
    NSIndexPath *virtualIndexPath = [NSIndexPath indexPathForItem:section inSection:SECTION_INDEXPATH_IDENTIFIER];
    
    if([view conformsToProtocol:@protocol(MFBindingViewProtocol)]) {
        
        //Réinitialisation de la vue
        id<MFFormCellProtocol>  formView = (id<MFFormCellProtocol>)view;
        ((MFFormSectionHeaderView *)formView).formController = self;
        [((MFFormSectionHeaderView *)formView) refreshComponents];
        [formView setCellIndexPath:virtualIndexPath];
        
        //Style de la cellule
        [formView configureByGroupDescriptor:currentGd andFormDescriptor:self.sectionDescriptor];
        
        //Enregistrement des composants graphiques de la vue
        NSDictionary *newRegisteredComponents = [self registerComponentsFromCell:formView];
        for(NSString *key in [newRegisteredComponents allKeys]) {
            NSMutableArray *componentList = [[self.binding componentsAtIndexPath:virtualIndexPath withBindingKey:key] mutableCopy];
            if(componentList) {
                for( NSString *fieldName in currentGd.fieldNames ) {
                    MFUIBaseComponent *component = [view valueForKey:fieldName];
                    [self initComponent:component atIndexPath:virtualIndexPath];
                }
            }
        }
        [self setDataOnView:formView withOptionalViewModel:[self viewModelAtIndexPath:virtualIndexPath]];
    }
    [view openedStateChanged];
    return view;
    
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


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    MFGroupDescriptor *group = [self getSectionGroupDescriptor];
    CGFloat value = [group.height floatValue];
    return value;
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
        MFDefaultViewModelCreator *vmCreator = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
        
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





#pragma mark  - Binding Form/ViewModel : évènements de binding

-(MFGroupDescriptor *) getSectionGroupDescriptor {
    return ((MFSectionDescriptor *)self.sectionDescriptor.sections[0]).orderedGroups[0];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void) setDataOnView:(id<MFFormCellProtocol>)cell withOptionalViewModel:(id<MFUIBaseViewModelProtocol>)viewModel{
    NSMutableArray *cellComponents = [NSMutableArray array];
    NSIndexPath *indexPath = cell.cellIndexPath;
    
    cellComponents = [[self.binding componentsArrayAtIndexPath:indexPath] mutableCopy];
    
    for(MFUIBaseComponent *component in cellComponents) {
        MFFieldDescriptor *componentDescriptor = (MFFieldDescriptor *)(component.selfDescriptor);
        
        id componentData = [viewModel valueForKeyPath:componentDescriptor.bindingKey];
        
        if(componentData) {
            componentData = [self applyConverterOnComponent:component forValue:componentData isFormToViewModel:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(setData:) onComponent:component withObject:componentData];
            });
        }
        else {
            MFUILogInfo(@"Binding Key \"%@\" was not found on %@",componentDescriptor.bindingKey, [self.viewModel class]);
        }
        
        //Set parameters for this component if exist
        if(componentDescriptor.parameters) {
            for(NSString *key in componentDescriptor.parameters.allKeys) {
                if([component respondsToSelector:NSSelectorFromString([self generateSetterFromProperty:key])]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [component performSelector:NSSelectorFromString([self generateSetterFromProperty:key])
                                        withObject:[componentDescriptor.parameters objectForKey:key]];
                    });
                }
            }
        }
        
    }
}

/**
 * @see MFForm2DListViewController.h
 */
-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath{
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre ppour ce composant
        MFValueChangedFilter applyFilter = [self filtersFromFormToViewModel][bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter)
            continueDispatch = applyFilter(bindingKey, [[self sectionViewModelsList].viewModels objectAtIndex:indexPath.row], self.binding);
        
        NSMutableArray *componentList = [[self.binding componentsAtIndexPath:indexPath withBindingKey:bindingKey] mutableCopy];
        if(continueDispatch && componentList) {
            for(id<MFUIComponentProtocol> component in componentList) {
                [[self viewModelAtIndexPath:indexPath] setValue:[component getData] forKeyPath:bindingKey];
            }
        }
    }
    else {
        [self releasePropertyFromMutex:bindingKey];
    }
}

/**
 * @see MFForm2DListViewController.h
 */
-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender{
    
    //Pour trouver la liste de composants associés, il faut récupérer la position de la cellule correspondant à ce ViewModel
    NSInteger section = 0;
    NSInteger row = 0;
    
    //S'il s'agit d'un ViewModel d'une section
    if([((MFUIBaseListViewModel *)self.viewModel).viewModels containsObject:viewModelSender]) {
        row = section;
        section = SECTION_INDEXPATH_IDENTIFIER;
    }
    else {
        for(id<MFBaseViewModelWithSublistProtocol> sectionViewModel in ((MFUIBaseListViewModel *)self.viewModel).viewModels) {
            if(![sectionViewModel isEqual:[NSNull null]] &&
               [sectionViewModel.subList.viewModels containsObject:viewModelSender]) {
                row = [sectionViewModel.subList.viewModels indexOfObject:viewModelSender];
                section = [((MFUIBaseListViewModel *)self.viewModel).viewModels indexOfObject:sectionViewModel];
                break;
                
            }
        }
    }
    
    // Récupération de l'indexPath concerné et de la liste de composants associés.
    NSIndexPath *componentIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    NSMutableArray *componentList = [[self.binding componentsAtIndexPath:componentIndexPath withBindingKey:bindingKey] mutableCopy];
    
    //Si la ressource n'est pas déja tenue par un autre évènement
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre ppour ce composant
        MFValueChangedFilter applyFilter = [self filtersFromViewModelToForm][bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter) {
            continueDispatch = applyFilter(bindingKey, viewModelSender, self.binding);
        }
        
        //Si la mise a jour doit être disptachée, on l'applique
        if(continueDispatch) {
            [self dispatchUpdatesOnComponentList:componentList fromViewModel:viewModelSender
                                  withBindingKey:bindingKey atIndexPath:componentIndexPath];
        }
        
        // On lâche la ressource à la fin du traitement
        [self releasePropertyFromMutex:bindingKey];
    }
    else {
        // Si on passe ici, c'est que le champ vient d'être modifié dans le viewModel suite à une modif du formulaire.
        // On peut donc maintenant appliquer la modification la méthode custom appelée quand le champ est modifié dans le modèle
        [self applyCustomValueChangedMethodForComponents:componentList atIndexPath:componentIndexPath];
        [self releasePropertyFromMutex:bindingKey];
    }
}

/**
 * @brief Met à jour un composant si nécessaire (c'est-à-dire si la nouvelle valeur est strictement différente de l'ancienne).
 * @param component Le composant à mettre à jour
 * @param newValue La nouvelle valeur à mettre dans le composant
 * @param oldValue L'ancienne valeur du composant
 */
-(void) updateComponentIfNeeded:(id<MFUIComponentProtocol>)component withNewValue:(id)newValue comparedToOldValue:(id)oldValue {
    MFNonEqual(oldValue, newValue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [component setData:newValue];
        });
    });
}

/**
 * @brief Met à jour une liste de composant en utilisant le ViewModel source des données, la bindingKey du ou des composants
 *        à mettre à jour, la liste des composants à mettre à jour et l'indexPath de la mise à jour.
 * @param componentList La Liste des composants à mettre à jour
 * @param viewModelSender Le ViewModel à l'origine de la mise à jour
 * @param bindingKey La clé de binding composant(s) <=> ViewModel
 * @param componentIndexPath L'indexPath de la mise à jour
 */
-(void) dispatchUpdatesOnComponentList:(NSArray *)componentList fromViewModel:(MFUIBaseViewModel *)viewModelSender
                        withBindingKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)componentIndexPath{
    //Si la mise a jour n'est pas bloquée par le filtre
    if(componentList) {
        for(id<MFUIComponentProtocol> component in componentList) {
            id oldValue = [component getData];
            id newValue =[viewModelSender valueForKeyPath:bindingKey];
            newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:NO];
            [self updateComponentIfNeeded:component withNewValue:newValue comparedToOldValue:oldValue];
        }
    }
    else {
        [self performSelectorForPropertyBinding:bindingKey onViewModel:viewModelSender withIndexPath:componentIndexPath];
    }
}


/**
 * @brief Cette méthode applique un traitement particulier lorsque la valeur du champ correspondant dans le ViewModel
 * à la liste des composants passée en paramètres est modifiée.
 * @param componentList Une liste de composants (définis dans les formulaires PLIST) dont on souhaite écouter les modifications
 * de valeur dans le ViewModel
 */
-(void) applyCustomValueChangedMethodForComponents:(NSArray *)componentList atIndexPath:(NSIndexPath *)indexPath{
    //Application des méthodes spécifiés pour le changement de cette valeur, s'il y en a dans le PLIST
    if(componentList) {
        for(id<MFUIComponentProtocol> component in componentList) {
            NSString *customValuechangedMethod = ((MFFieldDescriptor *)[component selfDescriptor]).vmValueChangedMethodName;
            customValuechangedMethod = [customValuechangedMethod stringByAppendingString:@"AtIndexPath:"];
            
            //Si une custom method est définie
            if(customValuechangedMethod) {
                //et qu'elle est implémentée, on l'exécute, sinon on informe l'utilisateur
                if([self respondsToSelector:NSSelectorFromString(customValuechangedMethod)]){
                    
                    // Par défaut le compilateur affiche un warning indiquant que performSelector avec un NSSelectorFromString
                    // peut causer des fuites mémoire car il ne sait pas vérifier que le sélecteur existe réellement.
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:NSSelectorFromString(customValuechangedMethod) withObject:indexPath];
                }
                else {
                    @throw([NSException exceptionWithName:@"Not Implemented" reason:
                            [NSString stringWithFormat:@"You should implement the custom value changed method %@ defined in PLIST file on %@",
                             customValuechangedMethod, self.class] userInfo:nil]);
                }
                
            }
        }
    }
}


#pragma mark  - Binding Form/ViewModel : Gestion des filtres


/**
 * @brief Cette méthode réalise les actions demandées d'après le changement de valeur d'une propriété
 * du ViewModel. D'après le nom de la propriété qui a changé, la méthode va vérifier dans son dictionnaire
 * de propriétés bindées, les composant et leur champs à modifier.
 * @param propertyBindingKey Le nom de la propriété qui a changé
 */
-(void) performSelectorForPropertyBinding:(NSString *) propertyBindingKey
                              onViewModel:(MFUIBaseViewModel *)viewModel withIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary * listeners = [self.propertiesBinding objectForKey:propertyBindingKey];
    
    //S'il y a des champs qui écoutent le changement de la propriété propertyBindingKey
    if(listeners) {
        for(NSString * componentName in [listeners allKeys]) {
            //Récupération du nom du champ qui écoute la propriété et de la propriété du champ à modifier
            
            NSString *listenerName = componentName;
            MFBindingComponentDescriptor * bindingDescriptor = listeners[componentName];
            MFFieldDescriptor * componentDescriptor = bindingDescriptor.componentDescriptor;
            NSString *property = bindingDescriptor.bindableProperty;
            // Si on a toutes les informations, on modifie la propriété récupérée sur le champs récupéré
            // avec la nouvelle valeur
            if(listenerName && property) {
                NSArray * componentList = [self.binding componentsAtIndexPath:indexPath withBindingKey:componentDescriptor.bindingKey];
                for(id<MFUIComponentProtocol> listener in componentList) {
                    NSString * selectorName = [self generateSetterFromProperty:property];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [listener performSelector:NSSelectorFromString(selectorName) withObject:[viewModel valueForKey:propertyBindingKey]];
                    });
                }
            }
        }
    }
}


#pragma mark - Initialisation des composants graphiques
/**
 * @brief Cette méthode permet d'initialiser  (graphiquement) le composant passé en paramètre
 * à partir des données du PLIST du formulaire
 * @param component Le composant à initialiser
 */
-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath{
    
    //Initialize Data
    MFFieldDescriptor * componentDescriptor = (MFFieldDescriptor *) component.selfDescriptor;
    id vmItem = [self viewModelAtIndexPath: indexPath];
    [vmItem valueForKeyPath:componentDescriptor.bindingKey];
    [component clearErrors];
    
    //Initializing each bindableProperty if defined
    for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
        NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
        NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
        
        id object = [((id<MFTypeValueProcessingProtocol>)[[NSClassFromString(processingClass) alloc] init])
                     processTreatmentOnComponent:component withViewModel:vmItem
                     forProperty:bindablePropertyName
                     fromBindableProperties:self.bindableProperties];
        
        NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
        
        if(object) {
            [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
        }
    }
}


-(void)setViewModel:(MFUIBaseListViewModel *)listViewModel {
    _viewModel.form = self;
    _viewModel = listViewModel;
    //    [self getListViewModel].viewModels = listViewModel.viewModels;
}


/**
 * @brief Cette méthode met à jour les données de la cellule selon son indexPath
 * @param cell La cellule
 */
-(void) setDataOnView:(id<MFFormCellProtocol>)cell {
    
    NSMutableArray *cellComponents = [NSMutableArray array];
    NSIndexPath *indexPath = cell.cellIndexPath;
    
    cellComponents = [[self.binding componentsArrayAtIndexPath:indexPath] mutableCopy];
    
    for(id<MFUIComponentProtocol> component in cellComponents) {
        MFFieldDescriptor *componentDescriptor = (MFFieldDescriptor *)component.selfDescriptor;
        id<MFUIBaseViewModelProtocol> itemVm = [self viewModelAtIndexPath:indexPath];
        id value = [itemVm valueForKeyPath:componentDescriptor.bindingKey];
        value = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:value isFormToViewModel:NO];
        [component performSelector:@selector(setData:) withObject:value];
    }
    
}

-(void) refresh {
    self.filterParameters = nil;
    [self reloadDataWithAnimationFromRight:NO];
}

-(void) refreshWithParameters:(NSDictionary *)parameters {
    self.filterParameters = parameters;
    [self reloadDataWithAnimationFromRight:NO];
    
}

-(MFGroupDescriptor *) getGroupDescriptor:(NSIndexPath *)indexPath {
    return ((MFSectionDescriptor *)self.formDescriptor.sections[0]).orderedGroups[0];
}

-(MFFormSectionHeaderView *) sectionView {
    
    MFFormSectionHeaderView * view = nil;
    if(self.sectionDescriptor) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:self.sectionDescriptor.uitype owner:self options:nil];
        if(topLevelObjects && topLevelObjects.count >0) {
            view = topLevelObjects[0];
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            @throw([NSException exceptionWithName:@"Missing property"
                                           reason:@"The property sectionHeaderViewNibName must be filled in StoryBoard"
                                         userInfo:nil]);
        });
    }
    return view;
}

-(MFFormDescriptor *) loadDescriptorWithName:(NSString *)descriptorName {
    MFFormDescriptor *localFormDescriptor = nil;
    if ([self.mf valueForKey:descriptorName]) {

        MFAppDelegate *mfDelegate = nil;
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        if([appDelegate isKindOfClass:[MFAppDelegate class]]){
            mfDelegate = (MFAppDelegate *) appDelegate;
        }
        
        //Récupération des formDescriptor mise en cache
        MFConfigurationHandler *registry = [_applicationContext getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
        [registry loadFormWithName:[self.mf valueForKey:descriptorName]];
        localFormDescriptor = [registry getFormDescriptorProperty:
                               [CONST_FORM_RESOURCE_PREFIX stringByAppendingString:[self.mf valueForKey:descriptorName]]];
    }
    else {
        @throw [NSException exceptionWithName:@"MissingFormDescriptorName"
                                       reason:[NSString stringWithFormat:@"The formDescriptor %@ is missing", descriptorName]
                                     userInfo:nil];
    }
    return localFormDescriptor;
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
    
    for(NSIndexPath *indexPath in self.animatedSectionsIndexPath) {
        [((MFCellAbstract *)[self.tableView cellForRowAtIndexPath:indexPath]) unregisterComponents:self];
    }
    
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
    [super reloadDataWithAnimationFromRight:fromRight];
}


-(void)unregisterAllComponents {
    [super unregisterAllComponents];
    [self.reusableSectionViews removeAllObjects];
    self.reusableSectionViews = nil;
}

-(void)doFillAction {
    
}


#pragma mark - MFBindinfFormDelegate Methods

/**
 * @brief Cette méthode enregistre dans le mapping les composants principaux de
 * la cellule
 * @param cell La cellule dont on souhaite enregisrer les composants
 */
-(NSDictionary *)registerComponentsFromCell:(id<MFFormCellProtocol>) cell {
    return [cell registerComponent:self];
}

-(MFBinding *)binding {
    return self.formBindingDelegate.binding;
}

-(NSDictionary *)filtersFromViewModelToForm {
    return self.formBindingDelegate.filtersFromViewModelToForm;
}

-(NSDictionary *)filtersFromFormToViewModel {
    return self.formBindingDelegate.filtersFromFormToViewModel;
}

-(NSDictionary *)bindableProperties {
    return self.formBindingDelegate.bindableProperties;
}

-(NSMutableDictionary *)propertiesBinding {
    return self.formBindingDelegate.propertiesBinding;
}



-(void)setBinding:(NSMutableDictionary *)mB {
    [self.formBindingDelegate setBinding:mB];
}

-(void)setFiltersFromFormToViewModel:(NSDictionary *)filters {
    [self.formBindingDelegate setFiltersFromFormToViewModel:filters];
}

-(void)setFiltersFromViewModelToForm:(NSDictionary *)filters {
    [self.formBindingDelegate setFiltersFromViewModelToForm:filters];
}

-(void)setPropertiesBinding:(NSMutableDictionary *)propertiesBinding {
    [self.formBindingDelegate setPropertiesBinding:propertiesBinding];
}

-(void)setBindableProperties:(NSDictionary *)bindableProperties {
    [self.formBindingDelegate setBindableProperties:bindableProperties];
}




-(BOOL)mutexForProperty:(NSString *)propertyName {
    return  [self.formBindingDelegate mutexForProperty:propertyName];
}

-(void)releasePropertyFromMutex:(NSString *)propertyName {
    [self.formBindingDelegate releasePropertyFromMutex:propertyName];
}

-(NSString *)bindingKeyWithIndexPathFromKey:(NSString *)key andIndexPath:(NSIndexPath *)indexPath {
    return [self.formBindingDelegate bindingKeyWithIndexPathFromKey:key andIndexPath:indexPath];
}

-(NSString *)bindingKeyFromBindingKeyWithIndexPath:(NSString *)key {
    return [self.formBindingDelegate bindingKeyFromBindingKeyWithIndexPath:key];
}

-(NSIndexPath *)indexPathFromBindingKeyWithIndexPath:(NSString *)key {
    return [self.formBindingDelegate indexPathFromBindingKeyWithIndexPath:key];
}

-(NSString *)generateSetterFromProperty:(NSString *)propertyName {
    return [self.formBindingDelegate generateSetterFromProperty:propertyName];
}

-(void)performSelector:(SEL)selector onComponent:(id<MFUIComponentProtocol>)component withObject:(id)object {
    [self.formBindingDelegate performSelector:selector onComponent:component withObject:object];
}

-(id)applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id)value isFormToViewModel:(BOOL)formToViewModel {
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel];
}

-(void)completeFiltersFromFormToViewModel:(NSDictionary *)filters {
    //Nothing to do
}

-(void)completeFiltersFromViewModelToForm:(NSDictionary *)filters {
    //Nothing to do
}

-(NSDictionary *)getFiltersFromFormToViewModel {
    return [NSDictionary dictionary];
}

-(NSDictionary *)getFiltersFromViewModelToForm {
    return [NSDictionary dictionary];
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
        
        
        //id<MFWorkspaceMasterColumnProtocol> masterColumn = (id<MFWorkspaceMasterColumnProtocol>)self;
        
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
                listViewmodel = (MFUIBaseListViewModel *) [self getViewModel];
                tempData = [listViewmodel.viewModels mutableCopy];
                [tempData removeObjectAtIndex:indexPath.row];
                listViewmodel.viewModels = tempData;
                listViewmodel.hasChanged = YES ;
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }];
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
        [self.binding clear];
        [self.propertiesBinding removeAllObjects];
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


@end

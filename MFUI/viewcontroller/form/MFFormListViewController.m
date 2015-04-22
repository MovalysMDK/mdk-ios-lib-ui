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
//  MFFormListViewController.m
//  MFUI
//
//

#import <CoreLocation/CoreLocation.h>

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreFormDescriptor.h>
#import <MFCore/MFCoreFormConfig.h>
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
#import "MFBaseBindingForm.h"
#import "MFWorkspaceViewController.h"
#import "MFAppDelegate.h"
#import "MFDeleteDetailActionParamIn.h"
#import "MFDeleteDetailActionParamOut.h"
#import "MFUIBaseListViewModel.h"
#import "MFFormViewController.h"
#import "MFLocalizedString.h"

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
@synthesize formDescriptor = _formDescriptor;
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
    
    if (self.mf.formDescriptorName) {

        MFAppDelegate *mfDelegate = nil;
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        if([appDelegate isKindOfClass:[MFAppDelegate class]]){
            mfDelegate = (MFAppDelegate *) appDelegate;
        }
        // Chameleon support for framework style system management.
        
        
        //Récupération des formDescriptor mise en cache
        MFConfigurationHandler *registry = [_applicationContext getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
        MFFormDescriptor *localFormDescriptor = [registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:self.mf.formDescriptorName]];
        
        self.formDescriptor = localFormDescriptor;
        
        [self setupBarItems];
        
    }
    else {
        MFUILogError(@"mf.formDescriptorName is missing");
        @throw [NSException exceptionWithName:@"MissingFormDescriptorName" reason:@"The form descriptor name is missing" userInfo:nil];
    }
    
    // fix separator display at the bottom of the tableview
    UIView *f = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    f.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:f];
}


- (void)dealloc
{
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    self.formDescriptor = nil;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Récupération de la cellule créée par le BaseFormController
    id<MFFormCellProtocol> formCell = (id<MFFormCellProtocol>)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ( self.deleteAction != nil && self.longPressToDelete ) {
        UILongPressGestureRecognizer *longGestureRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCell:)];
        [(UITableViewCell *)formCell addGestureRecognizer:longGestureRecognizer];
    }
    
    //Mise à jour des données des composants de la cellule
    [self setDataOnView:formCell];
    return (UITableViewCell *)formCell;
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




#pragma mark  - Binding Form/ViewModel : évènements de binding

/**
 * @see MFFormListViewController.h
 */
-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath
{
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre ppour ce composant
        MFValueChangedFilter applyFilter = [[self filtersFromFormToViewModel] objectForKey:bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter)
            continueDispatch = applyFilter(bindingKey, [((MFUIBaseListViewModel *)[self getViewModel]).viewModels objectAtIndex:indexPath.row], self.binding);
        
        //Si la mise a jour n'est pas bloquée par le filtre
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
 * @see MFFormListViewController.h
 */
-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender
{
    //Récupération de la liste des composants associé à ce keyPath
    NSIndexPath *componentIndexPath = [NSIndexPath indexPathForRow:[((MFUIBaseListViewModel *)[self getViewModel]).viewModels indexOfObject:viewModelSender] inSection:0];
    
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



/**
 * @brief Cette méthode applique un traitement particulier lorsque la valeur du champ correspondant dans le ViewModel
 * à la liste des composants passée en paramètres est modifiée.
 * @param componentList Une liste de composants (définis dans les formulaires PLIST) dont on souhaite écouter les modifications
 * de valeur dans le ViewModel
 */
-(void) applyCustomValueChangedMethodForComponents:(NSArray *)componentList atIndexPath:(NSIndexPath *)indexPath
{
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
                    @throw([NSException exceptionWithName:@"Not Implemented" reason:[NSString stringWithFormat:@"You should implement the custom value changed method %@ defined in PLIST file on %@", customValuechangedMethod, self.class] userInfo:nil]);
                }
                
            }
        }
    }
}

/**
 * @brief Cette méthode réalise les actions demandées d'après le changement de valeur d'une propriété
 * du ViewModel. D'après le nom de la propriété qui a changé, la méthode va vérifier dans son dictionnaire
 * de propriétés bindées, les composant et leur champs à modifier.
 * @param propertyBindingKey Le nom de la propriété qui a changé
 */
-(void) performSelectorForPropertyBinding:(NSString *) propertyBindingKey onViewModel:(MFUIBaseViewModel *)viewModel withIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * listeners = [self.propertiesBinding objectForKey:propertyBindingKey];
    
    //S'il y a des champs qui écoutent le changement de la propriété propertyBindingKey
    if(listeners) {
        for(NSString * componentName in [listeners allKeys]) {
            //Récupération du nom du champ qui écoute la propriété et de la propriété du champ à modifier
            
            NSString *listenerName = componentName;
            MFBindingComponentDescriptor * bindingDescriptor = [listeners objectForKey:componentName];
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



#pragma mark - ViewModels management

-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    id<MFUIBaseViewModelProtocol> vmItem = nil;
    MFUIBaseListViewModel *listVm = ((MFUIBaseListViewModel *)[self getViewModel]);
    
    
    if ( [listVm.viewModels count]>indexPath.row) {
        vmItem = [listVm.viewModels objectAtIndex:indexPath.row];
        if ( [[NSNull null] isEqual: vmItem]) {
            vmItem = nil ;
        }
    }
    
    
    if (vmItem == nil ) {
        
        id vmCreator = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
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
    return (MFUIBaseListViewModel *)self.viewModel;
}


-(void)setViewModel:(MFUIBaseListViewModel *)listViewModel
{
    _viewModel.form = self;
    _viewModel = listViewModel;
    ((MFUIBaseListViewModel *)[self getViewModel]).viewModels = listViewModel.viewModels;
}



#pragma mark - Gestion des composants graphiques
/**
 * @brief Cette méthode permet d'initialiser  (graphiquement) le composant passé en paramètre
 * à partir des données du PLIST du formulaire
 * @param component Le composant à initialiser
 */
-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath
{
    
    //Initialize Data
    MFFieldDescriptor * componentDescriptor = (MFFieldDescriptor *) component.selfDescriptor;
    
    id vmItem = [self viewModelAtIndexPath: indexPath];
    [vmItem valueForKeyPath:componentDescriptor.bindingKey];
    [component clearErrors];
    
    //Initializing each bindableProperty if defined
    for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
        NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
        NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
        
        id object = [((id<MFTypeValueProcessingProtocol>)[[NSClassFromString(processingClass) alloc] init]) processTreatmentOnComponent:component withViewModel:vmItem forProperty:bindablePropertyName fromBindableProperties:self.bindableProperties];
        
        NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
        
        if(object) {
            [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
        }
    }
}



/**
 * @brief Cette méthode met à jour les données de la cellule selon son indexPath
 * @param cell La cellule
 */
-(void) setDataOnView:(id<MFFormCellProtocol>)cell
{
    
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


-(void) refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if(self.searchDelegate) {
            [self.searchDelegate actualizePrompt];
        }
    });
    
}

-(void)unregisterAllComponents
{
    [super unregisterAllComponents];
    [((MFUIBaseListViewModel *)self.viewModel) clear];
    
}


-(MFGroupDescriptor *) getGroupDescriptor:(NSIndexPath *)indexPath
{
    return ((MFSectionDescriptor *)self.formDescriptor.sections[0]).orderedGroups[0];
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
                
                //        case NSFetchedResultsChangeInsert:
                //            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                //            break;
                
            case NSFetchedResultsChangeDelete:
                
                listViewmodel = (MFUIBaseListViewModel *) [self getViewModel];
                tempData = [listViewmodel.viewModels mutableCopy];
                [tempData removeObjectAtIndex:indexPath.row];
                listViewmodel.viewModels = tempData;
                listViewmodel.hasChanged = YES ;
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
                //        case NSFetchedResultsChangeUpdate:
                //            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                //            break;
                
                //        case NSFetchedResultsChangeMove:
                //          [tableView deleteRowsAtIndexPaths:[NSArray
                //                                               arrayWithObject:indexPath] //withRowAnimation:UITableViewRowAnimationFade];
                //            [tableView insertRowsAtIndexPaths:[NSArray
                //                                             arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                //        break;
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
        [self.binding clear];
        [self.propertiesBinding removeAllObjects];
        [self.tableView reloadData];
    }];
}


#pragma mark - Unimplemented methods
-(NSDictionary *)getFiltersFromFormToViewModel
{
    return [NSDictionary dictionary];
}

-(NSDictionary *)getFiltersFromViewModelToForm
{
    return [NSDictionary dictionary];
}

-(void)completeFiltersFromFormToViewModel:(NSDictionary *)filters
{
    //The method is declared to avoid warnings of unimplemented methods.
    //The method coulb be implemented in child classes.
}

-(void)completeFiltersFromViewModelToForm:(NSDictionary *)filters
{
    //The method is declared to avoid warnings of unimplemented methods.
    //The method coulb be implemented in child classes.
}

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

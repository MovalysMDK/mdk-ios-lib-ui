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
//  MFFixedListDataDelegate.m
//  MFUI
//
//

//Interface import
#import "MFFixedListDataDelegate.h"

//MFCore imports
#import <MFCore/MFCoreFormConfig.h>
#import <MFCore/MFCoreBean.h>

//FixedList import
#import "MFFixedList.h"
#import "MFFormDetailViewController.h"
#import "MFPhotoDetailViewController.h"

//MFCell import
#import "MFCellAbstract.h"

//Utils
#import "MFLocalizedString.h"
#import "MFHelperIndexPath.h"
#import "MFTypeValueProcessingProtocol.h"
#import "MFException.h"
#import "MFUILog.h"


//Binding
#import "MFBaseBindingForm.h"
#import "MFKeyNotFound.h"
#import "MFUIBaseListViewModel.h"

//Forms
#import "MFFormWithDetailViewControllerProtocol.h"
#import "MFFormBaseViewController.h"

//UI
#import "MBProgressHUD.h"

//FIXME : A supprimer ?
const static int TABLEVIEW_RESIZE_OFFSET = 0;


@interface MFFixedListDataDelegate ()



/**
 * @brief The view that is shown during loading
 */
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation MFFixedListDataDelegate
@synthesize viewModel = _viewModel;
@synthesize reusableBindingViews = _reusableBindingViews;
@synthesize formDescriptor = _formDescriptor;
@synthesize formValidation = _formValidation;


#pragma mark - Initialization
-(instancetype)initWithFixedList:(MFFixedList *) fixedList {
    self = [super init];
    if(self) {
        self.fixedList = fixedList;
        [self initialize];
        
    }
    return self;
}

-(void) initialize {
    self.formValidation = [[MFFormValidationDelegate alloc] initWithFormController:self];
    self.formBindingDelegate = [[MFBaseBindingForm alloc] initWithParent:self];
    
}




#pragma mark - Initialisation des composants graphiques
/**
 * @brief Cette méthode permet d'initialiser  (graphiquement) le composant passé en paramètre
 * à partir des données du PLIST du formulaire
 * @param component Le composant à initialiser
 */
-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath{
    
    [(MFUIBaseComponent *)component setInInitMode:YES];
    
    MFFieldDescriptor * componentDescriptor = (MFFieldDescriptor *) component.selfDescriptor;
    NSString *fullBindingKey  = [self bindingKeyWithIndexPathFromKey:componentDescriptor.bindingKey andIndexPath:indexPath];
    id valueForKeyPath ;
    
    
    
    MFUIBaseListViewModel *listViewModel =[self.fixedList getData];
    
    
    // first check if values present in invalid values
    if ([self.formValidation hasInvalidValueForFullBindingKey:fullBindingKey] ) {
        valueForKeyPath = [self.formValidation getInvalidValueForFullBindingKey:fullBindingKey];
        [component addErrors: [self.formValidation getErrorsForFullBindingKey:fullBindingKey]];
    }
    else {
        // if not found, read value from viewmodel (return MFKeyNotFound if binding key not found)
        valueForKeyPath = [[listViewModel.viewModels objectAtIndex:indexPath.row]  valueForKeyPath:componentDescriptor.bindingKey];
        [component clearErrors:NO];
    }
    
    if( valueForKeyPath != [MFKeyNotFound keyNotFound]) {
        valueForKeyPath = [self applyConverterOnComponent:component forValue:valueForKeyPath isFormToViewModel:NO withViewModel:[listViewModel.viewModels objectAtIndex:indexPath.row]];
        [self performSelector:@selector(setData:) onComponent:component withObject:valueForKeyPath];
    }
    else {
        //MFCoreLogInfo(@"Binding Key \"%@\" was not found on %@",componentDescriptor.bindingKey, [self.viewModel class]);
        // In case of error, component must be reinitialized (because views are reused and may contain an old value)
        [self performSelector:@selector(setData:) onComponent:component withObject:nil];
    }
    
    // Show deferred errors on component (= errors from previous validation and component was not visible).
    [self.formValidation addDeferredErrorsOnComponent:component withFullBindingKey:fullBindingKey];
    
    //Initializing each bindableProperty if defined
    for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
        NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
        NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
        
        id object = [((id<MFTypeValueProcessingProtocol>)[[NSClassFromString(processingClass) alloc] init]) processTreatmentOnComponent:component withViewModel:[listViewModel.viewModels objectAtIndex:indexPath.row] forProperty:bindablePropertyName fromBindableProperties:self.bindableProperties];
        
        NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
        
        if(object) {
            [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
        }
    }
    
    //If the Fixed List is in "not editable" mode , each field of each cell should be non-editable.
    if([self.fixedList.editable isEqualToNumber:@0]) {
        [component setEditable:@0];
    }
    
    [(MFUIBaseComponent *)component setInInitMode:NO];
}

/**
 * @brief Cette méthode permet de redessiner cette cellule pour l'adapter à la taille de la liste qu'elle contient
 * On calcule la taille totale du contenu de la liste éditable (contentSize), et on affecte au controller qui tient cette cellule
 * la nouvelle taille calculée de cette cellule. On redessine cette cellule et on rafraîchit la tableView qui contient cette cellule
 * pour obtenir la bonne taille
 * @param tableView La liste éditable dont on veut récupérer la taille du contenu
 */
-(void) redrawSelfWithTableView:(UITableView *)tableView {
    
    if(!self.hasBeenReload && self.fixedList.cellContainer) {
        
        //On récupère la taille actuelle de la liste interne de l'éditableList, et la taille de la cellule
        CGRect fixedListViewframe = self.fixedList.frame;
        fixedListViewframe.size.width = tableView.frame.size.width;
        
        CGRect cellFrame = ((MFCellAbstract *)self.fixedList.cellContainer).frame;
        
        //On enlève à la taille de la cellule la hauteur de la taille actuelle de la liste interne (cela afin
        // d'avoir la taille de la cellule sans la liste).
        cellFrame.size.height = cellFrame.size.height - fixedListViewframe.size.height;
        
        //On affecte la valeur de la taille totale du contenu à la taille de la liste interne.
        // Ainsi la TableView a deja la bonne taille, tous les cellules de la liste interne seront forcément chargées et
        // il n'y aura pas de scroll
        fixedListViewframe.size.height = self.fixedList.tableView.contentSize.height + [self sizeForCustomButtons].height;
        self.fixedList.frame = fixedListViewframe;
        self.fixedList.contentSize = CGSizeMake(fixedListViewframe.size.width, fixedListViewframe.size.height);
        
        //On calcule alors la taille de cette cellule (self, cellule du FormViewController) en y ajoutant la taille
        // de la liste interne précédement calculée, et on stocke la taille de self dans le controller parent.
        // Ce dernier va être rechargé (tableView reloadData) et va ainsi attribuer la bonne hauteur à cette cellule.
        int finalHeight = cellFrame.size.height + fixedListViewframe.size.height - TABLEVIEW_RESIZE_OFFSET;
        [self.formController setCellHeight:finalHeight atIndexPath:((MFCellAbstract *)self.fixedList.cellContainer).cellIndexPath];
        
        //Après les modification faites, on recharge la liste interne (fixedList) de cette cellule et on indique
        //au dataSource de cette liste interne (self) que la liste interne a déja été rechargée, afin de ne pas boucler.
        self.hasBeenReload = YES;
        
    }
    else {
        int newHeight = self.fixedList.tableView.contentSize.height + [self sizeForCustomButtons].height;
        [self.fixedList changeDynamicHeight:newHeight];
    }
    [self.fixedList updateConstraintsIfNeeded];
    if(self.fixedList.cellContainer) {
        [((MFCellAbstract *)self.fixedList.cellContainer) updateConstraintsIfNeeded];
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
/**
 * @brief Cette méthode met à jour les données de la cellule selon son indexPath
 * @param cell La cellule
 */
-(void) setDataOnView:(id<MFFormCellProtocol>)cell {
    
    NSMutableArray *cellComponents = [NSMutableArray array];
    NSIndexPath *indexPath = cell.cellIndexPath;
    
    cellComponents = [[self.binding componentsArrayAtIndexPath:indexPath] mutableCopy];
    
    
    //for(NSArray *componentList in cellComponents) {
    for(MFUIBaseComponent *component in cellComponents) {
        MFFieldDescriptor *componentDescriptor = (MFFieldDescriptor *)component.selfDescriptor;
        
        
        MFUIBaseViewModel *listViewModelItem = [((MFUIBaseListViewModel *)[self.fixedList getData]).viewModels objectAtIndex:indexPath.row];
        id componentData = [listViewModelItem valueForKeyPath:componentDescriptor.bindingKey];
        
        if(componentData) {
            componentData = [self applyConverterOnComponent:component forValue:componentData isFormToViewModel:NO withViewModel:listViewModelItem];
            
            [self performSelector:@selector(setData:) onComponent:component withObject:componentData];
        }
        else {
            MFCoreLogInfo(@"Binding Key \"%@\" was not found on %@",componentDescriptor.bindingKey, [self.viewModel class]);
        }
        //Set particular Datas for this component if exist
        if(componentDescriptor.parameters) {
            for(NSString *key in componentDescriptor.parameters.allKeys) {
                if([component respondsToSelector:NSSelectorFromString([self generateSetterFromProperty:key])]) {
                    [component performSelector:NSSelectorFromString([self generateSetterFromProperty:key]) withObject:[componentDescriptor.parameters objectForKey:key]];
                }
            }
        }
    }
    //}
    
}

#pragma mark - UITableViewDataSource & Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int value  = 1;
    return value;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // The fixedList should not return a number of rows by section superior to 15-20.
    // First, if the number of rows by section is too high, it could have bad performances
    // The main reason of this limit is that the parent cell of the fixedList component
    // should not be higher than 2009 (following Apple documentation about the UItableView).
    NSInteger value  = (self.viewModel && ((MFUIBaseListViewModel *)self.viewModel).viewModels) ? ((MFUIBaseListViewModel *)self.viewModel).viewModels .count: 0;
    return value;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *stringIndexPath = [NSString stringWithFormat:@"row : %i, section : %i", indexPath.row, indexPath.section];
    //Récupération des dexcripteurs
    MFConfigurationHandler *registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    MFFormDescriptor *localFormDescriptor = [registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:self.mf.formDescriptorName]];
    self.formDescriptor = localFormDescriptor;
    MFSectionDescriptor *currentSection = self.formDescriptor.sections[indexPath.section];
    MFGroupDescriptor *currentGd = nil;
    if([[self viewModel] isKindOfClass:[MFUIBaseListViewModel class]]) {
        currentGd = currentSection.orderedGroups[0];
    }
    
    //Création ou récupération de la cellule
    [tableView registerNib:[UINib nibWithNibName:currentGd.uitype bundle:nil] forCellReuseIdentifier:currentGd.uitype];
    MFCellAbstract *cell = [tableView dequeueReusableCellWithIdentifier:currentGd.uitype];
    id<MFFormCellProtocol> formCell = (id <MFFormCellProtocol>)cell;
    if(![self.reusableBindingViews containsObject:formCell]) {
        [self.reusableBindingViews addObject:formCell];
    }
    else {
        [formCell unregisterComponents:self];
    }
    
    // We check if it's a framework cell
    if ([cell conformsToProtocol:@protocol(MFFormCellProtocol)]) {
        
        //Reset et mise à jour des données de la cellule.
        id<MFFormCellProtocol> formCell = (id<MFFormCellProtocol>)cell;
        ((MFCellAbstract *)formCell).formController = self;
        [((MFCellAbstract *)formCell) refreshComponents];
        [formCell setCellIndexPath:indexPath];
        
        [formCell configureByGroupDescriptor:currentGd andFormDescriptor:self.formDescriptor];
        
        //Enregistrement des composants graphiques du formulaire pour les cellules visibles
        NSDictionary *newRegisteredComponents = [self registerComponentsFromCell:formCell];
        for(NSString *key in [newRegisteredComponents allKeys]) {
            //Récupération de la liste des composants associé à ce keyPath
            NSMutableArray *componentList = [[self.binding componentsAtIndexPath:indexPath withBindingKey:key] mutableCopy];
            
            if(componentList) {
                for(MFUIBaseComponent *component in componentList) {
                    //Initialisation des composants
                    [self initComponent:component atIndexPath:indexPath];
                }
            }
        }
        [self setDataOnView:formCell];
    }
    
    cell.selectionStyle =
    (self.fixedList.mf.editMode == MFFixedListEditModePopup && self.fixedList.mf.canEditItem) ? UITableViewCellSelectionStyleBlue :
    UITableViewCellSelectionStyleNone;
    
    if(self.fixedList.editMode == MFFixedListEditModePopup && self.fixedList.mf.canEditItem) {
        
        cell.accessoryType = [cell accessoryType];
        cell.editingAccessoryType = [cell accessoryType];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.fixedList.cellContainer) {
            [((MFCellAbstract *)self.fixedList.cellContainer) updateConstraints];
        }
        else {
            [self redrawSelfWithTableView:tableView];
        }
    });
    [cell cellIsConfigured];
    return cell;
}

/**
 * @brief Indique que cette cellule est éditable
 */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.fixedList.mf.canDeleteItem;
}


/**
 * @brief Indique que cette cellule peut être déplacée
 */
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // CATransaction permet d'exécuter un black après l'animation de la tableView
    [CATransaction begin];
    [tableView beginUpdates];
    
    // Block à exécuter après l'animation
    
    [CATransaction setCompletionBlock: ^{
        [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.05];
        
    }];
    
    
    // Test de la nature de l'édition : suppression, insertion, ou modification de la position de la cellule
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        self.HUD = [MBProgressHUD showHUDAddedTo:((UIViewController *)self.formController).view animated:YES];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = MFLocalizedStringFromKey(@"waiting.view.refreshing.list");
        // Suppression
        MFUIBaseListViewModel *viewModel = ((MFUIBaseListViewModel *)[self.fixedList getData]);
        NSMutableArray *tempData = [viewModel.viewModels mutableCopy];
        [tempData removeObjectAtIndex:indexPath.row];
        viewModel.viewModels = tempData;
        viewModel.hasChanged = YES ;
        [self.fixedList setDataAfterEdition:viewModel];
        self.hasBeenReload = NO;    //Permet de recharger les données lors de l'appel à reloadData dans le block
        
        [((MFCellAbstract *)[tableView cellForRowAtIndexPath:indexPath]) unregisterComponents:self];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSString *deleteItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).deleteItemListener;
        [self performSelectorFromMethodName:deleteItemListenerName onActionAtIndexPath:indexPath];
        
        
    }
    [tableView endUpdates];
    
    // Exécution du block
    [CATransaction commit];
    [self.fixedList.tableView reloadData];
    [self redrawSelfWithTableView:self.fixedList.tableView];
    [self.HUD hide:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.fixedList.mf.canEditItem)
        return;
    
    if(self.fixedList.mf.editMode == MFFixedListEditModePopup) {
        
        
        
        // Getting the parent controller of this form which will push the detail controller in its navigationController.
        id<MFBindingFormDelegate> parentController = self.formController;
        
        // Getting the detailController to display
        MFFormDetailViewController *nextController = [self detailController];
        [nextController setEditable:self.fixedList.editable];
        [nextController setParentFormController:self];
        [nextController setIndexPath:indexPath];
        MFUIBaseViewModel *tempViewModel = [[((MFUIBaseListViewModel *)self.viewModel).viewModels objectAtIndex:indexPath.row] copy];
        tempViewModel.parentViewModel = self.viewModel;
        //Displaying the detail controller
        [((UIViewController *)parentController).navigationController pushViewController:nextController animated:YES];
        [nextController setOriginalViewModel:tempViewModel];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Buttons

-(CGFloat)marginForCustomButtons {
    return 5;
}

-(CGSize)sizeForCustomButtons {
    UIButton *referenceButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    return CGSizeMake(referenceButton.frame.size.width,referenceButton.frame.size.height);
}


-(NSArray *)customButtonsForFixedList {
    [MFException throwNotImplementedExceptionOfMethodName:@"customButtonsForFixedList" inClass:[self class] andUserInfo:nil];
    return @[];
}


#pragma mark - FixedList Events

-(void) updateChangesFromDetailControllerOnCellAtIndexPath:(NSIndexPath *)indexPath withViewModel:(MFUIBaseViewModel *)viewModel {
    NSMutableArray * tempViewModels = ((MFUIBaseListViewModel *)self.viewModel).viewModels ;
    MFUIBaseViewModel *oldViewModel = [tempViewModels objectAtIndex:indexPath.row];
    viewModel.parentViewModel = oldViewModel.parentViewModel;
    [tempViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
    ((MFUIBaseListViewModel *)self.viewModel).viewModels = tempViewModels;
    tempViewModels = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fixedList.tableView reloadData];
    });
    
    for(NSString *bindingKey in [viewModel getBindedProperties]) {
        [self.formBindingDelegate mutexForProperty:bindingKey];
        [self dispatchEventOnViewModelPropertyValueChangedWithKey:bindingKey sender:viewModel];
    }
    [self callEditItemListenerAtIndexPath:indexPath];
}

-(void) callEditItemListenerAtIndexPath:(NSIndexPath *)indexPath {
    NSString *customEditItemListener = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).editItemListener;
    customEditItemListener = [customEditItemListener stringByAppendingString:@"AtIndexPath:"];
    if(customEditItemListener) {
        if( [self respondsToSelector:NSSelectorFromString(customEditItemListener)]) {
            [self performSelector:NSSelectorFromString(customEditItemListener) withObject:indexPath];
        }
    }
}

-(void)addItemOnFixedList{
    [self addItemOnFixedList:YES];
}

-(void)addItemOnFixedList:(BOOL) reload{
    
        if (reload) {
            self.HUD = [MBProgressHUD showHUDAddedTo:((UIViewController *)self.formController).view animated:YES];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = MFLocalizedStringFromKey(@"waiting.view.refreshing.list");
        }
        
        //Retrieving ListviewModel and adding it an new item
        MFUIBaseListViewModel *viewModel = [self.fixedList getData];
        NSMutableArray *data = viewModel.viewModels;
        MFUIBaseViewModel *newObject = [[NSClassFromString(self.fixedList.itemClassName) alloc] init];
        newObject.parentViewModel = viewModel;
        //TODO - PROVISOIRE.
        //Cela doit faire l'objet d'une vraie correction
        //Gestion de la mise à -1 de l'indentifiant du view model (valeur par défaut) au lieu de nil (empêche la sauvegarde
        //lors de l'ajout d'un item)
        [newObject updateFromIdentifiable:nil];
        [data addObject:newObject];
        viewModel.viewModels = data;
        viewModel.hasChanged = YES ;
        
        self.hasBeenReload = NO;
        
        
        if (reload) {
            [self.fixedList setData:viewModel];
        } else {
            [self.fixedList setDataAfterEdition:viewModel];
        }
        
        //Perform an action if exists
        NSString *addItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).addItemListener;
        [self performSelectorFromMethodName:addItemListenerName onActionAtIndexPath:nil];
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self redrawSelfWithTableView:self.fixedList.tableView];
                [self.HUD hide:YES];
            });
        }
    
    if([self.fixedList isPhotoFixedList]) {
        id<MFBindingFormDelegate> parentController = self.fixedList.form;
        //On ajoute l'élément à la liste
        //On créé le contrôleur à afficher
        MFPhotoDetailViewController *managePhotoViewController = [[UIStoryboard storyboardWithName:DEFAUT_PHOTO_STORYBOARD_NAME bundle:nil] instantiateViewControllerWithIdentifier:DEFAUT_PHOTO_MANAGER_CONTROLLER_NAME];
        
        //Récupération du view model créé lors de l'ajout de l'élément.
        //Il correspond au dernier élément ajouté au tableau des view models de la liste
        MFUIBaseListViewModel *viewModel = [self.fixedList getData];
        NSMutableArray *data = viewModel.viewModels;
        MFUIBaseViewModel *baseViewModel = (MFUIBaseViewModel *)[data objectAtIndex:data.count-1];
        
        //On instancie un nouveau view model de photo que l'on passe au view model de la cellule
        MFPhotoViewModel *newPhotoViewModel = [[MFPhotoViewModel alloc] init];
        [baseViewModel setValue:newPhotoViewModel forKeyPath:@"photo"];
        
        //Le contrôleur récupère la liste, la cellule et le view model créé.
        managePhotoViewController.fixedList = self.fixedList;
        managePhotoViewController.cellPhotoFixedList = self;
        managePhotoViewController.photoViewModel = newPhotoViewModel;
        
        //On affiche la vue
        
        [((UIViewController *)parentController).navigationController pushViewController:managePhotoViewController animated:YES];
    }
}

#pragma mark - FixedList forwarding
-(MFUIBaseListViewModel *) viewModel {
    return [self.fixedList getData];
}

-(MFFormExtend *) mf {
    return self.fixedList.mf;
}

-(id<MFBindingFormDelegate>) formController {
    return (id<MFBindingFormDelegate>)_fixedList.form;
}

#pragma mark - FixedList utils
-(NSString *)itemListViewModelName {
    [MFException throwNotImplementedExceptionOfMethodName:@"itemListViewModelName" inClass:[self class] andUserInfo:nil];
    return @"";
}

-(void) setContent{
    [self.fixedList setItemClassName:[self itemListViewModelName]];
    if(self.fixedList.editMode == MFFixedListEditModePopup) {
        self.fixedList.allowsSelectionDuringEditing = YES;
    }
    self.viewModel = [self.fixedList getData];
    if(self.viewModel)
    {
        self.viewModel.form = self;
    }
    
    MFConfigurationHandler *registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    [registry loadFormWithName:self.mf.formDescriptorName];
    
    self.fixedList.tableView.rowHeight = self.fixedList.mf.rowHeight;
}

-(void) performSelectorFromMethodName:(NSString *)selectorName onActionAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath) {
        selectorName = [selectorName stringByAppendingString:@"AtIndexPath:"];
    }
    if(selectorName) {
        if([self respondsToSelector:NSSelectorFromString(selectorName)]) {
            [self performSelector:NSSelectorFromString(selectorName) withObject:indexPath];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @throw([NSException exceptionWithName:@"Unimplemented method" reason:[NSString stringWithFormat:@"You must implement the method %@ in the class %@", selectorName, [self class]] userInfo:nil]);
            });
        }
    }
    
}

-(MFFormDetailViewController *)detailController {
    MFCoreLogError(@"MFFixedListDataDelegate : %@",[MFException getNotImplementedExceptionOfMethodName:@"detailController" inClass:self.class andUserInfo:nil]);
    return nil;
}

/**
 * @brief Cette méthode enregistre dans le mapping les composants principaux de
 * la cellule
 * @param cell La cellule dont on souhaite enregisrer les composants
 */
-(NSDictionary *)registerComponentsFromCell:(id<MFFormCellProtocol>) cell {
    return [cell registerComponent:self];
}





#pragma mark - FormController utils

-(MFUIBaseListViewModel *)getViewModel {
    return [self viewModel];
}

-(NSDictionary *)getFiltersFromFormToViewModel {
    //Should be implemented in child classes if necessary
    return [NSDictionary dictionary];
}

-(NSDictionary *)getFiltersFromViewModelToForm {
    //Should be implemented in child classes if necessary
    return [NSDictionary dictionary];
}




#pragma mark - Binding events

/**
 * @see MFFormListViewController.h
 */
-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender{
    //Récupération de la liste des composants associé à ce keyPath
    NSIndexPath *componentIndexPath = [NSIndexPath indexPathForRow:[((MFUIBaseListViewModel *)[self viewModel]).viewModels indexOfObject:viewModelSender] inSection:0];
    NSLog(@"IndexPath : section :%ld, row : %ld", (long)componentIndexPath.section, (long)componentIndexPath.row);
    
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
                    newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:NO withViewModel:viewModelSender];
                    MFNonEqual(oldValue, newValue, ^{
                        [[MFApplication getInstance] execSyncInMainQueue:^{
                            [component setData:newValue];
                        }];
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
 * @see MFFormListViewController.h
 */
-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath{
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre ppour ce composant
        MFValueChangedFilter applyFilter = [[self filtersFromFormToViewModel] objectForKey:bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter)
            continueDispatch = applyFilter(bindingKey, [((MFUIBaseListViewModel *)[self viewModel]).viewModels objectAtIndex:indexPath.row], self.binding);
        
        
        NSString *fullBindingKey  = [bindingKey stringByAppendingFormat:@"__%@",[MFHelperIndexPath toString:indexPath]];
        NSMutableArray *componentList = [[self.binding componentsAtIndexPath:indexPath withBindingKey:bindingKey] mutableCopy];
        continueDispatch = continueDispatch && (((MFUIBaseListViewModel *)[self viewModel]).viewModels.count > indexPath.row);
        if(continueDispatch && componentList) {
            for(id<MFUIComponentProtocol> component in componentList) {
                MFUIBaseListViewModel *listVm = [self viewModel];
                MFUIBaseViewModel *vmForRow = [listVm.viewModels objectAtIndex:indexPath.row];
                if ( ![[vmForRow valueForKeyPath:bindingKey] isEqual:[MFKeyNotFound keyNotFound]]) {
                    id newValue = [component getData];
                    if ( [self.formValidation validateNewValue:newValue onComponent:component withFullBindingKey:fullBindingKey]) {
                        newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:YES withViewModel:vmForRow];
                        [vmForRow setValue:newValue forKeyPath:bindingKey];
                    }
                }
            }
        }
        [self releasePropertyFromMutex:bindingKey];
    }
    else {
        [self releasePropertyFromMutex:bindingKey];
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
                    @throw([NSException exceptionWithName:@"Not Implemented" reason:[NSString stringWithFormat:@"You should implement the custom value changed method %@ defined in PLIST file on Viewcontroller %@", customValuechangedMethod, self] userInfo:nil]);
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
-(void) performSelectorForPropertyBinding:(NSString *) propertyBindingKey onViewModel:(MFUIBaseViewModel *)viewModel withIndexPath:(NSIndexPath *)indexPath{
    
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



#pragma mark - Forwarding FormBinding delegate - FormBinding protocol
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

-(void)setViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    self.formBindingDelegate.viewModel = viewModel;
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

-(void)unregisterAllComponents {
    return [self.formBindingDelegate unregisterAllComponents];
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

-(id)applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel withViewModel:viewModel];
}

-(void) setActiveField:(UIControl *)component {
    ((MFBaseBindingForm *)self.formBindingDelegate).activeField = (UIControl *)component;
}


@end

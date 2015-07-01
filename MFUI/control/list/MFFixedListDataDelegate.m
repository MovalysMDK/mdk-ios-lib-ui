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


//Interface import
#import "MFFixedListDataDelegate.h"

//MFCore imports
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreI18n.h>

//UI
#import <MBProgressHUD/MBProgressHUD.h>


//FixedList import
#import "MFFixedList.h"
#import "MFFormDetailViewController.h"
#import "MFPhotoDetailViewController.h"

//MFCell import
#import "MFCellAbstract.h"

//Utils
#import "MFHelperIndexPath.h"
#import "MFTypeValueProcessingProtocol.h"
#import "MFUILog.h"


//Binding
#import "MFUIBaseListViewModel.h"

//Forms
#import "MFFormWithDetailViewControllerProtocol.h"
#import "MFFormBaseViewController.h"


#import "MFAbstractComponentWrapper.h"
#import "MFObjectWithBindingProtocol.h"

//FIXME : A supprimer ?
const static int TABLEVIEW_SEPARATOR_HEIGHT = 1;


@interface MFFixedListDataDelegate ()



/**
 * @brief The view that is shown during loading
 */
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation MFFixedListDataDelegate
@synthesize viewModel = _viewModel;
@synthesize formValidation = _formValidation;
@synthesize bindingDelegate = _bindingDelegate;



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
    [self initializeBinding];
    [self initializeModel];
}




#pragma mark - Initialisation des composants graphiques

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
    
    if(!self.bindingDelegate.structure) {
        return [[UITableViewCell alloc] init];
    }
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    [tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    bindingData.cellIndexPath = indexPath;
    [cell bindCellFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData atIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.fixedList.cellContainer) {
            [((MFCellAbstract *)self.fixedList.cellContainer) updateConstraints];
        }
    });
    
    if([cell isKindOfClass:[MFCellAbstract class]]) {
        [(MFCellAbstract *)cell cellIsConfigured];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    return [bindingData.cellHeight floatValue];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    if(bindingData) {
        [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingData generatedBindingKey]];
    }
}


-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
    
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
    return NO;
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
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //PROTODO
        //        NSString *deleteItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).deleteItemListener;
        //        [self performSelectorFromMethodName:deleteItemListenerName onActionAtIndexPath:indexPath];
        
        
    }
    [tableView endUpdates];
    
    // Exécution du block
    [CATransaction commit];
    [self.fixedList.tableView reloadData];
    [self computeCellHeightAndDispatchToFormController];
    
    [self.HUD hide:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.fixedList.mf.canEditItem)
        return;
    
    if(self.fixedList.mf.editMode == MFFixedListEditModePopup) {
        //PROTODO : MF ?
        
        
        // Getting the parent controller of this form which will push the detail controller in its navigationController.
        id<MFCommonFormProtocol> parentController = self.formController;
        
        // Getting the detailController to display
        MFFormDetailViewController *nextController = [self detailController];
        [nextController setEditable:self.fixedList.editable];
        [nextController setParentFormController:self];
        [nextController setIndexPath:indexPath];
        MFUIBaseViewModel *tempViewModel = [[((MFUIBaseListViewModel *)self.viewModel).viewModels objectAtIndex:indexPath.row] copy];
        tempViewModel.parentViewModel = self.viewModel;
        //Displaying the detail controller
        [nextController setOriginalViewModel:tempViewModel];
        
        [((UIViewController *)parentController).navigationController pushViewController:nextController animated:YES];
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
    
    [self callEditItemListenerAtIndexPath:indexPath];
}

-(void) callEditItemListenerAtIndexPath:(NSIndexPath *)indexPath {
    //PROTODO
    //    NSString *customEditItemListener = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).editItemListener;
    //    customEditItemListener = [customEditItemListener stringByAppendingString:@"AtIndexPath:"];
    //    if(customEditItemListener) {
    //        if( [self respondsToSelector:NSSelectorFromString(customEditItemListener)]) {
    //            [self performSelector:NSSelectorFromString(customEditItemListener) withObject:indexPath];
    //        }
    //    }
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
    MFUIBaseViewModel *newObject = [[NSClassFromString([self itemListViewModelName]) alloc] init];
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
    //        NSString *addItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).addItemListener;
    //        [self performSelectorFromMethodName:addItemListenerName onActionAtIndexPath:nil];
    if (reload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });
    }
    
    if([self.fixedList isPhotoFixedList]) {
        id<MFCommonFormProtocol> parentController = self.fixedList.parentViewController;
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
    [self computeCellHeightAndDispatchToFormController];
}

#pragma mark - FixedList forwarding
-(MFUIBaseListViewModel *) viewModel {
    return [self.fixedList getData];
}



-(id<MFCommonFormProtocol>) formController {
    return (id<MFCommonFormProtocol>)_fixedList.parentViewController;
}

#pragma mark - FixedList utils
-(NSString *)itemListViewModelName {
    [MFException throwNotImplementedExceptionOfMethodName:@"itemListViewModelName" inClass:[self class] andUserInfo:nil];
    return @"";
}

-(void) setContent{
    [self.fixedList setItemClassName:[self itemListViewModelName]];

    self.viewModel = [self.fixedList getData];
    if(self.viewModel) {
        self.viewModel.form = self;
    }
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


#pragma mark - FormController utils

-(MFUIBaseListViewModel *)getViewModel {
    return [self viewModel];
}

-(MFUIBaseViewModel *)viewModelAtIndexPath:(NSIndexPath *)indexPath {
    return ((MFUIBaseListViewModel *)[self getViewModel]).viewModels[indexPath.row];
}

-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
    [self.fixedList.tableView reloadData];
}
-(void) initializeModel {
    self.viewModel.objectWithBinding = self;
}

-(void)setBindingDelegate:(MFBindingDelegate *)bindingDelegate {
    _bindingDelegate = bindingDelegate;
    [self createBindingStructure];
}

-(void) computeCellHeightAndDispatchToFormController {
    
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    float itemHeight = [bindingData.cellHeight floatValue];
    
    UIViewController *parent = self.fixedList.parentViewController;
    if(parent && [parent conformsToProtocol:@protocol(MFObjectWithBindingProtocol)]) {
        id<MFObjectWithBindingProtocol> parentObjectWithBinding = (id<MFObjectWithBindingProtocol>)parent;
        MFBindingValue *selfBindingValue = parentObjectWithBinding.bindingDelegate.binding.bindingByComponents[@(self.fixedList.hash)];
        if(selfBindingValue && [self getViewModel]) {
            int numberOfItems = ((MFUIBaseListViewModel *)[self getViewModel]).viewModels.count;
            float height = numberOfItems * itemHeight ;
            height += (numberOfItems - 1) * TABLEVIEW_SEPARATOR_HEIGHT;
            height += self.fixedList.topBarView.frame.size.height;
            if(((MFUIBaseListViewModel *)[self getViewModel]).viewModels.count == 0) {
                height = self.fixedList.topBarViewHeight;
            }
            
            [self.fixedList changeDynamicHeight:height];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"MDK_ComponentSize_%@", [selfBindingValue.bindingIndexPath stringIndexPath]] object:@(height)];
        }
    }
}

-(void)createBindingStructure {
        MFTableConfiguration *tableConfiguration = [MFTableConfiguration createTableConfigurationForObjectWithBinding:self];
        MFBindingCellDescriptor *photoCellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:@"PhotoFixedListItemCell" withCellHeight:@(123) withCellBindingFormat:@"outlet.photoValue.binding : vm.photo<->c.data", nil];
        [tableConfiguration createFixedListTableCellWithDescriptor:photoCellDescriptor];
}



@end

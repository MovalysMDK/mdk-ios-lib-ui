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
}




#pragma mark - Initialisation des composants graphiques

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
    UITableViewCell *cell;
    
    //Création ou récupération de la cellule
//    [tableView registerNib:[UINib nibWithNibName:currentGd.uitype bundle:nil] forCellReuseIdentifier:currentGd.uitype];
    
//       cell.selectionStyle =
//    (self.fixedList.mf.editMode == MFFixedListEditModePopup && self.fixedList.mf.canEditItem) ? UITableViewCellSelectionStyleBlue :
//    UITableViewCellSelectionStyleNone;
    
//    if(self.fixedList.editMode == MFFixedListEditModePopup && self.fixedList.mf.canEditItem) {
//        
//        cell.accessoryType = [cell accessoryType];
//        cell.editingAccessoryType = [cell accessoryType];
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.fixedList.cellContainer) {
            [((MFCellAbstract *)self.fixedList.cellContainer) updateConstraints];
        }
        else {
            [self redrawSelfWithTableView:tableView];
        }
    });
    
//    [cell cellIsConfigured];
    return cell;
}

/**
 * @brief Indique que cette cellule est éditable
 */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.fixedList.mf.canDeleteItem;
    
    //PROTODO : Can edit
    return YES;
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
                
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //PROTODO
//        NSString *deleteItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).deleteItemListener;
//        [self performSelectorFromMethodName:deleteItemListenerName onActionAtIndexPath:indexPath];
        
        
    }
    [tableView endUpdates];
    
    // Exécution du block
    [CATransaction commit];
    [self.fixedList.tableView reloadData];
    [self redrawSelfWithTableView:self.fixedList.tableView];
    [self.HUD hide:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(!self.fixedList.mf.canEditItem)
//        return;
//    
//    if(self.fixedList.mf.editMode == MFFixedListEditModePopup) {
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
//    }
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
//        NSString *addItemListenerName = ((MFFieldDescriptor *)self.fixedList.selfDescriptor).addItemListener;
//        [self performSelectorFromMethodName:addItemListenerName onActionAtIndexPath:nil];
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self redrawSelfWithTableView:self.fixedList.tableView];
                [self.HUD hide:YES];
            });
        }
    
    if([self.fixedList isPhotoFixedList]) {
        id<MFCommonFormProtocol> parentController = self.fixedList.form;
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



-(id<MFCommonFormProtocol>) formController {
    return (id<MFCommonFormProtocol>)_fixedList.form;
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


@end

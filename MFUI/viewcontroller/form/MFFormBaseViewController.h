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
//  MFFormBaseViewController.h
//  MFUI
//
//

//Parent ViewController
#import "MFViewController.h"

//Binding
#import "MFBindingFormDelegate.h"

//Search Delegate
#import "MFFormSearchDelegate.h"

//Protocol
#import "MFFormViewControllerProtocol.h"
#import "MFUIForm.h"
#import "MFUITransitionDelegate.h"

@protocol MFFormCellProtocol;
@class MFFormSearchViewController;

FOUNDATION_EXPORT NSString *const MF_BINDABLE_PROPERTIES;

/**
 * @brief This class is the base class of a Movalys Form View Controller
 * @discussion It creates cells with appropriates components, bind them to a ViewModel and manage the lifecycle of the controller.
 */
@interface MFFormBaseViewController : MFViewController <MFUITransitionDelegate, MFFormViewControllerProtocol, UITableViewDelegate, UITableViewDataSource, MFBindingFormDelegate>


#pragma mark - Properties

/**
 * @brief Indicates if the data of the screen should be reloaded
 */
@property (nonatomic) BOOL shouldReloadData;

/**
 * @brief Indicates if the controller is on a detroy state
 */
@property (nonatomic) BOOL onDestroy;

/**
 * @brief TODO
 */
@property (nonatomic, strong) UISearchDisplayController *searchController;

/**
 * @brief L'extension de ce formulaire contenant des données écrites dans le StoryBoard associé 
 */
@property(nonatomic, strong) MFFormExtend *mf;

/**
 * @brief Le delegate permettant le binding Formulaire<->ViewModel
 */
@property(nonatomic, strong) id<MFBindingFormDelegate> formBindingDelegate ;

/**
 *  @brief la table associée
 */
@property(nonatomic, strong) IBOutlet UITableView *tableView;

/**
 * @brief The necessary delegate to display a search form if needed
 */
@property (nonatomic, strong) MFFormSearchDelegate *searchDelegate;

/**
 * @brief A boolean that indicates if the form need to reload its data
 */
@property (nonatomic) BOOL needDoFillAction;

/*!
 * @brief A value that indicates the type of the form
 */
@property(nonatomic) MFFormType formType;

#pragma mark - Methods

/**
 * @brief Cette méthode renvoie un objet MFGroupDescriptor correspondant à une cellule du formulaire
 * @param indexPath La position (@see NSIndexPath) de la cellule dont on souhiate récupérer le groupDescriptor.
 * @return Le descripteur de la cellule dont la position est passée en paramètre
 */
-(MFGroupDescriptor *) getGroupDescriptor:(NSIndexPath *)indexPath;

/**
 * @brief Reload the data of the main tableView and performs a sliding an animation to the right or to the left
 * @param fromRight YES if the animation should be performed to the right, NO if tis should be performed to the left
 */
- (void)reloadDataWithAnimationFromRight:(BOOL)fromRight;

/**
 * @brief Indicates if this formController should display a searchFrom or a searchTopBar
 * @return YES is this controller should display a searchForm or topBarSearch, NO else.
 */
-(BOOL)hasSearchForm;

/**
 * @brief The MFFormSearchViewController used to display a searching form to the user
 * @return The created searchViewController
 */
-(MFFormSearchViewController *)searchViewController;

/**
 * @brief This action is launched when the user do a simple search.
 * in this class, this method should launch an exception. 
 * The implementation should be in child class.
 * @param text the current text to search in the list
 -*/
-(void)simpleSearchActionWithText:(NSString *)text;

/**
 * @brief Returns a specified cell identifier depending on given indexPath or current GroupDescriptor
 * @param indexPath The indexPath we will to give a cell identifier to try to reuse it.
 * @param groupDescriptor The current group descriptor for the cell at this indexPath
 * @return A cell identifier as a (NSString *) object
 */
-(NSString *) cellIdentifierAtIndexPath:(NSIndexPath *)indexPath withGroupDescriptor:(MFGroupDescriptor *)groupDescriptor;

/**
 * @brief Get the main dataLoader name associated to this controller
 * @return An NSString containing the dataloaderName associated to this controller
 */
-(NSString *)dataLoaderName;

/**
 * @brief Cette méthode doit définir et retourner une liste de filtres à appliquer lorsque
 * la synchronisation d'une donnée se fait depuis le ViewModel vers le formulaire. La clé du dictionnaire
 * est le keyPath du champ, et sa valeur est un ^MFValueChangedFilter
 * @return Un dictionnaire contenant des définitions de filtres pour certains champs
 */
-(NSDictionary*) getFiltersFromViewModelToForm;

/**
 * @brief Cette méthode doit définir et retourner une liste de filtres à appliquer lorsque
 * la synchronisation d'une donnée se fait depuis le Formulaire vers le ViewModel. La clé du dictionnaire
 * est le keyPath du champ, et sa valeur est un ^MFValueChangedFilter
 * @return Un dictionnaire contenant des définitions de filtres pour certains champs
 */
-(NSDictionary*) getFiltersFromFormToViewModel;

/**
 * @brief Returns the cell at the specified indexPath for the specified GroupDescriptor
 * @param indexPath The indexPath of the cell to retrieve
 * @param currentGd The group descriptor that configured the cell
 * @return A Movalys MFCellAbstract object
 * @see MFCellAbstract
 */
-(UITableViewCell<MFFormCellProtocol> *) retrieveCellAtIndexPath:(NSIndexPath *)indexPath fromCurrentGroupDescriptor:(MFGroupDescriptor *)currentGd;


@end



/**
 * @brief This protocol allows to implement the method setContent called before the tableView is initialized
 */
@protocol MFContentDelegate <NSObject>

@required
/**
 * @brief Permet d'initialiser du contenu avant le chargement des DataSource et Delegate
 */
-(void)setContent;

@end

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


#import "MFFormWithDetailViewControllerProtocol.h"
#import "MFUITransitionDelegate.h"
#import "MFUIElementCommonProtocol.h"
#import "MFUIBaseListViewModel.h"
#import "MFFormViewController.h"
#import "MFFormExtend.h"
#import "MFDefaultViewModelCreator.h"
#import "MFListViewControllerProtocol.h"

/*!
 * @class MFForm2DListViewController
 * @brief A Movalmys Form View Controller that presents a 2 levels list (2D-list)
 * @discussion This is a base Movalys Form List View Controller.
 * @discussion The main level (1) is represented as sections of the UITableView managed by this controller
 * @discussion The second level (2) is represented by cells of the UITableView managed by this controller.
 * @discussion The simple touch action on a section shows/hides child items of the section.
 */
@interface MFForm2DListViewController : MFFormBaseViewController <MFListViewControllerProtocol, NSFetchedResultsControllerDelegate, MFViewControllerObserverProtocol>

#pragma mark - Properties
/*!
 * @brief The name of the delete action
 */
@property (nonatomic,strong) NSString *deleteAction;

/*!
 * @brief A dictionary containing the filter parameters for 2D and 3D lists
 */
@property (nonatomic, strong) NSDictionary *filterParameters;

/*!
 * @brief The list of the section viewModels
 */
@property (nonatomic, strong) NSArray *sectionsViewModelList;

/*!
 * @brief The section descriptor used to inflate and bind the section view
 */
@property (nonatomic, strong) MFFormDescriptor *sectionDescriptor;

/*!
 * @brief The cellDescriptor used to inflate and bind a cell
 */
@property (nonatomic, strong) MFFormDescriptor *cellDescriptor;

/*!
 * @brief A dictionary containing the current state (opened or closed) for each section of the tableView
 */
@property (nonatomic, strong) NSMutableDictionary *openedSectionStates;

/*!
 * @brief the item identifier
 */
@property (nonatomic,strong) NSString *itemIdentifier;


#pragma mark - Methods

/*!
 * @brief Performs a specified action on a ViewModel
 * @param bindingKey the binding key corresponding to a field of the specified ViewModel ; this key is also used to 
 * generate the selector of the action to perform.
 * @param viewModel the viewModel on which the selector will be performed
 */
-(void) performSelectorForPropertyBinding:(NSString *) propertyBindingKey onViewModel:(MFUIBaseViewModel *)viewModel withIndexPath:(NSIndexPath *)indexPath;

/*!
 * @brief Registers the components of a cell (or a bindable view)
 * @param cell A cell or a bindableView 
 * @return A dictionnary of the new registered components from this cell/view
 */
-(NSDictionary *)registerComponentsFromCell:(id<MFFormCellProtocol>) cell;


/*!
 * @brief Get ViewModel for this dimension (third dimension, for header)
 * @param indexPath The indexPath to the view/cell binded at the ViewModel that we want to get
 * @return A viewModel corresponding to the passed indexPath
 */
-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * @brief Cette méthode applique un traitement particulier lorsque la valeur du champ correspondant dans le ViewModel
 * à la liste des composants passée en paramètres est modifiée.
 * @param componentList Une liste de composants (définis dans les formulaires PLIST) dont on souhaite écouter les modifications
 * de valeur dans le ViewModel
 */
-(void) applyCustomValueChangedMethodForComponents:(NSArray *)componentList atIndexPath:(NSIndexPath *)indexPath;

/*!
 * @brief Cette méthode met à jour un composant graphique depuis les données du ViewModel associé au formulaire.
 * @param bindingKey La clé associée à un ou plusieurs composants dont on souhaite affecter une valeur depuis le ViewModel
 */
-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender;

/*!
 * @brief Cette méthode met à jour les données de la cellule selon son indexPath
 * @param cell La cellule
 */
-(void) setDataOnView:(id<MFFormCellProtocol>)cell withOptionalViewModel:(id<MFUIBaseViewModelProtocol>)viewModel;

/*!
 * @brief Cette méthode permet à l'utilisateur d'ajouter des filtres pour la synchronisation des données
 * depuis le formulaire vers le ViewModel
 * @param filters Les filtres sous forme d'un dictionnaire contenant des @see(MFValueChangedFilter)
 */
-(void) completeFiltersFromFormToViewModel:(NSDictionary*)filters;

/*!
 * @brief Cette méthode permet à l'utilisateur d'ajouter des filtres pour la synchronisation des données
 * depuis le ViewModel vers le formulaire
 * @param filters Les filtres sous forme d'un dictionnaire contenant des @see(MFValueChangedFilter)
 */
-(void) completeFiltersFromViewModelToForm:(NSDictionary*)filters;

/*!
 * @brief Cette méthode doit définir et retourner une liste de filtres à appliquer lorsque
 * la synchronisation d'une donnée se fait depuis le ViewModel vers le formulaire. La clé du dictionnaire
 * est le keyPath du champ, et sa valeur est un ^MFValueChangedFilter
 * @return Un dictionnaire contenant des définitions de filtres pour certains champs
 */
-(NSDictionary*) getFiltersFromViewModelToForm;

/*!
 * @brief Cette méthode doit définir et retourner une liste de filtres à appliquer lorsque
 * la synchronisation d'une donnée se fait depuis le Formulaire vers le ViewModel. La clé du dictionnaire
 * est le keyPath du champ, et sa valeur est un ^MFValueChangedFilter
 * @return Un dictionnaire contenant des définitions de filtres pour certains champs
 */
-(NSDictionary*) getFiltersFromFormToViewModel;

/*!
 * @brief Cette méthode permet de faire les initialisations nécessaires au bon fonctionnement du controller
 * Cette méthode devra notamment être implémentée par l'utilisateur dans son propre FormViewController afin qu'il
 * définisse le viewModel associé à son propre FormViewcontroller.
 */
-(void) initialize;

/*!
 * @brief load the data of the screen
 */
-(void) doFillAction;

/*!
 * @brief refresh the list
 */
-(void) refresh;

/*!
 * @brief refresh the liste with some parameters
 * @param parameters The parameteres to use to refresh the list
 */
-(void) refreshWithParameters:(NSDictionary *)parameters;

/*!
 * @brief Opens a section (inserts cells of this section)
 * @param section The index of the section to open
 */
-(void)openSectionAtIndex:(NSNumber *)section;

/*!
 * @brief Closes a section (removes cells of this section)
 * @param section The index of the section to close
 */
-(void)closeSectionAtIndex:(NSNumber *)section;

/*!
 * @brief Allow to laod a descriptor specified by its name
 * @param descriptorName The name to the descriptor to load
 */
-(MFFormDescriptor *) loadDescriptorWithName:(NSString *)descriptorName;

@end


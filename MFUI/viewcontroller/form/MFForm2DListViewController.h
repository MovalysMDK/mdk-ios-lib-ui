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
#import "MFUIBaseListViewModel.h"
#import "MFFormViewController.h"
#import "MFDefaultViewModelCreator.h"
#import "MFListViewControllerProtocol.h"
#import "MFObjectWithBindingProtocol.h"

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
 * @brief A dictionary containing the current state (opened or closed) for each section of the tableView
 */
@property (nonatomic, strong) NSMutableDictionary *openedSectionStates;

/*!
 * @brief the item identifier
 */
@property (nonatomic,strong) NSString *itemIdentifier;


#pragma mark - Methods



/*!
 * @brief Get ViewModel for this dimension (third dimension, for header)
 * @param indexPath The indexPath to the view/cell binded at the ViewModel that we want to get
 * @return A viewModel corresponding to the passed indexPath
 */
-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath;

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
 * @brief Indicates if all the sections must be opened or close on the first display
 * @return Returns YES if all section must be opened first, NO otherwhise.
 */
-(BOOL) allSectionsOpenedFirst;


@end


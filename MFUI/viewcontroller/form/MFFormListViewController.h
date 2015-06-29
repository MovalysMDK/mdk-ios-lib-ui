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


//ViewModel
#import "MFUIBaseListViewModel.h"

//Delegate
#import "MFUITransitionDelegate.h"

//ViewController
#import "MFFormBaseViewController.h"

//Action
#import "MFDeleteDetailActionParamIn.h"
#import "MFDeleteDetailActionParamOut.h"

//Protocol
#import "MFListViewControllerProtocol.h"
#import "MFViewControllerObserverProtocol.h"

/*!
 * @class MFFormListViewController
 * @brief The base Movalys Form List View Controller
 * @discussion This base Movalys Form List Controller displays a list of items managed by a List View Model
 * @see MFUIBaseListViewModel
 * @see MFListViewControllerProtocol
 */
@interface MFFormListViewController : MFFormBaseViewController<NSFetchedResultsControllerDelegate, MFViewControllerObserverProtocol, MFListViewControllerProtocol>

#pragma mark - Properties

/*!
 * @brief The name of the delete action
 */
@property (nonatomic,strong) NSString *deleteAction;

/*!
 * @brief The item identifier
 */
@property (nonatomic,strong) NSString *itemIdentifier;





#pragma mark - Méthodes


/*!
 * @brief Get viewmodel at indexPath
 * @param indexPath indexPath
 * @return viewmodel
 */
-(NSObject<MFUIBaseViewModelProtocol> *) viewModelAtIndexPath:(NSIndexPath *)indexPath ;

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


@end

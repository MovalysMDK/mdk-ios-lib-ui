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



#import "MFUIBaseViewModel.h"
#import "MFObjectWithBindingProtocol.h"

#pragma mark - Propriétés
/*!
 * @brief Cette classe est ConverunViewModel contenant une liste de ViewModel
 */
@interface MFUIBaseListViewModel : NSObject <MFUIBaseViewModelProtocol>

/*!
 * @brief Cette propriété définit le nom du ViewModel que cette liste utilise
 */
@property (nonatomic, strong) NSString *viewModelName;

/*!
 * @brief La liste des ViewModel
 */
@property (nonatomic, strong, readonly) NSMutableArray *viewModels;

/*!
 * Controller for fetched results
 */
@property (nonatomic, strong) NSFetchedResultsController *fetch;

/*!
 * @brief Le nombre d'items de la liste
 */
@property (nonatomic) int numberOfItems;

/*!
 * @brief Cette propriété définit le ViewModel Parent. Si cette propriété reste nulle,
 * alors ce ViewModel est le plus haut parent
 */
@property (nonatomic, weak) id<MFUIBaseViewModelProtocol> parentViewModel;

#pragma mark - Méhodes à implémenter dans les fils 

/*!
 * @brief Définit le nombre d'items à afficher dans la liste
 * @return le nombre d'élément de la liste
 */
-(NSUInteger) defineNumberOfItems;

/*!
 * @brief Définit le nom du ViewModel à lister
 * @return le nom du ViewModel à lister
 */
-(NSString *)defineViewModelName;

/*!
 * @brief Initialisation
 */
-(void) initialize;

/*!
 * @brief clear
 */
-(void)clear;


#pragma mark - Edition
/*!
 * @brief add an item viewmodel
 * @param itemVm item viewmodel
 */
-(void) add:(MFUIBaseViewModel *)itemVm ;

/*!
 * @brief add item at index
 * @param itemVm item vm
 * @param index index
 */
-(void) add:(MFUIBaseViewModel *)itemVm atIndex:(NSInteger)index ;

/*!
 * @brief Allows to update the ViewModel property
 * @param viewModels the new array of ViewModel to set
 */
-(void) updateViewModels:(NSArray <MFUIBaseViewModel *>*)viewModels;

/*!
 * @brief Delete the given item for the ListViewModel
 * @param itemVm The item to delete
 */
-(void) deleteItem:(MFUIBaseViewModel *)itemVm;

/*!
 * @brief Delete the item at the given position from de ListViewModel
 * @param itemVm The position of the item to delete.
 */
-(void) deleteItemAtIndex:(NSInteger)index;


@end

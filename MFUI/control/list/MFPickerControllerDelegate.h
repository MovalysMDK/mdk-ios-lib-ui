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




//Component import
#import "MFPickerList.h"
#import "MFPickerListConfiguration.h"

//Binding imports
#import "MFUIBinding.h"

@protocol MFContentDelegate;

/*!
 * @brief This class is used as the Delegate and DataSource of a MFPicker.
 * This component can indeed be declared in any kinf of cells that inherits from MFCellAbstract.
 * Its more convenient to manages data of the picker here.
 */
@interface MFPickerControllerDelegate : NSObject <UIPickerViewDataSource, UIPickerViewDelegate, MFCommonFormProtocol, MFSearchDelegate>


#pragma mark - Properties

/*!
 * @brief The picker we want to manage data in this delegate
 */
@property (nonatomic, weak) MFPickerList *picker;

/*!
 * @brief Le ViewModel associé à ce formulaire. il peut s'agir d'un ViewModel simple contenant différents
 * types de champs( => viewModel de type MFUIBaseViewModel) ou un ViewModel de type "liste" qui contient une liste
 * d'autres viewModels ( => viewModel de type MFUIBaseListViewModel ).
 */
@property(nonatomic, strong) NSMutableArray *filteredViewModels;



#pragma mark - Methods 

/*!
 * @brief Custom constructor
 * @param pickerList The MFPickerList component from which this class will manage data
 * @return The built MFPickerControllerDelegate object
 */
-(id) initWithPickerList:(MFPickerList *)pickerList;

/*!
 * @brief An empty itemView of the PickerList
 */
-(MFBindingViewAbstract *)itemView;

/*!
 * @see MFSearchDelegate
 */
-(BOOL)filterViewModel:(MFUIBaseViewModel *)viewModel withCurrentSearch:(NSString *)searchText;

/*!
 * Select view model with the position in parameter
 */
-(void) selectViewModel:(NSInteger)row ;


-(void) initialize;

@end

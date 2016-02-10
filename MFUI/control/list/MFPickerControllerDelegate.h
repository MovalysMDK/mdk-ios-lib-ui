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
//  MFPickerControllerDelegate.h
//  MFUI
//
//



//Component import
#import "MFPickerList.h"

//Binding imports
#import "MFUIBinding.h"

@protocol MFContentDelegate;

/**
 * @brief This class is used as the Delegate and DataSource of a MFPicker.
 * This component can indeed be declared in any kinf of cells that inherits from MFCellAbstract.
 * Its more convenient to manages data of the picker here.
 */
@interface MFPickerControllerDelegate : NSObject <UIPickerViewDataSource, UIPickerViewDelegate, MFBindingFormDelegate, MFSearchDelegate, MFViewModelChangedListenerProtocol, MFContentDelegate>


#pragma mark - Properties

/**
 * @brief The picker we want to manage data in this delegate
 */
@property (nonatomic, weak) MFPickerList *picker;

/**
 * @brief Form Binding Delegate. This delegate allow to bind a ViewModel to a Form easily
 */
@property(nonatomic, strong) id<MFBindingFormDelegate> formBindingDelegate ;

/**
 * @brief Le ViewModel associé à ce formulaire. il peut s'agir d'un ViewModel simple contenant différents
 * types de champs( => viewModel de type MFUIBaseViewModel) ou un ViewModel de type "liste" qui contient une liste
 * d'autres viewModels ( => viewModel de type MFUIBaseListViewModel ).
 */
@property(nonatomic, strong) NSMutableArray *filteredViewModels;


#pragma mark - Methods 

/**
 * @brief Custom constructor
 * @param pickerList The MFPickerList component from which this class will manage data
 * @return The built MFPickerControllerDelegate object
 */
-(id) initWithPickerList:(MFPickerList *)pickerList;

/**
 * @brief An empty itemView of the PickerList
 */
-(MFBindingViewAbstract *)itemView;

/**
 * @see MFSearchDelegate
 */
-(BOOL)filterViewModel:(MFUIBaseViewModel *)viewModel withCurrentSearch:(NSString *)searchText;

/**
 * @brief Fills the selected view with the data of the given viewModelk
 * @param viewModel The viewModel to use to fill the selected view
 */
-(void) fillSelectedViewWithViewModel:(MFUIBaseViewModel *)viewModel;

-(void) reinitBinding;
/**
 * Select view model with the position in parameter
 */
-(void) selectViewModel:(NSInteger)row ;

@end

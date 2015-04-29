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
//  MFPickerList.h
//  MFUI
//
//

#import "MFUIView.h"
#import "MFUIMotion.h"
#import "MFUIForm.h"

#import "MFUIOldBaseComponent.h"

@class MFUIBaseListViewModel;
@class MFUIBaseViewModel;

#pragma mark - Constants
FOUNDATION_EXPORT NSString *const PICKER_NOTIFICATION_SHOW;
FOUNDATION_EXPORT NSString *const PICKER_NOTIFICATION_HIDE;
FOUNDATION_EXPORT NSString *const PICKER_NOTIFICATION_FORCE_HIDE;

FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_SEARCH_KEY;
FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_SELECTION_INDICATOR_COLOR_KEY;

FOUNDATION_EXPORT NSString *const PICKER_NOTIFICATION_BUTTON_SAVE_TITLE;
FOUNDATION_EXPORT NSString *const PICKER_NOTIFICATION_BUTTON_CANCEL_TITLE;
FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_VALUES_KEY;

FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_OK_BUTTON_COLOR_KEY;
FOUNDATION_EXPORT NSString *const PICKER_PARAMETER_CANCEL_BUTTON_COLOR_KEY;

FOUNDATION_EXPORT const int PICKER_VIEW_TAG;


@interface MFPickerList : MFUIOldBaseComponent <UIGestureRecognizerDelegate, UISearchBarDelegate, MFOrientationChangedProtocol>


#pragma mark -  Properties - Graphics

/**
 * @brief l'extension du controlleur, l'extension contient des paramètres qui peuvent être définis dans le storyboard
 */
@property(nonatomic, strong) MFFormExtend *mf;

/**
 * @brief The button which displays the selected item and which displays the pickerView (onClick)
 */
@property (nonatomic, weak) MFBindingViewAbstract *staticView;

/**
 * @brief The binded view displayed when no data is selected in the picker.
 */
@property (nonatomic, strong) MFBindingViewAbstract *emptyStaticView;

/**
 * @brief The name of the XIB that represents the empty view
 */
@property (nonatomic, strong) NSString *emptyViewNibName;

/**
 * @brief The pickerView whichi displays the items
 */
@property (nonatomic, strong) UIPickerView *pickerView;

/**
 * @brief The view container of the pickerView
 */
@property (nonatomic, strong) UIScrollView *modalPickerView;

/**
 * @brief The button to confirm the current choice
 */
@property (nonatomic, strong) UISegmentedControl *confirmButton;

/**
 * @brief The button to cancel the current choice
 */
@property (nonatomic, strong) UISegmentedControl *cancelButton;

/**
 * @brief The search bar
 */
@property (nonatomic, strong) UISearchBar *searchBar;



#pragma mark - Properties - Others

/**
 * @brief Indicates if th pickerView is currently showing
 */
@property (nonatomic) BOOL isShowing;

/**
 * @brief Le tableau contenant les données de la Liste éditable
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;



#pragma mark - Methods

/**
 * @brief Returns the frame of the pickerView
 * @returns the frame of the pickerView
 */
-(CGRect) pickerFrame;

/**
 * @brief Builds and displays the pickerView
 */
-(void) displayPickerView;

/**
 * @brief The values to display in pickerView
 * @return A MFUIBaseListViewModel object that is used to display datas of the PickerView
 */
-(id) getValues;

/**
 * @brief Get the name of the formDescriptor used to load the selected view
 * @return The name of the PLIST form descriptor that describes the selected view
 */
-(NSString *)selectedViewFormDescriptorName;

/**
 * @brief Get the name of the formDescriptor used to load the list item view of the picker
 * @return The name of the PLIST form descriptor that describes the list item view of the picker
 */
-(NSString *)lstItemViewFormDescriptorName;

/**
 * @brief Dismiss the picker view and save its current data to set in the static view.
 */
-(void) dismissPickerViewAndSave;

/**
 * @brief Dismiss the picker view and don't save the current data. The old data will be kept in the static view.
 */
-(void) dismissPickerViewAndCancel;

@end




@protocol MFSearchDelegate <NSObject>

@required
/**
 * @brief Filter to search.
 * @param viewModel A viewModel
 * @param searchText The current text to search in ViewModel
 * @return a BOOL that indicate if the viewModel is accepted or not (rejected).
 */
- (BOOL) filterViewModel:(MFUIBaseViewModel *)viewModel withCurrentSearch:(NSString *)searchText;

/**
 * @brief This method will be called in order to update the result with a new search
 * @param searchText The new search to use
 */
- (void)updateFilterWithText:(NSString *)searchText;

@end

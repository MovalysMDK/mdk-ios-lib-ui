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
//  MFListViewControllerProtocol.h
//  MFUI
//
//
//



#pragma mark - Properties

/**
 * @brief This protocol provides some attributes to manage a FormListviewController
 */
@protocol MFListViewControllerProtocol <NSObject>

/**
 * @brief Indicates if an add button button should be shown
 */
@property (nonatomic) BOOL showAddItemButton;

/**
 * @brief Indicates if the long press to delete gesture is enabled
 */
@property (nonatomic) BOOL longPressToDelete;

/**
 * @brief The name of the storyboard of the detail
 */
@property (nonatomic,strong) NSString *detailStoryboardName;



#pragma mark - Methods

/**
 * @brief This method creates a new item of the list. 
 * It is called when the user press the "add item" button
 */
- (void) doOnCreateItem;

/**
 * @brief Add a toolbar to the controller with given items
 */
-(void) addToolBarWithItems:(NSArray *)items;

/**
 * @brief Add a button bar item to the toolbar
 */
//-(void) addToolbarItem:(UIBarButtonItem *)item;

@end

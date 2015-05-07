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


#import "MFFormViewController.h"


/**
 * @class MFFormSearchViewController
 * @brief The form controller for the search view controller
 * @discussion To complete
 */
@interface MFFormSearchViewController : MFFormViewController

#pragma mark - Properties
/**
 * @brief The navigation Bar
 */
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

/**
 * @brief The left button of the navigation bar
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarLeftButton;


/**
 * @brief The right button of the navigation bar
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navigationBarRightButton;

/**
 * @brief The clear button of the toolBar
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarClearButton;

/**
 * @brief The formController on which will be applied the search
 */
@property (nonatomic, weak) MFFormBaseViewController *targetFormController;


#pragma mark - Methods

/**
 * @brief This method is called when the leftButton of the navigationBar is tapped.
 * You can customize the action of this button here
 */
-(void)navigationBarLeftButtonAction;

/**
 * @brief This method is called when the rightButton of the navigationBar is tapped.
 * You can customize the action of this button here
 */
-(void)navigationBarRightButtonAction;

/**
 * @brief Valids the current form and search
 */
-(void) validFormAndSearch;

/**
 * @brief Cancel the search
 */
-(void) cancelSearch;

@end

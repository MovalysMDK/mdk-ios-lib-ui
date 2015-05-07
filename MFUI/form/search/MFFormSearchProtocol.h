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


@class MFFormViewController;

@protocol MFFormSearchProtocol <NSObject>

#pragma mark - Properties

/**
 * @brief The controller to display to make a new search
 */
@property (nonatomic, strong) MFFormViewController *searchFormController;

/**
 * @brief Indicates if the search is a simple search. 
 * In that case, the searchFormController should not be shown.
 */
@property (nonatomic) BOOL isSimpleSearch;

/**
 * @brief Indicates if the search is a live search.
 * This property doesn't make sense if the search is not a simple search.
 * It the value is YES, the results will be displayed instantly to ther user.
 * If the value is NO, the results will be displayed when the user will click on a "OK" button.
 */
@property (nonatomic) BOOL isLiveSearch;

/**
 * @brief Indicates if the number of results should be displayed
 */
@property (nonatomic) BOOL displayNumberOfResults;



#pragma mark - Methods

@optional
/**
 * @brief Shows the showFormController if needed, or a top searchBar.
 */
-(void) showSearchFormController;


@optional
/**
 * @brief Add a search icon to he navigationItem of the FormViewController
 */
-(void) addSearchIcon;

@end

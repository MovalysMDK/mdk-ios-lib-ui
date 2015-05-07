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
//  MFWorkspaceView.h
//  Pods
//
//
//


#import "MFUIMotion.h"
#import "MFUIProtocol.h"

#import "MFUIViewControllerContainerWorkspace.h"

FOUNDATION_EXPORT NSString *const WORKSPACE_VIEW_DID_SCROLL_NOTIFICATION_KEY;


@interface MFWorkspaceView : UIScrollView <MFOrientationChangedProtocol, MFDefaultConstraintsProtocol, UIScrollViewDelegate>


#pragma mark - Properties
/*!
 * @brief The delegate that manages orientation changes for this controller
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;

/*!
 * @brief The view that contains the view controllers of this workspace view
 */
@property (nonatomic, strong) UIView *containerView;



#pragma mark - Properties
/*!
 * @brief Add columns from designed segues in the storyboard
 * @param columnsSegues An array of Workspace Segue that are used to define the columns of the workspace
 */
-(void) addColumnFromSegue:(MFWorkspaceColumnSegue *) columnSegue;

/*!
 * @brief Refreshs the view from the given columnSegues
 * @param columnSegues An array of MFWorksapceSegue that defines the columns to display
 */
-(void) refreshViewFromSegues:(NSArray *)columnSegues;

/*!
 * @brief Makes scroll the workspaceView to the master column
 */
-(void) scrollToMasterColumn;

/*!
 * @brief Makes scroll the workspaceView to the detail column with specified index
 * @param index The index of the detail column to scroll
 */
-(void) scrollToDetailColumnWithIndex:(int)index;

/*!
 * @brief Indicates if the column with the specified name is visible
 * @param columnName The name of the column we need to get the current visibility
 * @return YES if the column is currently visible, NO otherwhise
 */
-(BOOL) isColumnWithNameVisible:(NSString *)columnName;

/*!
 * @brief Indicates if the master column is visible
 * @return YES if the master column is currently visible, NO otherwhise
 */
-(BOOL) isMasterColumnVisible;


/*!
 * @brief Unregister the columns references
 */
-(void) unregisterColumnsReferences;

/*!
 * @brief Force to hide any modal input manager (keyboard, picker...)
 */
-(void) hideAnyModalInput;

@end

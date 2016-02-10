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
//  MFWorkspaceViewController.h
//  MFUI
//
//



#import "MFContainerViewController.h"
#import "MFWorkspaceDetailColumnProtocol.h"
#import "MFWorkspaceMasterColumnProtocol.h"

@class MFWorkspaceView;

@interface MFWorkspaceViewController : MFContainerViewController

#pragma mark - Properties

/**
 * @brief An array that contains the different columns managed by this Workspace View Controller
 */
@property (nonatomic, strong) NSMutableArray *segueColumns;



#pragma mark - Methods

/** 
 * @brief This method is called when an item has been selected in the master column
 * @param indexPath The indexPath of the selected item in the master column
 * @param sourceController The master view controller
 */
- (void) didSelectMasterIndex:(NSIndexPath *)indexPath from:(id<MFWorkspaceMasterColumnProtocol>) sourceController;

/**
 * @brief Returns the workspace view of this workspace view controller
 * @return The workspace view of this workspace view controller
 */
-(MFWorkspaceView *)getWorkspaceView;

/**
 * @brief Allows to create an item in the master list and to show an empty detail
 */
-(void) createMasterItem;

-(void) releaseRetainedObjects;

@end

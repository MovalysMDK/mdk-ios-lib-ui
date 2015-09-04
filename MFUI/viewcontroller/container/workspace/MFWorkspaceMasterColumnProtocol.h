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



#import "MFWorkspaceColumnProtocol.h"
#import "MFUIBaseViewModelProtocol.h"

/*!
 * @brief This protocol defines the properties and methods that each master ViewController of a
 * MFWorkspaceViewController should use.
 */
@protocol MFWorkspaceMasterColumnProtocol <MFWorkspaceColumnProtocol>

/*!
 * @brief Returns the viewModel corresponding to the selected item in the master column
 * @param indexPath, The indexpath of the current selected item in the master column
 * @return The view model associated to the current selected item in the master column
 */
-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath;


@end

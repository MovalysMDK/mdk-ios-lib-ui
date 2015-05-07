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




@protocol MFDetailViewControllerProtocol;
@protocol MFUIBaseViewModelProtocol;

@protocol MFFormWithDetailViewControllerProtocol <NSObject>

@required
/*!
 * @brief This method should be implemented to update the components in a cell of a form with the values changed in detailController
 * @param indexPath The indexPath of the cell in which the components will be updated
 * @param valuesForComponents A dictionary containing the name of the component to update as key, and the new Value for the component as value (or entry).
 */
-(void) updateChangesFromDetailControllerOnCellAtIndexPath:(NSIndexPath *)indexPath withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel;

@required
/*!
 * @brief The method should return the detail view controller to use to edit an item
 * @returns A MFFormDetailViewController object.
 */
-(id<MFDetailViewControllerProtocol>) detailController;


@end

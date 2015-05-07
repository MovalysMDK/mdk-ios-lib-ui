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



@protocol MFFormWithDetailViewControllerProtocol;
@protocol MFUIBaseViewModelProtocol;


/**
 * @brief Doit être implémenté par les contrôleurs des vues dites de détail (idétails d'un item de liste, détails d'une photo, etc)
 */
@protocol MFDetailViewControllerProtocol <NSObject>


#pragma mark - Properties

/**
 * @brief This attribute is the parent controller which opens this detailController
 */
@property (nonatomic, weak) id<MFFormWithDetailViewControllerProtocol> parentFormController;

/**
 * @brief This attribute is the indexPath of the current editing cell
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 * @brief Indicates if the components of this detail are editable or not.
 */
@property (nonatomic, strong) NSNumber *editable;

/**
 * @brief The original view model used to display detail data
 */
@property id<MFUIBaseViewModelProtocol> originalViewModel;

@end

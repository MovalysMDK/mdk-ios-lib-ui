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



#import "MFFormSearchExtend.h"

/**
 * @brief Classe d'extension du formulaire
 */
@interface MFFormExtend : NSObject

/**
 * @brief Extension de formulaire pour les formulaires de recherche
 */
@property (nonatomic, weak) MFFormSearchExtend *search;

/**
 * @brief Le nom du descripteur du formulaire
 */
@property(nonatomic, strong) NSString *formDescriptorName;

/**
 * @brief Le nom du descripteur de la vue statique (PickerList uniquement)
 */
@property(nonatomic, strong) NSString *sectionFormDescriptorName;

/**
 * @brief Le nom du descripteur de la vue statique (PickerList uniquement)
 */
@property(nonatomic, strong) NSString *headerFormDescriptorName;

/**
 * @brief La hauteur d'une cellule du formulaire
 */
@property(nonatomic) int editMode;

/**
 * @brief La hauteur d'une cellule du formulaire
 */
@property(nonatomic) int rowHeight;

/**
 * @brief Définit si ue item peut être ajouté au formulaire
 */
@property(nonatomic) BOOL canAddItem;

/**
 * @brief Définit si un item peut être édité
 */
@property(nonatomic) BOOL canEditItem;

/**
 * @brief Définit si un item peut être supprimmé
 */
@property(nonatomic) BOOL canDeleteItem;



@end



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



/*!
 * @brief Classe d'extension pour formulaire avec recherche
 */

@interface MFFormSearchExtend : NSObject 

/*!
 * @brief Définit si la recherche est simple (sur un seul élément)
 */
@property (nonatomic) BOOL simpleSearch;

/*!
 * @brief Définit si la recherche doit être faite en direct (uniquement pour le cas d'une recherche simple).
 */
@property (nonatomic) BOOL liveSearch;

/*!
 * @brief Définit si le nombre de résultats doit être affiché.
 */
@property (nonatomic) BOOL displayNumberOfResults;

@end




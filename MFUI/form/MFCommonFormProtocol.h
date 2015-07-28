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

#import "MFFormValidationDelegate.h"
#import "MFUIBaseViewModelProtocol.h"
#import "MFObjectWithBindingProtocol.h"

@protocol MFUIComponentProtocol;

@protocol MFCommonFormProtocol <MFObjectWithBindingProtocol>


#pragma mark - Properties

/*!
 * @brief formValidationDelegate
 */
@property( nonatomic, strong) MFFormValidationDelegate *formValidation;


#pragma mark - Methods


@optional
/*!
 * @brief Cette méthode permet de définir la hauteur d'une cellule du formulaire à une position donnée
 * En effet, un tableView définit lui même la hauteur de ses cellules, mais avant de connaître son contenu. 
 * En cas de contenu dynamique, cette méthode permet donc de définir la bonne taille de la cellule et recharger
 * la liste avec la nouvelle taille
 * @param height La hauteur de la cellule
 * @param indexPath La position de la cellule dont on souhaite déterminer une nouvelle taille
 */
-(void) setCellHeight:(float)height atIndexPath:(NSIndexPath *)indexPath;


/*!
 * @brief Creates the binding structure for thix object with binding
 */
-(void) createBindingStructure;

@end

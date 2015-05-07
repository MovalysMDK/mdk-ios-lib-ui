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


#import "MFBindingFormDelegate.h"

@interface MFBaseBindingForm : NSObject <MFBindingFormDelegate>

#pragma mark - Propriétés

/*!
 * @brief Le tableau des ressources bloquées par mutex
 */
@property(nonatomic, weak) UIControl *activeField;

/*!
 * @brief Le tableau des ressources bloquées par mutex
 */
@property(nonatomic, strong) NSArray *mutexPropertiesName;

/*!
 * @brief Le parent tenant ce delegate
 */
@property (nonatomic, weak) id<MFBindingFormDelegate> parent;

/*!
 * @brief Cette propriété liste l'ensemble des composants de ce formumaire candidats au binding
 * avec un ViewModel
 */
@property(nonatomic, strong) MFBinding *binding;

/*!
 * @brief Cette propriété définit un dictionnaire des propriétés qui sont bindables,
 * et leur valeurpar défaut possibles
 */
@property(nonatomic, strong) NSMutableDictionary *bindableProperties;

/*!
 * @brief Cette propriété liste les un ensemble de propriétés des champs qui doivent être écoutés.
 * Chacune de ces propriétés "bindable" est liée à un ensemble de champs qui l'écoute.
 * @example : la propriété "champAMandatory" a été renseigné dans un PLIST d'un formulaire comme propriété
 * bindée pour la valeur "mandatory" d'un composant niommé "ChampA". Ce dictionnaire contient la clé "champAMandatory"
 * qui a pour valeur un dictionnaire contenant une entrée avec la clé "champA" et la valeur "mandatory".
 * Ainsi lorsque la propriété "champAMandatory" du viewModel change, on peut récupérer le champ qui l'écoute, et la
 * propriété du champ à laquelle on va affecter la nouvelle valeur de "champAMandatory"
 */
@property(nonatomic, strong) NSMutableDictionary * propertiesBinding;

/*!
 * @brief Cette propriété contient un dictionnaire de block contenant des actions à effectuer pour
 * continuer ou non la mise à jour d'un champ graphique depuis le modèle. Ces blocks sont de type
 * MFValueChangedFilter et renvoient un booléen pour annoncer si la synchronisation de ce champ doit
 * continuer ou non
 */
@property (nonatomic, strong) NSDictionary* filtersFromViewModelToForm;

/*!
 * @brief Cette propriété contient un dictionnaire de block contenant des actions à effectuer pour
 * continuer ou non la mise à jour d'un champ graphique depuis le formulaire. Ces blocks sont de type
 * @see(MFValueChangedFilter) et renvoient un booléen pour annoncer si la synchronisation de ce champ doit
 * continuer ou non
 */
@property (nonatomic, strong) NSDictionary* filtersFromFormToViewModel;

#pragma mark - Méthodes

/*!
 * @brief Cette méthode construit cette classe avec un parent
 * @param Le parent de ce delegate
 * @return Une instance de ce delegate
 */
-(id)initWithParent:(id<MFBindingFormDelegate>) parent;

/*!
 * @brief Cette méthode permet de réinitialiser les propriétés dynamiques du binding telles que binding ou bindingProperties.
 */
-(void) reinit;

@end

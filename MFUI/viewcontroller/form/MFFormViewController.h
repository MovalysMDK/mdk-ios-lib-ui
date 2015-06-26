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



#import "MFFormBaseViewController.h"


FOUNDATION_EXPORT NSString *const MFPROP_FORM_ONUNSAVEDCHANGES;

/*!
    Controlleur de formulaire, fait le lien entre la réprésentation xml du formulaire et sa représentation graphique.
    Gère l'ensemble des cellules d'un formulaire.
 */
@interface MFFormViewController : MFFormBaseViewController


#pragma mark - Propriétés

/*!
 * @brief Options fournies pour le chargement des données
 */
@property (nonatomic, strong) NSDictionary *loadingOptions;
/*!
 * @brief Tableau des identifiants d'instance de modèles sou forme de NSNumber *
 */
@property (nonatomic, strong) NSArray *ids;


#pragma mark - Méthodes

/*!
 * @brief Cette méthode permet de faire les initialisations nécessaires au bon fonctionnement du controller
 * Cette méthode devra notamment être implémentée par l'utilisateur dans son propre FormViewController afin qu'il
 * définisse le viewModel associé à son propre FormViewcontroller.
 */
-(void) initialize;

/*!
 * @brief Permet de lancer l'action de chargement des données
 */
-(void) doFillAction;

/*!
 * @brief Return the name of the data loader
 */
-(NSString *) nameOfDataLoader ;

/*!
 * @brief Return the name of the view model
 */
-(NSString *) nameOfViewModel ;


//-(BOOL) addError:(id)error onComponent:(NSString *)bindingKey;


- (void) doOnKeepModification:(id)sender ;

/*!
 * @brief Indicates if the controller use  partial viewModels
 */
-(BOOL) usePartialViewModel;

/*!
 * @brief The names of the view Models used by the controller 
 */
-(NSArray *) partialViewModelKeys;

@end

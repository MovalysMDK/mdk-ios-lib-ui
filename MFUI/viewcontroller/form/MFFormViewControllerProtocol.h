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


//iOS imports


//Protocol
#import "MFViewControllerProtocol.h"


//Validation
#import "MFFormViewControllerValidationDelegate.h"


/*!
 * MFFormViewControllerProtocol
 */
@protocol MFFormViewControllerProtocol <MFViewControllerProtocol>

typedef enum {
    MFFormTypeSimple = 0,
    MFFormTypeForm = 1,
    MFFormTypeMixte = 2
} MFFormType;


#pragma mark - Properties



#pragma mark - Methods

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
 * @brief Create/Get the view model
 */
-(id<MFUIBaseViewModelProtocol>) createViewModel;

/*!
 * @brief Cette méthode est appelée lorsque l'un des composants graphiques présents dans le dictionnaire "mapping"
 * a été modifié. La méthode met alors à jour les champs associés dans le ViewModel
 * @param bindingKey La clé de mapping qui identifie le ou les composants concernés
 */
-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath valid:(BOOL)valid;

/*!
 * @brief Indique si le bouton de sauvegarde doit être affiché ou non. 
 * Par défaut, le framework affiche le bouton si au moins un composant du formulaire est éditable
 * @return YES si le bouton doit être affiché, NO sinon
 */
@optional
-(BOOL)showSaveButton;
@end

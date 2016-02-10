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
//  MFBindingFormDelegate.h
//  MFUI
//
//

#import <MFCore/MFCoreFormDescriptor.h>

#import "MFUIForm.h"
#import "MFBinding.h"
#import "MFUIBaseViewModelProtocol.h"

@protocol MFUIComponentProtocol;

@protocol MFBindingFormDelegate <NSObject>


#pragma mark - Properties

/**
 * @brief formValidationDelegate
 */
@property( nonatomic, strong) MFFormValidationDelegate *formValidation;



/**
 * @brief  A mutable array containing the current reusable cell for this form. 
 * When a new cell is created, it is added to this array, and that last is used to reuse the cell the next times
 */
@property (nonatomic, strong) NSMutableArray *reusableBindingViews;

/**
 * Form which contains the element.
 */
@property(nonatomic, strong) MFFormDescriptor* formDescriptor;

/**
 * @brief Le ViewModel associé à ce formulaire. il peut s'agir d'un ViewModel simple contenant différents
 * types de champs( => viewModel de type MFUIBaseViewModel) ou un ViewModel de type "liste" qui contient une liste
 * d'autres viewModels ( => viewModel de type MFUIBaseListViewModel ).
 */
@property(nonatomic, strong) id<MFUIBaseViewModelProtocol> viewModel;


#pragma mark - Methods
/**
 * @brief Renvoie le binding Cellule<->Composants
 * @return Le binding
 */
-(MFBinding *)binding;

/**
 * @brief Renvoie la liste des filtres à appliquer avant une mise à jour du viewModel vers le formulaire
 * @return Un dictionnaire contenant des filtres
 */
-(NSDictionary *)filtersFromViewModelToForm;

/**
 * @brief Renvoie la liste des filtres à appliquer avant une mise à jour du formulaire vers le ViewModel
 * @return Un dictionnaire contenant des filtres
 */
-(NSDictionary *)filtersFromFormToViewModel;

/**
 * @brief Renvoie la liste des bindableProperties définies dans le PLIST principal du projet.
 * Cette liste définit des propriétés qui peuvent être spécifiées dans les PLIST décrivant les formulaires
 * @return un dictionnaire contenant la liste des bindableProperties et leurs spécifications
 */
-(NSDictionary *)bindableProperties;

/**
 * @brief Renvoie un dictionnaire de propriétés bindées au formulaire. Ces propriétés ne correspondent pas à la valeur
 * d'un composant du formulaire, mais à un certaine propriété d'un composant (comme la mention mandatory ou la couleur
 * de fond du champ), dont la valeur est définie dans le ViewModel
 * Pour chaque composant du formulaire et pour chaque propriétés de ce dictionnaire, une setter sera généré selon son nom,
 * et appliquera la valeur définie dans le PLIST (peut être une valeur par défaut définie dans les spécifications des 
 * bindalbeProperties, ou une valeur définie par une propriété sur le ViewModel).
 * @return Un dictionnaire contenant les properties binding
 */
-(NSMutableDictionary *)propertiesBinding;


/**
 * @brief Définit ou met à jour le binding
 * @param mB Le nouveau binding
 */
-(void)setBinding:(NSMutableDictionary *)mB;

/**
 * @brief Définit ou met à jour les filtres de mise à jour Formulaire --> ViewModel
 * @param mB Les nouveaux filtres
 */
-(void)setFiltersFromFormToViewModel:(NSDictionary *)filters;

/**
 * @brief Définit ou met à jour les filtres de mise à jour  ViewModel --> Formulaire 
 * @param mB Les nouveaux filtres
 */
-(void)setFiltersFromViewModelToForm:(NSDictionary *)filters;

/**
 * @brief Définit ou met à jour les propertiesBinding
 * @param mB Les nouvelles propriétés
 */
-(void)setPropertiesBinding:(NSMutableDictionary *)propertiesBinding;

/**
 * @brief Définit ou met à jour les bindableProperties
 * @param mB Les nouvelles propriétés
 */
-(void)setBindableProperties:(NSDictionary *)bindablePropertie;

@required
/**
 * @brief renvoie le ViewModel associé à ce binding
 * @param Un ViewModel (simple ou de liste) associé à ce binding
 */
-(id<MFUIBaseViewModelProtocol>) getViewModel;

/**
 * @brief Cette méthode permet de bloquer une ressource le temps de son traitement. Le nom identifiant
 * la ressource est ajoutée à un tableau jusqu'à son relâchement
 * @param propertyName Le nom de la resource dont on souhiate bloquer l'accès pendant le traitement
 * @return Un booléen VRAI si la resource est n'est déjà bloquée (et donc le traitement de la ressource est autorisé),
 * FAUX sinon.
 */
-(BOOL)mutexForProperty:(NSString *)propertyName;

/**
 * @brief Cette méthode relâche une ressource bloquée par mutex (@see mutexForProperty:)
 * @param propertyName Le nom de la ressource que l'on souhaite débloquer
 */
-(void)releasePropertyFromMutex:(NSString *)propertyName;

/**
 * @brief Cette méthode permet de récupérer un clé de binding complète à partir de la clé de base
 * et de l'indexPath correspondant à cette clé de binding
 * @param key La clé de base
 * @param indexPath L'indexPath correspondant à la cellule du composant bindé
 * @return La clé complète de binding de la forme "nomdelacle_X_Y" avec X la section de
 * de l'indexPath et Y la ligne dans la section Y de l'indexPath
 */
-(NSString *)bindingKeyWithIndexPathFromKey:(NSString *)key andIndexPath:(NSIndexPath *)indexPath;


/**
 * @brief Cette méthode permet de récupérer une clé de binding simple à partir d'une clé complète
 * @param key La clé complète de binding
 * @return la clé simp^le de binding
 */
-(NSString *)bindingKeyFromBindingKeyWithIndexPath:(NSString *)key;


/**
 * @brief Cette méthode permet de récupérer un indexPath à partir d'une clé complète de binding
 * @param key La clé complète de binding
 * @return l'indexPath extrait de la clé complète de binding
 */
-(NSIndexPath *)indexPathFromBindingKeyWithIndexPath:(NSString *)key;

/**
 *@brief Cette méthode permet de désenregistrer l'ensemble des composants au préalable enregistrés sur ce controller
 */
-(void)unregisterAllComponents;

/**
 * @brief Cette méthode génère un Seclector à partir du nom d'une propriété.
 * @example Pour la propriété "name" la méthode va générer le sélecteur "setName:"
 * @param propertyName Le nom de la propriété pour laquelle on veut obtenir un sélecteur
 * @return Une chaine de caractère représentant un sélecteur
 */
-(NSString *) generateSetterFromProperty:(NSString *)propertyName;


/**
 * @brief Cette méthode permet d'initialiser  (graphiquement) le composant passé en paramètre
 * à partir des données du PLIST du formulaire
 * @param component Le composant à initialiser
 */
-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief Cette méthode permet de traiter un sélecteur dans le thread UI.
 * Ceci est nécessaire pour l'initialisation des composants. Toutes les initialisation
 * possibles du composant doivent être appliquée ici : mandatory, couleur, valeur etc ...
 * @param selector Le sélecteur à appliquer sur le composant. Ce sélecteur doit être une méthode
 * existante dans le comoosant
 * @param component Le composant sur lequel on veut appliquert le sélecteur
 * @param object Le paramètre éventuel du sélecteur
 */
-(void)performSelector:(SEL)selector onComponent:(id<MFUIComponentProtocol>)component withObject:(id)object;

/**
 * @brief Cette méthode applique le convertisseur sur un composant, à partir de la valeur et du sens de conversion passé en paramètres
 * @param component Le composant sur lequel on veut appliquer la conversion
 * @param value La valeur source et cible de la conversion
 * @param formToViewModel Un booléen indiquant le sens de la conversion
 * @return La valeur convertie (ou non)
 */
-(id) applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel;

/**
 * @brief Cette méthode applique le convertisseur sur un composant, à partir de la valeur et du sens de conversion passé en paramètres
 * @param component Le composant sur lequel on veut appliquer la conversion
 * @param value La valeur source et cible de la conversion
 * @param formToViewModel Un booléen indiquant le sens de la conversion
 * @return La valeur convertie (ou non)
 */
-(id) applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel;


@optional
/**
 * @brief Cette méthode permet de définir la hauteur d'une cellule du formulaire à une position donnée
 * En effet, un tableView définit lui même la hauteur de ses cellules, mais avant de connaître son contenu. 
 * En cas de contenu dynamique, cette méthode permet donc de définir la bonne taille de la cellule et recharger
 * la liste avec la nouvelle taille
 * @param height La hauteur de la cellule
 * @param indexPath La position de la cellule dont on souhaite déterminer une nouvelle taille
 */
-(void) setCellHeight:(float)height atIndexPath:(NSIndexPath *)indexPath;

-(BOOL) addError:(id)error onComponent:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath;

@end

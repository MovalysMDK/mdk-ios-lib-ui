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
//  MFUIBaseViewModel.h
//  MFUI
//
//
#import <MFCore/MFCoreContext.h>

#import "MFUIBinding.h"
#import "MFUIControl.h"

#import "MFUIBaseViewModelProtocol.h"
#import "MFFormBaseViewController.h"

@interface MFUIBaseViewModel : NSObject <MFUIBaseViewModelProtocol, NSCopying>

#pragma mark - Types définis

/*!
 * @brief Type de callback appelé lorsque l'appli sait combien elle possède de classe de démarrage
 * @param 1er paramètre le nom de classe ou l'étape lancée
 * @param 2eme paramètre l'état du lancement (START, STOP)
 */
typedef BOOL (^MFValueChangedFilter)(NSString *, id<MFUIBaseViewModelProtocol>, MFBinding *);

#pragma mark - Properties

/*!
 * @brief Cette propriété définit le ViewModel Parent. Si cette propriété reste nulle, 
 * alors ce ViewModel est le plus haut parent
 */
@property (nonatomic, weak) id<MFUIBaseViewModelProtocol> parentViewModel;

/*!
 * @brief Cette propriété indique si un changement a eu lieu. Cette propriété est nécessaire
 * pour savoir s'il faut sauvegarder de nouvelles données.
 */
@property (nonatomic, strong) NSString *parentViewModelPrefix;

/*!
 * @brief A dictionary containing as key/value pair : 
 * key : the name of a viewModel
 * value : the value of the filter to apply on a property of the viewModel
 */
@property (nonatomic, strong) NSDictionary *filterParameters;

#pragma mark - Methods

//non implemented
//-(id)initWithForm:(id<MFViewModelChangedListenerProtocol>) form;
/*!
 * @brief Définir ici les actions à effectuer lorsque l'un des champs synchronizables du ViewModel a été modifié
 * @see NSKeyValueObserving.h
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

/*!
 * @brief Cette méthode doit être implémentée dans les classes héritées de @MFUIBaseViewModel seulement.
 * Elle permet de définir les propriétés qui sepont bindées au formulaire.
 * @return Un tableau comporant le nom des propriétés de la classe candidates au bind avec le formulaire.
 * Ce tableau ne doit pas contenir d'autres propriétés autre que celles de la classe qui implémente cette méthode.
 */
-(NSArray*)getBindedProperties;

/*!
 * @brief Cette méthode doit être implémentée dans les classes héritées de @MFUIBaseViewModel seulement.
 * Elle permet de définir les propriétés personnalisées qui seront bindées au formulaire.
 * @return Un tableau comporant le nom des propriétés de la classe candidates au bind avec le formulaire.
 * Ce tableau ne doit pas contenir d'autres propriétés autre que celles de la classe qui implémente cette méthode.
 */
-(NSArray*)getCustomBindedProperties;

/*!
 * @brief get child viewmodels (property names)
 */
-(NSArray *) getChildViewModels;

/*!
 * @brief Cette méthode renvoie la liste des propriétés à copier lors de la copie du ViewModel
 * Par défaut il s'agit des bindedProperties et des customBindedProperties
 */
-(NSArray *)getCopyProperties;

/*!
 * @brief Clear this view model.
 */
- (void) clear;

/*!
 * @brief update viewmodel with entity
 * @param entity
 */
-(void) updateFromIdentifiable:(id) entity ;

/*!
 * @brief update entity with viewmodel
 * @param entity
 */
-(void) modifyToIdentifiable:(id)entity inContext:(id<MFContextProtocol>)context ;

@end

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

#import "MFUIComponentProtocol.h"

@protocol MFBindingViewProtocol <NSObject>


#pragma mark - Properties
/**
 Descriptor of form which contains this view
 */
@property(nonatomic, strong) MFFormDescriptor *formDescriptor;

/**
 * @brief Indicates if this view has changed (and need to register components).
 */
@property(nonatomic) BOOL hasChanged;

/**
 * @brief This is the controller of this view. This controller contains a forms.
 */
@property (nonatomic, weak) id<MFBindingFormDelegate> formController;


@required
#pragma mark - Methods

/**
 * @brief Cette méthode prend en paramètre un composant de la viewule qui doit être bindé.
 * Le composant est ajouté au dictionnaire de binding du formulaire si celui-ci n'a pas déjà été ajouté
 * Cette méthode est spécifique à cette viewule car elle suppose une viewule composé d'un champ principal et d'un label
 * @param component Le composant a ajouté au binding
 * @param formController Le formulaire sur lequel on souhaite bindé ce composant
 * @return Un dictionnaire contenant le ou les nouveaux éléments bindés (ici un seul).
 */
-(NSMutableDictionary *) addComponent:(id<MFUIComponentProtocol>) component
                  toBindingOnForm:(id<MFBindingFormDelegate>) formController;

/**
 * @brief Cette méthode enregistrer pour le champ passé en paramètre, ses propriétés bindables.
 * @param le composant dont on souhaite enregistrer des propriétrés dans le bindingProperties
 * @param formController Le formulaire contenant les binding entre des propriétés du ViewModel
 * et des propriétés du composant.
 */
-(void) registerBindablePropertiesFromComponent:(id<MFUIComponentProtocol>) component
                      toPropertiesBindingOnForm: (id<MFBindingFormDelegate>) formController;

/**
 * @brief Cette méthode permet de valider ou non la valeur d'une propriété bindable.
 * @example la propriété bindable "mandatory" peut valoir YES, NO ou le nom d'une propriété
 * à binder sur le ViewModel. Si elle vaut YES ou NO, on la considère comme non valide pôur le binding
 * @param valueOfBindableProperty La valeur de la potentielle propriété bindable
 * @param property La propriété sur laquelle on veut tester la valeur
 * @param formController Le View Controller du formulaire contenant la liste des bindableProperties avec les valeurs autorisées
 * @return YES si la valeur est valide pour le binding, NO sinon.
 */
-(BOOL) isBindablePropertyValueCorrect:(NSString *) valueOfBindableProperty forProperty:(NSString *) property fromFormController:(id<MFBindingFormDelegate>) formController;

/**
 * @brief This method refresh the view graphically by resetting the fields
 */
-(void) refreshComponents;

/**
 * @brief Allows to remove all components from the binding of the givent formController of this view
 * @param formController The form controller in which the components will be removed
 */
-(void)unregisterComponents:(id<MFBindingFormDelegate>)formController;

@end


#pragma mark - MFBindingComponentDescriptor Class

/**
 * @brief Cette classe est un descripteur pôur le binding des propriétés/composants.
 */
@interface MFBindingComponentDescriptor : NSObject

/**
 * @brief La bindableProperty concernée
 */
@property (nonatomic, strong) NSString * bindableProperty;

/**
 * @brief Le descripteur du composant associé à la bindable property
 */
@property (nonatomic, strong) MFFieldDescriptor * componentDescriptor;



@end


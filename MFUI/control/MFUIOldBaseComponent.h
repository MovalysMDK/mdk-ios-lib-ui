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
//  MFUIOldBaseComponent.h
//  MFUI
//
//
//

//iOS Framework imports


//MFCore
#import <MFCore/MFCoreFormDescriptor.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreError.h>

//MFCore Log
#import "MFUILog.h"

//Cell
#import "MFFormCellProtocol.h"

//Components
#import "MFUIComponentProtocol.h"

//Tags
#import "MFViewTags.h"

//Tooltip
#import "MFUIControlTooltip.h"
#import "MFUIError.h"

//Framework constants

/*!
 * @class MFUIOldBaseComponent
 * @brief The main class for all framework components
 * @discussion It represents a base framework component.
 * @discussion It allows to represent any kind of components (label, texfield, slider ...), with the benefits of binding.
 * @discussion This class allows to add an error button associated to a tooltip when the error button is clicked.
 * @warning If you need to create a custom component binded with the framework, you ALWAYS should inherits this class. If your custom component have some basic methods of another basic iOS component, you can combine with a category that forwards needed methods and properties
 */
@interface MFUIOldBaseComponent : UIControl<MFUIComponentProtocol>



#pragma mark - Properties

/*!
 * Bouton indiquant une erreur
 */
@property (nonatomic, strong) UIButton *baseErrorButton;

/*!
 * @brief The component that holds or has created this component
 */
@property (nonatomic, weak) MFUIOldBaseComponent *sender;

/*!
 * Info-bulle affichant la liste des erreurs
 */
@property (nonatomic, strong) TooltipView *baseTooltipView;

/*!
 * Liste des erreurs du composant
 */
@property (nonatomic, strong) NSMutableArray *baseErrors;

/*!
 * MF Parent Composant
 */
@property (nonatomic, weak) MFUIOldBaseComponent *mfParent;

/*!
 * initialisation
 */
@property (nonatomic) BOOL applySelfStyle;

/*!
 * initialisation
 */
@property (nonatomic, strong) NSNumber *parentEditable;

/*!
 * @brief The class abstract object this component should used to apply style.
 * @discussion This property is computed at runtime following the style's priority.
 */
@property  (nonatomic) Class baseStyleClass;


#pragma mark - Inspectable Methods
/*!
 * @brief This property enables or disables the override of the IB Style on the code style
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable BOOL IB_enableIBStyle;


#pragma mark - Methods

/*!
 * @brief Custom init that initialize the component with a specified frame, on set another sender component.
 * @param frame The frame opf the created componenty
 * @param sender The component that holds this component
 * @return The created component.
 */
- (instancetype)initWithFrame:(CGRect)frame withSender:(MFUIOldBaseComponent *)sender;

/*!
 * @brief Initialise certains propriétés de la classe
 */
-(void) initialize;

/*!
 * @brief Permet de masquer le bouton baseErrorButton
 */
-(void)hideErrorButtons;

/*!
 * @brief Permet d'afficher le bouton baseErrorButton
 */
-(void)showErrorButtons;

/*!
 * @brief Permet de redimensionner le composant après avoir affiché le bouton baseErrorButton
 */
-(void)modifyComponentAfterShowErrorButtons;

/*!
 * @brief Permet de redimensionner le composant après avoir masqué le bouton baseErrorButton
 */
-(void)modifyComponentAfterHideErrorButtons;

/*!
 * @brief Affiche l'info-bulle contenant la liste des erreurs
 */
-(void)showErrorTooltips;

/*!
 * @brief Masque l'info-bulle contenant la liste des erreurs
 */
-(void)hideErrorTooltips;

/*!
 * @brief Permet de vider la liste des erreurs
 */
-(void) clearErrors;

/*!
 * @brief Permet d'ajouter des erreurs à la liste des erreurs
 * @param errors Une liste d'erreurs à ajouter
 */
-(void) addErrors:(NSArray *) errors;

/*!
 * @brief Action appelée lorsque l'utilisateur tape sur le bouton indiquant qu'il y a des erreurs sur le composant
 */
-(void)toggleErrorInfo;

/*!
 * @brief Chargement des configurations
 * @param Le nom de la configuration à charger
 * @return Une configuration
 */
-(MFConfigurationUIComponent *) loadConfiguration:(NSString *) configurationName;

/*!
 * @brief Cette méthode est appelée dès que la valeur du composant est modifiée.
 * Elle permet la synchronisation du formulaire avec le ViewModel
 * @return Un block dont le code est exécuté dès que la valeur du champ est modifiée
 */
-(void)updateValue:(id) newValue;

/*!
 * @brief This method is called after the STYLE has been applied to the component and the subcomponents of its method.
 * You can do some customizations here on the component
 */
-(void) selfCustomization;

/*!
 * @brief This method is called after the selfDescriptor has been set
 */
-(void) didFinishLoadDescriptor __attribute__((deprecated("Use method didLoadFieldDescriptor: instead")));

/*!
 * @brief This method is called after the selfDescriptor has been set
 * @param fieldDescriptor The complete fieldDescriptor of this component
 */
-(void) didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor;

/*!
 * @brief Set the parameters for this component
 */
-(void) setComponentParameters:(NSDictionary *)parameters;

#pragma mark - Live Rendering Methods

/*!
 * @brief Add views to this components and static attributes of those views.
 * @discussion This method is mandatory
 */
-(void) buildDesignableComponentView;

/*!
 * @brief Implement here the behaviour of the inspectable attributes in order to
 * render the component dynamically in InterfaceBuilder
 * @discussion This method is mandatory.
 */
-(void) renderComponentFromInspectableAttributes;

/*!
 * @brief Before to implement the behaviour of the inspectables attributes on this component,
 * you should define here some default values for these inspectable attributes.
 * @discussion This method is mandatory. Be careful, if no value is specified, the component should
 * have a wrong rendering. For example, nil value on an inspectable attribute of type (UIColor *)
 * will render a black color for this inspectable attribute.
 */
-(void) initializeInspectableAttributes;

/*!
 * @brief Implement here some treatment you would do in layoutSubviews but you
 * wish not that it will be rendered on InterfaceBuilder. This method is called before
 * parent layoutSubviews method.
 * @discussion This method is optional;
 */
-(void) willLayoutSubviewsNoDesignable;

/*!
 * @brief Implement here some treatment you would do in layoutSubviews but you
 * wish not that it will be rendered on InterfaceBuilder. This method is called after
 * parent layoutSubviews method.
 * @discussion This method is optional;
 */
-(void) didLayoutSubviewsNoDesignable;

/*!
 * @brief Implement here some treatment you would do in layoutSubviews but you
 * wish not that it will be rendered on InterfaceBuilder. This method is called before
 * parent layoutSubviews method.
 * @discussion This method is optional;
 */
-(void) willLayoutSubviewsDesignable;

/*!
 * @brief Implement here some treatment you would do in layoutSubviews but you
 * wish not that it will be rendered on InterfaceBuilder. This method is called after
 * parent layoutSubviews method.
 * @discussion This method is optional;
 */
-(void) didLayoutSubviewsDesignable;

#pragma mark - Static methods

/*!
 * @brief Cette méthode réalise le merge entre les valeurs de configuration et de base du storyboard
 * @param configurationValue La valeur booléenne de base en configuration
 * @param defaultValue La valeur par défaut dans le storyboard
 * @return La valeur choisie en fonction des règles établies
 */
+(NSNumber *) getBoolConfigurationWithValue:(NSNumber *)configurationValue andDefaultValue:(NSNumber *)defaultValue;

/*!
 * @brief Cette méthode réalise le merge entre les valeurs de configuration et de base du storyboard
 * @param configurationValue La valeur numérique de base en configuration
 * @param defaultValue La valeur par défaut dans le storyboard
 * @return La valeur choisie en fonction des règles établies
 */
+(NSNumber *) getNumberConfigurationWithValue:(NSNumber *)configurationValue andDefaultValue:(NSNumber *)defaultValue;

/*!
 * @brief Cette méthode réalise le merge entre les valeurs de configuration et de base du storyboard
 * @param configurationValue La chaîne de caractères de base en configuration
 * @param defaultValue La valeur par défaut dans le storyboard
 * @return La valeur choisie en fonction des règles établies
 */
+(NSString *) getStringConfigurationWithValue:(NSString *)configurationValue andDefaultValue:(NSString *)defaultValue;


#pragma mark - Methods to delete (be sure before deleting it)

@end

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
//  MFUIComponentProtocol.h
//  MFUI
//
//



#import <MFCore/MFCoreContext.h>
#import <MFCore/MFCoreApplication.h>

#import "MFUIError.h"
#import "MFUIProtocol.h"

#import "MFComponentChangedListenerProtocol.h"
#import "MFUITransitionDelegate.h"
#import "MFFormCellProtocol.h"

@protocol MFUIGroupedElementCommonProtocol;


#pragma mark - Properties

/**
 * This protocol is used by the MOVALYS Generic Form to fit the process to the UI component.
 * All MOVALYS UI element must implement this protocol.
 */
@protocol MFUIComponentProtocol <MFUIGroupedElementCommonProtocol>

/**
 UI control display name.
 */
@property(nonatomic, strong) NSString *localizedFieldDisplayName;

/**
 Current execution context.
 */
@property(nonatomic, strong) id<MFContextProtocol> context;

/**
 Transition delegate uses to open a new controller.
 */
@property(nonatomic, weak) id<MFUITransitionDelegate> transitionDelegate;

/**
 Current component's descriptor.
 */
@property(nonatomic, weak) NSObject<MFDescriptorCommonProtocol> *selfDescriptor;

/**
 Application Context
 */
@property(nonatomic, strong) MFApplication *applicationContext;

/**
 Indicate if the control is valid.
 */
@property(nonatomic) BOOL isValid;

/**
 Le formulaire qui contient ce composant 
 */
@property (nonatomic, weak) id<MFComponentChangedListenerProtocol> form;
 

/**
 Indique si le composant est obligatoire
 */
@property (nonatomic, strong) NSNumber *mandatory;


/**
 Indique si le composant est obligatoire
 */
@property (nonatomic) NSNumber *visible;

/**
 Indique si le composant est éditable
 */
@property (nonatomic) NSNumber *editable;

/**
 * @brief L'IndexPath de la cellule dans laquelle se trouve ce composant.
 */
@property (nonatomic, strong) NSIndexPath *componentInCellAtIndexPath;

/**
 * @brief Indique si le composant a le focus
 */
@property(nonatomic) BOOL hasFocus;

@property (nonatomic, weak) id lastUpdateSender;



 
#pragma mark - Methods

/**
 * Validate the ui component value.
 * @param parameters - parameters from the page
 * @return Number of errors detected by the UI component
 */
-(NSInteger) validateWithParameters:(NSDictionary *)parameters;

/**
 * Validate the ui component value.
 * @return Number of errors detected by the UI component
*/
-(NSInteger) validate;

/**
 * Clean all component errors 
 */
-(void) clearErrors;

/**
 * Clean all component errors
 * @param anim use animation
 */
-(void) clearErrors:(BOOL)anim;

/**
 * @brief get errors on component
 * @return errors
 */
-(NSArray *) getErrors;

/*
 * Add errors to component.
 */
-(void) addErrors:(NSArray *) errors;

/*
 * Setter of selfDescriptor 
 */
-(void)setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor;

/*
 * Returns YES if the component isActive (enabled)
 */
-(BOOL) isActive;

/*
 * Set if the component is active (enabled)
 */
-(void) setIsActive:(BOOL)isActive;

/**
 * @brief Retourne le type de donnée géré par le composant
 */
+ (NSString *) getDataType;

/**
 * @brief Cette méthode met à jour la valeur de ce composant
 * @param data La nouvelle valeur de ce composant
 */
-(void) setData:(id)data;

/**
 * @brief Cette méthode met à jour la valeur de ce composant
 * @param data La nouvelle valeur de ce composant
 * @param shouldUpdateAfterSettingData Indique si la valeur doit être mise à jour dans le ViewModel après avoir affecté la valeur
 */
-(void)setData:(id)data andUpdate:(BOOL)shouldUpdateAfterSettingData;

/**
 * @brief Cette méthode retourne la valeur de ce composant
 * @return data La valeur de ce composant
 */
-(id)getData;

/**
 * @brief show errors on components (tooltip and icon)
 */
-(void)showErrorButtons ;

/**
 * @brief hide errors on components (tooltip and icon)
 */
-(void)hideErrorButtons ;


@optional
/**
 * @brief Returns a list of sub-components of this component that could be customized with a custom CSS class
 * @return An array of sub-components that are customizable in this component
 */
-(NSArray *)customizableComponents;


@optional
/**
 * @brief Returns a list of suffix of CSS class for the customizable components of this component
 * @return A array of string that are the suffixes
 */
-(NSArray *)suffixForCustomizableComponents;

@optional
/**
 * @brief Allows to define a specific alignment for the component.
 * Each component should manage its alignment
 * @param alignValue The NSTextAlignment value of the alignment to set
 */
-(void) setComponentAlignment:(NSNumber *)alignValue;


@optional
-(void) setTextColor:(UIColor *) color;


@end

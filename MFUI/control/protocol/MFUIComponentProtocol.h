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


#import <MFCore/MFCoreContext.h>
#import <MFCore/MFCoreApplication.h>

#import "MFUIErrorView.h"
#import "MFUIProtocol.h"

#import "MFComponentChangedListenerProtocol.h"
#import "MFUITransitionDelegate.h"
#import "MFFormCellProtocol.h"
#import "MFComponentBindingProtocol.h"

#import  "MFComponentBindingDelegate.h"
#import "MFComponentErrorProtocol.h"
#import "MFComponentPropertiesProtocol.h"
#import "MFComponentValidationProtocol.h"
#import "UIView+Styleable.h"

@protocol MFUIGroupedElementCommonProtocol;
@protocol MFStyleProtocol;
@protocol MFFormCellProtocol;


/**
 * This protocol is used by the MOVALYS Generic Form to fit the process to the UI component.
 * All MOVALYS UI element must implement this protocol.
 */
@protocol MFUIComponentProtocol <MFUIGroupedElementCommonProtocol, MFComponentBindingProtocol, MFComponentErrorProtocol, MFComponentPropertiesProtocol, MFComponentValidationProtocol>

#pragma mark - Properties

@property (nonatomic, strong) MFComponentBindingDelegate *bindingDelegate;

/**
 * @brief UI control display name.
 */
@property(nonatomic, strong) NSString *localizedFieldDisplayName;

/**
 * @brief Transition delegate uses to open a new controller.
 */
@property(nonatomic, weak) id<MFUITransitionDelegate> transitionDelegate;

/**
 * @brief Current component's descriptor.
 */
@property(nonatomic, weak) NSObject<MFDescriptorCommonProtocol> *selfDescriptor;

/**
 * @brief Le formulaire qui contient ce composant
 */
@property (nonatomic, weak) id<MFComponentChangedListenerProtocol> form;

/**
 * @brief The name of the custom class to use to render component style
 */
@property (nonatomic, strong) NSString *styleClassName;

/**
 * @brief The instance of the style lass to use to render the component style.
 */
@property (nonatomic, strong) id<MFStyleProtocol> styleClass;

/**
 * @brief Indicates if the component self-validation is active
 */
@property (nonatomic) BOOL componentValidation;

/**
 * @brief initialisation
 */
@property (nonatomic) BOOL inInitMode;

/**
 * @brief L'IndexPath de la cellule dans laquelle se trouve ce composant.
 */
@property (nonatomic, strong) NSIndexPath *componentInCellAtIndexPath;

/**
 * @brief todo
 */
@property (nonatomic, weak) id lastUpdateSender;

/**
 * Cell container
 */
@property (nonatomic, weak) id<MFFormCellProtocol> cellContainer;



#pragma mark - Methods

/**
 * @brief Callback called when the Field Descriptor of the component has been loaded by the framework.
 * @discussion You should use this methods to be sure to have a full-initialized FieldDescriptor.
 * @param fieldDescriptor The FieldDescriptor of the component that has been loaded by the framework
 */
-(void) didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor;


@end

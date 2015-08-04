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

#import "MFUITransitionDelegate.h"
#import "MFFormCellProtocol.h"
#import "MFComponentBindingProtocol.h"

#import "MFCommonControlDelegate.h"

#import "MFComponentErrorProtocol.h"
#import "MFComponentPropertiesProtocol.h"
#import "MFComponentValidationProtocol.h"
#import "MFComponentAttributesProtocol.h"
#import "MFComponentAssociatedLabelProtocol.h"

#import "UIView+Styleable.h"

#import "MFStyleProtocol.h"
#import "MFFormCellProtocol.h"



/*!
 * This protocol is used by the MOVALYS Generic Form to fit the process to the UI component.
 * All MOVALYS UI element must implement this protocol.
 */
@protocol MFUIComponentProtocol < MFComponentBindingProtocol, MFComponentErrorProtocol, MFComponentPropertiesProtocol, MFComponentValidationProtocol, MFComponentAttributesProtocol, MFComponentAssociatedLabelProtocol>

#pragma mark - Properties

@property (nonatomic, strong) MFCommonControlDelegate *controlDelegate;

/*!
 * @brief UI control display name.
 */
@property(nonatomic, strong) NSString *localizedFieldDisplayName;

/*!
 * @brief Transition delegate uses to open a new controller.
 */
@property(nonatomic, weak) id<MFUITransitionDelegate> transitionDelegate;

/*!
 * @brief Current component's descriptor.
 */
@property(nonatomic, weak) NSObject<MFDescriptorCommonProtocol> *selfDescriptor;

/*!
 * @brief The name of the custom class to use to render component style
 */
@property (nonatomic, strong) NSString *styleClassName;

/*!
 * @brief The instance of the style lass to use to render the component style.
 */
@property (nonatomic, strong) NSObject<MFStyleProtocol> *styleClass;

/*!
 * @brief Indicates if the component self-validation is active
 */
@property (nonatomic) BOOL componentValidation;

/*!
 * @brief initialisation
 */
@property (nonatomic) BOOL inInitMode;

/*!
 * @brief L'IndexPath de la cellule dans laquelle se trouve ce composant.
 */
@property (nonatomic, strong) NSIndexPath *componentInCellAtIndexPath;

/*!
 * @brief todo
 */
@property (nonatomic, weak) id lastUpdateSender;


@end

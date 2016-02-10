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
//  MFLabel.h
//  MFUI
//
//

#import "MFUIControlExtension.h"

#import "MFUIComponentProtocol.h"
#import "MFUIBaseComponent.h"


IB_DESIGNABLE
/**
 * @class MFLabel
 * @brief The label framework component
 * @discussion
 */
@interface MFLabel : MFUIBaseComponent

FOUNDATION_EXPORT NSString * const MF_MANDATORY_INDICATOR;

#pragma mark - Propriétés

/**
 * @brief Cette propriété permet de personnaliser le texte de la mension "obligatoire"
 */
@property (nonatomic, strong) NSString *mandatoryIndicator;

/**
 * @brief Le composant principal vers lesquelles on "forward" certaines propriétés
 * @see MFLabel+UILabelForwarding.h
 */
@property (nonatomic, strong) UILabel *label;

#pragma mark - Inspectable Properties
/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic, strong) IBInspectable UIColor *IB_textColor;

/**
 * @brief The text size of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable NSInteger IB_textSize;

/**
 * @brief The text alignment of the component that implements this protocol.
 * @discussion This property is only used in InterfaceBuilder
 */
@property (nonatomic) IBInspectable NSInteger IB_textAlignment;

/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is only used in InterfaceBuilder
 */
@property (nonatomic, strong) IBInspectable NSString *IB_unbindedText;



#pragma mark - Méthodes

/**
 * @brief Cette méthode permet de mettre à jour le label via la valeur de mandatory
 */
-(void) displayMandatory;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

#import "MFLabel+UILabelForwarding.h"

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
#import "MFUIBaseRenderableComponent.h"


FOUNDATION_EXPORT NSString * const MF_MANDATORY_INDICATOR;



IB_DESIGNABLE
/**
 * @class MFLabel
 * @brief The label framework component
 * @discussion
 */
@interface MFUILabel : MFUIBaseRenderableComponent

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *label;


#pragma mark - Propriétés

/**
 * @brief Cette propriété permet de personnaliser le texte de la mension "obligatoire"
 */
@property (nonatomic, strong) NSString *mandatoryIndicator;

@end


IB_DESIGNABLE

@interface MFUIInternalLabel : MFUILabel <MFInternalComponent>

@end



IB_DESIGNABLE

@interface MFUIExternalLabel : MFUILabel <MFExternalComponent>

@property (nonatomic, strong) IBInspectable NSString *customXIBName;

@property (nonatomic, strong) IBInspectable NSString *customErrorXIBName;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

//#import "MFLabel+UILabelForwarding.h"

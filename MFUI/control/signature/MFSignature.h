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
//  MFSignature.h
//  MFUI
//
//

#import "MFUIOldBaseComponent.h"
#import "MFSignatureDrawing.h"
#import "MFControlChangesProtocol.h"

/*!
 * @class MFSignature
 * @brief The framework Signature component
 * @discussion This component display a view that allows the user to draw a signature.
 */
@interface MFSignature : MFUIOldBaseComponent <MFControlChangesProtocol>

#pragma mark - Properties
/*!
 * @brief The data managed by the component
 */
@property (nonatomic, strong) NSString *data;

/*!
 * @brief The custom signature drawing object that allows the user to draw a signature
 */
@property (nonatomic, strong) MFSignatureDrawing *signature;

/*!
 * @brief The view to display allowing the user to draw a signature
 */
@property (nonatomic, strong) UIView *modalSignatureDrawingView;

/*!
 * @brief The line width of the signature
 */
@property(nonatomic, assign) float lineWidth;

/*!
 * @brief The stroke color of the signature
 */
@property(nonatomic, strong) UIColor *strokeColor;

/*!
 * @brief An array describing the signature path
 */
@property(nonatomic, strong) NSMutableArray *signaturePath;

@end




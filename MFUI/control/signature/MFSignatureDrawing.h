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
//  MFSignatureDrawing.h
//  MFUI
//
//

#import <QuartzCore/QuartzCore.h>

typedef struct Line {
    CGPoint from, to;
} Line;

/*!
 * @class MFSignatureDrawing
 * @brief A view that allows the user to draw a signature
 * @discussion
 */
@interface MFSignatureDrawing : UIView {
    float lineWidth;
    UIColor *strokeColor;
    NSMutableArray *signaturePath;
}

#pragma mark - Properties

/*!
 * @brief The line width of the signature
 */
@property(nonatomic, assign) float lineWidth;

/*!
 * @brief The stroke color of the signature
 */
@property(nonatomic, strong) UIColor *strokeColor;

/*!
 * @brief An array describing the path of the signature
 */
@property(nonatomic, strong) NSMutableArray *signaturePath;


#pragma mark - Methods
/*!
 * @brief Clears the current signature
 */
- (void) clear;

@end




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
//  MFEnumImage.h
//  MFUI
//
//

#import "MFUIUtils.h"
#import "MFUIMotion.h"

#import "MFUIBaseComponent.h"
#import "MFButton.h"


@interface MFEnumImage : MFUIBaseComponent <UIGestureRecognizerDelegate, MFOrientationChangedProtocol>

#pragma mark - Properties

/**
 * @brief The image view that displays the image of an enum
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 * @brief The label that displays a text if no image is found
 */
@property (nonatomic, strong) UILabel *label;

/**
 * @brief The image that illustrates an enum
 */
@property (nonatomic) UIImage *image;


/**
 * @brief the manipuled data of the component
 */
@property (nonatomic, strong) NSNumber *data;

/**
 * @brief The delegate used when orientation change
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;

@end

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
//  MFButton+UIButtonForwarding.m
//  MFUI
//
//

#import "MFButton+UIButtonForwarding.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation MFButton (UIButtonForwarding)

#pragma clang diagnostic pop

@dynamic buttonType;
@dynamic currentAttributedTitle;
@dynamic currentImage;
@dynamic currentBackgroundImage;
@dynamic imageView;
@dynamic tintColor;
@dynamic currentTitle;
@dynamic currentTitleColor;
@dynamic currentTitleShadowColor;
@dynamic titleLabel;

@dynamic adjustsImageWhenDisabled;
@dynamic adjustsImageWhenHighlighted;
@dynamic reversesTitleShadowWhenHighlighted;
@dynamic hidden;
@dynamic showsTouchWhenHighlighted;
@dynamic titleEdgeInsets;
@dynamic contentEdgeInsets;
@dynamic imageEdgeInsets;

@end

//
//  MFButton+UIButtonForwarding.m
//  MFUI
//
//  Created by Quentin Lagarde on 31/12/2013.
//  Copyright (c) 2013 Sopra Consulting. All rights reserved.
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

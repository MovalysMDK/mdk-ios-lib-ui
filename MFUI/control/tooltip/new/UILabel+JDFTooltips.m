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


#import "UILabel+JDFTooltips.h"

// Categories
#import "UIView+JDFTooltips.h"


@implementation UILabel (JDFTooltips)

- (void)jdftt_resizeHeightToFitTextContents
{
    self.numberOfLines = 0;
    if (self.text.length < 1) {
        return;
    }
    [self jdftt_setFrameHeight:[self jdftt_requiredHeightToFitContents]];
}

- (void)jdftt_resizeWidthToFitTextContents
{
    self.numberOfLines = 0;
    if (self.text.length < 1) {
        return;
    }
    [self jdftt_setFrameWidth:[self jdftt_requiredWidthToFitContents]];
}

- (CGFloat)jdftt_requiredHeightToFitContents
{
    if (self.text.length < 1) {
        return 0.0f;
    }
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName: self.font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return ceil(rect.size.height);
}

- (CGFloat)jdftt_requiredWidthToFitContents
{
    if (self.text.length < 1) {
        return 0.0f;
    }
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName: self.font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return ceil(rect.size.width);
}

@end

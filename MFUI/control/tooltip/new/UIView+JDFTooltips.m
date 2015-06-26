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

#import "UIView+JDFTooltips.h"

@implementation UIView (JDFTooltips)

- (void)jdftt_setFrameWidth:(CGFloat)frameWidth
{
    CGRect frame = self.frame;
    frame.size.width = frameWidth;
    self.frame = frame;
}

- (void)jdftt_setFrameHeight:(CGFloat)frameHeight
{
    CGRect frame = self.frame;
    frame.size.height = frameHeight;
    self.frame = frame;
}

- (void)jdftt_centerInSuperview
{
    [self jdftt_centerHorizontallyInSuperview];
    [self jdftt_centerVerticallyInSuperview];
}

- (void)jdftt_centerHorizontallyInSuperview
{
    CGFloat viewWidth = self.frame.size.width;
    CGFloat superviewWidth = self.superview.frame.size.width;
    
    CGRect frame = self.frame;
    frame.origin.x = (superviewWidth - viewWidth) / 2;
    self.frame = frame;
}

- (void)jdftt_centerVerticallyInSuperview
{
    CGFloat viewHeight = self.frame.size.height;
    CGFloat superviewHeight = self.superview.frame.size.height;
    
    CGRect frame = self.frame;
    frame.origin.y = (superviewHeight - viewHeight) / 2;
    self.frame = frame;
}

@end

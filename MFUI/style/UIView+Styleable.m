
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
#import "UIView+Styleable.h"

@implementation MFUIBaseRenderableComponent (Styleable)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)applyStandardStyle {
    if([[[self.baseStyleClass alloc] init] respondsToSelector:@selector(applyStyleOnView:)]) {
        [[[self.baseStyleClass alloc] init] performSelector:@selector(applyStyleOnView:) withObject:self];
    }
}

-(void)applyErrorStyle {
    if([[[self.baseStyleClass alloc] init] respondsToSelector:@selector(applyErrorStyleOnView:)]) {
        [[[self.baseStyleClass alloc] init] performSelector:@selector(applyErrorStyleOnView:) withObject:self];
    }
}


-(void)applyValidStyle {
    if([[[self.baseStyleClass alloc] init] respondsToSelector:@selector(applyValidStyleOnView:)]) {
        [[[self.baseStyleClass alloc] init] performSelector:@selector(applyValidStyleOnView:) withObject:self];
    }
}
#pragma clang diagnostic pop

@end

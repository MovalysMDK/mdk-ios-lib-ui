
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
@protocol MFStyleProtocol;

@implementation UIView (Styleable)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)applyStandardStyle {
    NSObject<MFStyleProtocol> *baseStyleClass = [self performSelector:@selector(styleClass)];
    if([baseStyleClass respondsToSelector:@selector(applyStandardStyleOnComponent:)]) {
        [baseStyleClass performSelector:@selector(applyStandardStyleOnComponent:) withObject:self];
    }
}

-(void)applyErrorStyle {
    NSObject<MFStyleProtocol> *baseStyleClass = [self performSelector:@selector(styleClass)];
    if([baseStyleClass respondsToSelector:@selector(applyErrorStyleOnComponent:)]) {
        [baseStyleClass performSelector:@selector(applyErrorStyleOnComponent:) withObject:self];
    }
}


-(void)applyValidStyle {
    NSObject<MFStyleProtocol> *baseStyleClass = [self performSelector:@selector(styleClass)];
    if([baseStyleClass respondsToSelector:@selector(applyValidStyleOnComponent:)]) {
        [baseStyleClass performSelector:@selector(applyValidStyleOnComponent:) withObject:self];
    }
}
#pragma clang diagnostic pop

@end

//
//  MFBaseRenderableComponent+Styleable.m
//  LiveRendering
//
//  Created by Lagarde Quentin on 04/03/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

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

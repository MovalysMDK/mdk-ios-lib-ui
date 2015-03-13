//
//  MFBaseRenderableComponent+Styleable.h
//  LiveRendering
//
//  Created by Lagarde Quentin on 04/03/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFUIBaseRenderableComponent.h"

@interface UIView (Styleable)

-(void) applyStandardStyle;

-(void) applyValidStyle;

-(void) applyErrorStyle;

@end

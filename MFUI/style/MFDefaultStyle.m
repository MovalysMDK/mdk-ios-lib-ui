//
//  MFBaseStyle.m
//  LiveRendering
//
//  Created by Lagarde Quentin on 03/03/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFDefaultStyle.h"

@implementation MFDefaultStyle


-(void) applyStyleOnView:(UIView *)view {
    if(view) {
        view.layer.masksToBounds = YES;
    }
}

-(void)applyErrorStyleOnView:(UIView *)view {
//    view.layer.backgroundColor = [UIColor redColor].CGColor;
//    view.backgroundColor = [UIColor redColor];
}

-(void)applyValidStyleOnView:(UIView *)view {
    
}
@end

//
//  MFTextViewStyle.m
//  MFUI
//
//  Created by Quentin Lagarde on 06/05/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFTextViewStyle.h"
#import "MFTextView.h"

@implementation MFTextViewStyle

-(void)applyStandardStyleOnComponent:(MFTextView *)component {
    [super applyStandardStyleOnComponent:component];
    if([component.editable isEqualToNumber:@1]) {
        if(!component.backgroundColor) {
            component.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        }
    }
}


@end

//
//  MFUIError.m
//  MFUI
//
//  Created by Quentin Lagarde on 12/03/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFUIErrorView.h"
#import "MFUIBaseRenderableComponent.h"

@implementation MFUIErrorView




- (IBAction)onErrorButtonClick:(id)sender {
    //Forwarding this event on MFUIBaseRenderableComponent parent
    UIView *currentView = self;
    while (currentView && ![currentView isKindOfClass:[MFUIBaseRenderableComponent class]]) {
        currentView = [currentView superview];
    }
    
    if(currentView) {
        MFUIBaseRenderableComponent *parentComponent = (MFUIBaseRenderableComponent *)currentView;
        [parentComponent doOnErrorButtonClicked];
    }
}


@end

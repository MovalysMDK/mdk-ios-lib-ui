//
//  UIButton+MMButton.m
//  MMControls
//
//  Created by Sébastien Maitre on 05/10/12.
//  Copyright (c) 2012 Sopra Consulting. All rights reserved.
//

#import <objc/runtime.h>
#import "MFButton+MFButtonExt.h"

const void *mfButtonKey = &mfButtonKey;

@implementation MFButtonExt

@end

@implementation MFButton (MFButtonext)

-(MFButtonExt*)mf {
    MFButtonExt *extension = objc_getAssociatedObject(self, &mfButtonKey);
    
    if (!extension) {
        extension = [[MFButtonExt alloc] init];
        
        objc_setAssociatedObject(self, &mfButtonKey, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return extension;
}

-(void)setMf:(MFButtonExt *)extension {
    objc_setAssociatedObject(self, &mfButtonKey, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
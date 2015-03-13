//
//  UIButton+MMButton.h
//  MMControls
//
//  Created by Sébastien Maitre on 05/10/12.
//  Copyright (c) 2012 Sopra Consulting. All rights reserved.
//

#import "MFButton.h"


@interface MFButtonExt : NSObject

@property(nonatomic, strong) NSString *storyboardTargetName;

@property(nonatomic, strong) NSString *actionName;

@property(nonatomic, strong) NSString *title;

@property(nonatomic, weak) MFButton *owner;

@end

@interface MFButton (MFButtonExt)

@property(nonatomic, strong, readonly) MFButtonExt *mf;

@end

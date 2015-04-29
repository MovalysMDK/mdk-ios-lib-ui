//
//  MFButton.h
//  MFUI
//
//  Created by Sébastien Pacreau on 10/06/13.
//  Copyright (c) 2013 Sopra Consulting. All rights reserved.
//

#import "MFUIOldBaseComponent.h"

@interface MFButton : MFUIOldBaseComponent <UIAppearanceContainer>

@property (nonatomic, strong)   UIButton *button;

@end

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

#import "MFButton+UIButtonForwarding.h"
#import "MFButton+MFButtonExt.h"

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
//
//  MFForm3DHeaderViewControls.m
//  MFUI
//
//

#import "MFForm3DHeaderViewControls.h"
#import "MFUIApplication.h"

#define ARROWS_WIDTH 50

@implementation MFForm3DHeaderViewControls
@synthesize  contentView = _contentView;

#pragma mark - Initialization

-(id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void) initialize {
//    self.tag = [MFApplication getViewTag];
}


#pragma mark - UIView methods Method
- (void)layoutSubviews {
    
    [super layoutSubviews];
    //Placement des flèches en fonction de la taille de l'écran et de la valleur de ARROWS_WIDTH
    if(self.arrowNext) {
        [self.arrowNext removeFromSuperview];
    }
    else {
        self.arrowNext = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [self.arrowNext addTarget:self.delegate action:@selector(onNext) forControlEvents:UIControlEventTouchDown];
    }
    self.arrowNext.frame = CGRectMake(self.frame.size.width - ARROWS_WIDTH, 0, ARROWS_WIDTH, self.frame.size.height);
    [self addSubview:self.arrowNext];

    
    if(self.arrowPrevious) {
        [self.arrowPrevious removeFromSuperview];
    }
    else {
        self.arrowPrevious = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        self.arrowPrevious.transform = CGAffineTransformMakeRotation(M_PI);
        [self.arrowPrevious addTarget:self.delegate action:@selector(onPrevious) forControlEvents:UIControlEventTouchDown];

    }
    self.arrowPrevious.frame = CGRectMake(0, 0, ARROWS_WIDTH, self.frame.size.height);
    [self addSubview:self.arrowPrevious];

    [self addSubview:self.contentView];
    
}


#pragma mark - Custom methods
-(void)setContentView:(MFBindingViewAbstract *)contentView {
    //Add contentView
    _contentView = contentView;
    [_contentView setFrame:CGRectMake(ARROWS_WIDTH, 0, self.frame.size.width - 2 * ARROWS_WIDTH, self.frame.size.height)];
}




@end

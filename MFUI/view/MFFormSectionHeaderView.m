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


#import "MFFormSectionHeaderView.h"

#define MF_SECTION_DISCLOSURE_DETAIL_BUTTON_MARGIN 5

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@implementation MFFormSectionHeaderView


- (id)initWithIdentifier:(NSNumber *)identifier {
    self = [super init];
    if(self) {
        self.identifier = identifier;
    }
    return self;
}

- (void)initialize {
    [super initialize];
    self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.userInteractionEnabled = NO;
    [self animateDisclosurechanges];
}

- (void)animateDisclosurechanges {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self toogleDisclosureStateWithAction:YES];
    }
    completion:^(BOOL finished) {
        self.isOpened = ! self.isOpened;
        self.userInteractionEnabled = YES;
        [self openedStateChanged];
    }];
}

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)toogleDisclosureStateWithAction:(BOOL)withAction {
    if(self.isOpened) {
        if([self.sender respondsToSelector:@selector(closeSectionAtIndex:)] && withAction) {
            [self.sender performSelector:@selector(closeSectionAtIndex:) withObject:self.identifier];
        }
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        self.disclosureIndicator.tag = 0;
        
    }
    else {
        if([self.sender respondsToSelector:@selector(openSectionAtIndex:)] && withAction) {
            [self.sender performSelector:@selector(openSectionAtIndex:) withObject:self.identifier];
        }
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        self.disclosureIndicator.tag = 1;
    }
}
#pragma clang diagnostic pop

- (void)addDisclosureIndicator {
    UIImage *arrowImage = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:NSClassFromString(@"MFForm2DListViewController")] pathForResource:@"arrow" ofType:@"png"]];
    self.disclosureIndicator = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.disclosureIndicator setImage:arrowImage forState:UIControlStateNormal];
    
    self.disclosureIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *disclosureCenterY = [NSLayoutConstraint constraintWithItem:self.disclosureIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *disclosureHeight= [NSLayoutConstraint constraintWithItem:self.disclosureIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
    NSLayoutConstraint *disclosureWidth= [NSLayoutConstraint constraintWithItem:self.disclosureIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:32];
    NSLayoutConstraint *disclosureLeftMargin = [NSLayoutConstraint constraintWithItem:self.disclosureIndicator attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:MF_SECTION_DISCLOSURE_DETAIL_BUTTON_MARGIN];
    [self addSubview:self.disclosureIndicator];
    [self addConstraints:@[disclosureCenterY, disclosureHeight, disclosureLeftMargin, disclosureWidth]];
    
    [self.disclosureIndicator addTarget:self action:@selector(touchesEnded:withEvent:) forControlEvents:UIControlEventTouchDown];
    
    if(self.isOpened) {
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        self.disclosureIndicator.tag = 1;
    }
}

- (void)setIsOpened:(BOOL)isOpened {
    _isOpened = isOpened;
    
    //Restoring discluse state
    if(isOpened && self.disclosureIndicator.tag ==0) {
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        self.disclosureIndicator.tag = 1;
    }
    else if(!isOpened && self.disclosureIndicator.tag == 1) {
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        self.disclosureIndicator.tag = 0;
    }
    if(!self.disclosureIndicator) {
        [self addDisclosureIndicator];
    }
}

- (void)reinit {
    self.isOpened = YES;
    [UIView beginAnimations:@"" context:nil];
    self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    self.disclosureIndicator.tag = 1;
    [UIView commitAnimations];
    
}

- (void)setParentEditable:(NSNumber *)parentEditable {
    [super setParentEditable:@0];
}

- (void)openedStateChanged {
    //Nothing here
}

@end

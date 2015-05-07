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

#define MF_SECTION_DISCLOSURE_DETAIL_BUTTON_MARGIN 20

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@implementation MFFormSectionHeaderView


-(id) initWithIdentifier:(NSNumber *)identifier {
    self = [super init];
    if(self) {
        self.identifier = identifier;
    }
    return self;
}


-(void) initialize {
    [super initialize];
    self.isOpened = YES;
        [self addDisclosureIndicator];
    
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self animateDisclosure];
                     }
                     completion:^(BOOL finished) {
                         self.isOpened = ! self.isOpened;
                         self.userInteractionEnabled = YES;
                         [self openedStateChanged];
                     }];
}

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
-(void) animateDisclosure {
    if(self.isOpened) {
        if([self.sender respondsToSelector:@selector(closeSectionAtIndex:)]) {
            [self.sender performSelector:@selector(closeSectionAtIndex:) withObject:self.identifier];
            self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
            
        }
    }
    else {
        if([self.sender respondsToSelector:@selector(openSectionAtIndex:)]) {
            [self.sender performSelector:@selector(openSectionAtIndex:) withObject:self.identifier];
            self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        }
    }
}
#pragma clang diagnostic pop

-(void) addDisclosureIndicator {
    
    self.disclosureIndicator = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.disclosureIndicator setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    self.disclosureIndicator.frame = CGRectMake(MF_SECTION_DISCLOSURE_DETAIL_BUTTON_MARGIN - self.disclosureIndicator.frame.size.width/2,
                                                self.frame.size.height/2 - self.disclosureIndicator.frame.size.height/2,
                                                self.disclosureIndicator.frame.size.width,
                                                self.disclosureIndicator.frame.size.height);
    [self.disclosureIndicator addTarget:self action:@selector(touchesEnded:withEvent:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.disclosureIndicator];
    if(self.isOpened) {
        self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    }
}

-(void)setIsOpened:(BOOL)isOpened {
    _isOpened = isOpened;
}

-(void)reinit {
    self.isOpened = YES;
    [UIView beginAnimations:@"" context:nil];
    self.disclosureIndicator.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    [UIView commitAnimations];
    
}


-(void)setParentEditable:(NSNumber *)parentEditable {
    [super setParentEditable:@0];
}

-(void) openedStateChanged {
    //Nothing here
}
@end

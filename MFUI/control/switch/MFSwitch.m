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
//  MFSwitch.m
//  MFUI
//
//

#import "MFSwitch.h"

@implementation MFSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize {
    
    [super initialize];
    self.innerSwitch = [[UISwitch alloc] initWithFrame:self.frame];
    [self addSubview:self.innerSwitch];
#if !TARGET_INTERFACE_BUILDER
    [self.innerSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
#else
#endif
    
}

- (void) switchValueChanged:(id)sender {
    
    [self updateValue];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.innerSwitch.tag == 0) {
        [self.innerSwitch setTag:TAG_MFSWITCH_SWITCHCOMPONENT];
    }
}


#pragma mark - MFUIComponentProtocol implementation

+(NSString *)getDataType {
    return @"NSNumber";
}

-(void)setData:(id)data {
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        self.innerSwitch.on = [(NSNumber *)data boolValue];
    }
}

-(id)getData {
    return [NSNumber numberWithBool:self.innerSwitch.on];
}

-(void) updateValue {
    [self performSelectorOnMainThread: @selector(updateValue:) withObject:[self getData] waitUntilDone:YES];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.innerSwitch.enabled = ([editable isEqualToNumber:@1]) ? YES : NO;
}

#pragma mark - Fast Forwarding UISwitch methods
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.innerSwitch;
}


#pragma mark - LiveRendering methods


@end

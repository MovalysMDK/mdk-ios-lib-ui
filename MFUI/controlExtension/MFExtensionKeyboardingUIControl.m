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
//  MFExtensionKeyboardingUIControl.m
//  MFUI
//
//

#import "MFExtensionKeyboardingUIControl.h"

@implementation MFExtensionKeyboardingUIControl
@synthesize maxLength = _maxLength;
@synthesize minLength = _minLength;
@synthesize mandatory = _mandatory;

- (NSString *) description
{
    return [NSString stringWithFormat:@"MFExtensionKeyboardingUIControl<maxLength: %@, minLength: %@, mandatory: %@>", self.maxLength, self.minLength, self.mandatory ? @"YES" : @"NO"];
}

-(void) setValue:(id)value forUndefinedKey:(NSString *)key {
        [super setValue:value forUndefinedKey:key];
}

@end

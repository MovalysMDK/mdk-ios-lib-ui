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
//  MFPhotoState.m
//  MFUI
//
//

#import "MFPhotoState.h"

@implementation MFPhotoState

@synthesize state;
@synthesize baseId = _baseId;

#pragma mark - Constructeurs

-(id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

#pragma mark - Constructeurs

-(id) init:(int)baseId {
    self = [super init];
    if(self) {
        _baseId = &baseId;
    }
    return self;
}

@end

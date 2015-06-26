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


#import "MFListenerDescriptorManager.h"

@interface MFListenerDescriptorManager ()

@property (nonatomic, strong) NSArray *listenerDescriptors;

@end

@implementation MFListenerDescriptorManager

#pragma mark - Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listenerDescriptors = [NSArray array];
    }
    return self;
}


#pragma mark - Manage descriptors

-(void) addListenerDescriptor:(MFListenerDescriptor *)listenerDescriptor {
    NSMutableArray *mutableArray = [self.listenerDescriptors mutableCopy];
    [mutableArray addObject:listenerDescriptor];
    self.listenerDescriptors = mutableArray;
}

-(void) addListenerDescriptors:(NSArray *)listenerDescriptors {
    NSMutableArray *mutableArray = [self.listenerDescriptors mutableCopy];
    for(MFListenerDescriptor *descriptor in mutableArray) {
        [self addListenerDescriptor:descriptor];
    }
    [mutableArray addObjectsFromArray:listenerDescriptors];
    self.listenerDescriptors = mutableArray;
}

-(NSArray *)listenerDescriptorsForEventType:(MFListenerEventType)eventType {
    NSMutableArray *result = [NSMutableArray new];
    for(MFListenerDescriptor *aDescriptor in self.listenerDescriptors) {
        if([aDescriptor listenEventType:eventType]) {
            [result addObject:aDescriptor];
        }
    }
    return result;
}

@end

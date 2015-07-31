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


#import "MFListenerDescriptor.h"
#import "NSString+Utils.h"


@interface MFListenerDescriptor ()

@property (nonatomic, strong) NSMutableDictionary *propertyCallbacksDictionary;

@property (nonatomic) MFListenerEventType eventType;

@property (nonatomic, weak) id<MFObjectWithListenerProtocol> objectWithListener;

@end


@implementation MFListenerDescriptor
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertyCallbacksDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+(instancetype) listenerDescriptorForType:(MFListenerEventType)eventType withFormat:(NSString *)format,... NS_REQUIRES_NIL_TERMINATION {
    MFListenerDescriptor *descriptor = [MFListenerDescriptor new];
    if(descriptor) {
        descriptor.eventType = eventType;
        va_list args;
        va_start(args, format);
        for (NSString *arg = format; arg != nil; arg = va_arg(args, NSString*)) {
            [descriptor parseFormat:arg];
        }
        va_end(args);
    }
    return descriptor;
}


-(void) parseFormat:(NSString *)format {
    if(!self.propertyCallbacksDictionary) {
        self.propertyCallbacksDictionary = [NSMutableDictionary dictionary];
    }
    NSArray *formatComponents = [format componentsSeparatedByString:@":"];
    if(formatComponents.count != 2) {
        @throw [NSException exceptionWithName:@"Wrong fromat" reason:[NSString stringWithFormat:@"Invalid Format : %@ . The View Model configuration format should be like \" x :   method1, metohd2\"", format] userInfo:nil];
    }
    NSString *callbackMethodName = [formatComponents[0] trim];
    NSArray *listenedProperties = [formatComponents[1] componentsSeparatedByString:@","];
    for(NSString *aProperty in listenedProperties) {
        NSString *aTrimmedProperty = [aProperty trim];
        NSMutableArray *currentCallbacksForProperty = self.propertyCallbacksDictionary[aTrimmedProperty];
        if(!currentCallbacksForProperty) {
            currentCallbacksForProperty = [NSMutableArray array];
        }
        [currentCallbacksForProperty addObject:[callbackMethodName trim]];
        self.propertyCallbacksDictionary[aTrimmedProperty] = currentCallbacksForProperty;
    }
}

-(NSArray *) callbackForKeyPath:(NSString *) keyPath {
    return self.propertyCallbacksDictionary[keyPath];
}

-(void)setTarget:(id<MFObjectWithListenerProtocol>)object {
    self.objectWithListener = object;
}

-(BOOL)listenEventType:(MFListenerEventType)eventType {
    return self.eventType == eventType;
}



@end

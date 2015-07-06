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

#import "MFSimpleComponentProvider.h"
#import "MFCommandProtocol.h"
#import "MFFieldValidatorProtocol.h"

@implementation MFSimpleComponentProvider

-(id<MFCommandProtocol>)commandWithKey:(NSString *)baseKey withQualifier:(NSString *)qualifier {
    id<MFCommandProtocol> command = nil;
    Class commandClass = [self classWithKey:baseKey withQualifier:qualifier];
    if(commandClass) {
        command = [commandClass sharedInstance];
    }
    else {
        @throw [NSException exceptionWithName:@"Command not found" reason:[NSString stringWithFormat:@"No command found for key %@", baseKey] userInfo:nil];
    }
    return command;
}

-(id<MFFieldValidatorProtocol>)fieldValidatorWithKey:(NSString *)baseKey {
    id<MFFieldValidatorProtocol> fieldValidator = nil;
    baseKey = [[[baseKey substringToIndex:1] uppercaseString] stringByAppendingString:[baseKey substringFromIndex:1]];
    Class fieldValidatorClass = [self classWithKey:baseKey withQualifier:@""];
    if(fieldValidatorClass) {
        fieldValidator = [fieldValidatorClass sharedInstance];
    }
    else {
        @throw [NSException exceptionWithName:@"Field validator not found" reason:[NSString stringWithFormat:@"No field validator found for key %@", baseKey] userInfo:nil];
    }
    return fieldValidator;
}



-(Class)classWithKey:(NSString *)baseKey withQualifier:(NSString *)qualifier{
    Class commandClass = nil;
    if(qualifier) {
        Class commandClass = NSClassFromString([NSString stringWithFormat:@"MF%@_%@", baseKey, qualifier]);
        if(!commandClass) {
            commandClass = NSClassFromString([NSString stringWithFormat:@"MF%@", baseKey]);
        }
        else {
            commandClass = NSClassFromString([NSString stringWithFormat:@"MF%@", baseKey]);
        }
    }
    return commandClass;
}
@end

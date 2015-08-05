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

#import "MFCallPhoneNumberCommand.h"
#import "MFPhoneNumber.h"

@implementation MFCallPhoneNumberCommand

#pragma mark - Initialization

+(MFCallPhoneNumberCommand *)sharedInstance{
    static MFCallPhoneNumberCommand *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id) executeFromViewController:(UIViewController *)viewController withParameters:(id)parameters, ... NS_REQUIRES_NIL_TERMINATION {
    
    va_list args;
    va_start(args, parameters);
    MFPhoneNumber *phone = parameters;
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [phone buildPhoneString]]];
    [[UIApplication sharedApplication] openURL:url];
    return nil;
}

@end

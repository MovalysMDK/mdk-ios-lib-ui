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

#import "MFFixedListContentFieldValidator.h"
#import "MFFixedList.h"
#import "MFUIBaseListViewModel.h"

@implementation MFFixedListContentFieldValidator

+(instancetype)sharedInstance{
    static MFFixedListContentFieldValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(MFError *)validate:(id)value withCurrentState:(NSDictionary *)currentState withParameters:(NSDictionary *)parameters {
    MFError *result = nil;
    BOOL isValid = YES;
    if([value isKindOfClass:[MFUIBaseListViewModel class]]) {
        for(MFUIBaseViewModel *itemVM in ((MFUIBaseListViewModel *)value).viewModels) {
            isValid = isValid && [itemVM validate];
        }
    }
    if(!isValid) {
        result = [[MFError alloc] initWithCode:1002 localizedDescriptionKey:parameters[@"componentName"]];
    }
    return result;
}

-(BOOL)canValidControl:(UIView *)control {
    return [control isKindOfClass:[MFFixedList class]];
}

-(NSArray *)recognizedAttributes {
    return @[];
}

-(BOOL)isBlocking {
    return YES;
}

@end

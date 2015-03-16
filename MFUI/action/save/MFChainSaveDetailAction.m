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
//  MFChainSaveDetailAction.m
//  MFUI
//
//

#import "MFChainSaveDetailAction.h"
#import "MFAbstractSaveDetailAction.h"
#import "MFChainSaveActionDetailParameter.h"
#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreI18n.h>

@implementation MFChainSaveDetailAction

NSString *const MFAction_MFChainSaveDetailAction = @"MFChainSaveDetailAction";

-(id) doAction:(id)parameterIn withContext: (id<MFContextProtocol>)context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher *) dispatch {
    
    MFChainSaveActionDetailParameter *inParam = (MFChainSaveActionDetailParameter *) parameterIn;
    NSArray *actionNames = (NSArray *) inParam.actions ;
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    for ( NSString *saveAction in actionNames ) {
        MFAbstractSaveDetailAction *action = [[MFApplication getInstance] getBeanWithKey:saveAction];
        [actions addObject:action];
    }
    
    //--------------------------
    
    if (parameterIn != nil) {
        BOOL validationSuccess = YES;
        // Validate data
        for ( MFAbstractSaveDetailAction *action in actions ) {
            if (![action validateData:parameterIn inContext:context]) {
                validationSuccess = NO ;
            }
        }
            
        if (validationSuccess) {
            
            NSMutableDictionary *actionResults = [[NSMutableDictionary alloc] init];
            
            int index = 0 ;
            for ( MFAbstractSaveDetailAction *action in actions ) {
                id entity = [action preSaveData:inParam.parameterIn inContext:context];
                [actionResults setObject:entity forKey:[NSString stringWithFormat:@"%d", index]];
                index++;
            }
            
            index = 0 ;
            for ( MFAbstractSaveDetailAction *action in actions ) {
                id entity = [actionResults objectForKey:[NSString stringWithFormat:@"%d", index]];
                [action saveData:entity parameter:inParam.parameterIn inContext:context];
                index++;
            }
            
            index = 0 ;
            for ( MFAbstractSaveDetailAction *action in actions ) {
                id entity = [actionResults objectForKey:[NSString stringWithFormat:@"%d", index]];
                [action postSaveData:entity parameter:inParam.parameterIn inContext:context];
                index++;
            }
        }
        else {
            NSString *errorText = [NSString stringWithString:MFLocalizedStringFromKey(@"form_savefailed_title")];
            NSError *error = [[NSError alloc] initWithDomain:@"com.sopraconsulting.movalys.saveChainDetailAction"
                                                        code:2 userInfo:@{NSLocalizedDescriptionKey : errorText}];
            [context addErrors:@[error]];
        }
    }
    
    //--------------------------
   
    return nil;
}


@end

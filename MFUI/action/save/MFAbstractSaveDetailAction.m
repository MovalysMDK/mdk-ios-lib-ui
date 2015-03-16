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
//  MFAbstractSaveDetailAction.m
//  MFUI
//
//

#import "MFAbstractSaveDetailAction.h"
#import "MFActionQualifierProtocol.h"
#import "MFContextProtocol.h"
#import "MFActionProgressMessageDispatcher.h"

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreCoredata.h>
#import "MFBeanLoader.h"
#import "MFLocalizedString.h"

@implementation MFAbstractSaveDetailAction

-(id) doAction:(id)parameterIn withContext: (id<MFContextProtocol>)context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher *) dispatch {
    
    id result = nil ;

    if ( [self validateData:parameterIn inContext:context] ) {
        result = [self preSaveData:parameterIn inContext:context];
        [self saveData:result parameter:parameterIn inContext:context];
        [self postSaveData:result parameter:parameterIn inContext:context];
    } else {
        
        NSString *errorText = [NSString stringWithString:MFLocalizedStringFromKey(@"form_savefailed_title")] ;
        NSError *error = [[NSError alloc] initWithDomain:@"com.sopraconsulting.movalys.saveDetailAction"
              code:2 userInfo:@{NSLocalizedDescriptionKey : errorText}];
        [context addErrors:@[error]];
    }

    return result ;
}

-(id) doOnSuccess:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil ;
}

-(id) doOnFailed:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil ;
}

-(BOOL) validateData:(id)parameterIn inContext:(id<MFContextProtocol>)context {
    return YES;
}

-(id) preSaveData:(id)parameterIn inContext:(id<MFContextProtocol>)context {
    return nil;
}

-(void) saveData:(id)entity parameter:(id)parameterIn inContext:(id<MFContextProtocol>)context {
}

-(void) postSaveData:(id)entity parameter:(id)parameterIn inContext:(id<MFContextProtocol>)context {
}

- (BOOL) isReadOnly {
    return NO;
}

@end

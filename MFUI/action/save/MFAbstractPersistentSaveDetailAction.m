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
//  MFAbstractPersistentSaveDetailAction.m
//  MFUI
//
//

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreCoreData.h>

#import "MFAbstractPersistentSaveDetailAction.h"

@implementation MFAbstractPersistentSaveDetailAction

-(void) saveData:(id)entity parameter:(id)parameterIn inContext:(id<MFContextProtocol>)context {
    if ( [context.entityContext hasChanges] ) {
        MFCoreDataHelper *cdh = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CORE_DATA_HELPER];
        
        //#ifdef DEBUG
        //[cdh logChanges:context withDetails:YES];
        //#endif
        
        NSError* error = [cdh saveContext:context];
        if (error!=nil) {
            [NSException raise:@"Failure saving context" format:@"error: %@", error];
        }
    }
}


-(id) doOnSuccess:(id)parameterOut withContext: (id<MFContextProtocol>)context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch {

    NSArray *listObjectToSync = [self toSynchronize:parameterOut inContext:context];
    if (listObjectToSync != nil && ![listObjectToSync count] != 0 ) {
          //TODO: save listObjectToSync in database
    }
        
    //TODO: gestion de la synchro
        
    [super doOnSuccess:parameterOut withContext:context withQualifier:qualifier withDispatcher:dispatch];
    
    return nil ;
}


-(NSArray *) toSynchronize:(id)entity inContext:(id<MFContextProtocol>)context {
    return nil;
}

- (BOOL) isReadOnly {
    return NO ;
}

@end

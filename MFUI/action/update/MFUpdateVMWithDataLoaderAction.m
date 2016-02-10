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
//  MFUpdateVMWithDataLoaderAction.m
//  MFCore
//
//

#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreDataloader.h>

#import "MFUpdateVMWithDataLoaderAction.h"
#import "MFUpdateVMInParameter.h"
#import "MFUIBaseViewModelProtocol.h"
#import "MFApplication+MFUIAppSingleton.h"


@implementation MFUpdateVMWithDataLoaderAction

NSString *const MFAction_MFUpdateVMWithDataLoaderAction = @"MFUpdateVMWithDataLoaderAction";

-(id) doAction:(id) parameterIn withContext: (id<MFContextProtocol>)context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch {
    MFCoreLogVerbose(@"MFUpdateVMWithDataLoaderAction> doAction");
    
    if ( [parameterIn isKindOfClass:[NSArray class]] ) {
        NSArray *updateVmParams = parameterIn;
        
        for( MFUpdateVMInParameter *updateVmParam in updateVmParams ) {
            [self updateVM:updateVmParam.viewModelName withDataLoader:updateVmParam.dataLoaderName inContext:context];
        }
    }
    else {
        MFUpdateVMInParameter *updateVmParam = parameterIn;
        [self updateVM:updateVmParam.viewModelName withDataLoader:updateVmParam.dataLoaderName inContext:context];
    }
    
    MFCoreLogVerbose(@"MFUpdateVMWithDataLoaderAction< doAction");
    return self.filterParameters ;
}

-(id) doOnSuccess:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil;
}

-(id) doOnFailed:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil ;
}

-(void) updateVM:(NSString *)viewModelName withDataLoader:(NSString *)dataLoaderName inContext:(id<MFContextProtocol>)context
{
    //TODO FTO : On gère ici le cas des entités transient qui n'ont pas de DataLoader, donc pas d'action à lancer. il faut voir par la suite comment gérer ces entités.
    if(![dataLoaderName isEqualToString:@""]) {
    	id<MFUIBaseViewModelProtocol> vm = [[MFApplication getInstance] getBeanWithKey:viewModelName];
    	id<MFDataLoaderProtocol> dataLoader = (id<MFDataLoaderProtocol>) [[MFApplication getInstance] getBeanWithKey:dataLoaderName];
    	self.filterParameters = [dataLoader getFilterParameters];
    	if ( [vm conformsToProtocol:@protocol(MFUpdatableFromDataLoaderProtocol)]) {
        	[vm performSelector:@selector(updateFromDataloader: inContext:) withObject:dataLoader withObject:context];
      	}
    }
}

@end

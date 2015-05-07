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


#import "MFAbstractDeleteDetailAction.h"

#import "MFDeleteDetailActionParamIn.h"
#import "MFDeleteDetailActionParamOut.h"

#import <MFCore/MFCoreAction.h>

@protocol MFActionQualifierProtocol;

@implementation MFAbstractDeleteDetailAction

-(id) doAction:(id)parameterIn withContext: (id<MFContextProtocol>)context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher *) dispatch {
    
    MFDeleteDetailActionParamIn *paramIn = (MFDeleteDetailActionParamIn *) parameterIn;
    
    [self deleteData:paramIn.identifier inContext:context];
    
    return [[MFDeleteDetailActionParamOut alloc] initWithIdentifier:paramIn.identifier andIndexPath:paramIn.indexPath];
}

-(id) doOnSuccess:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil ;
}

-(id) doOnFailed:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch{
    return nil ;
}

- (void) deleteData:(NSNumber *)identifier inContext:(id<MFContextProtocol>)context
{
    // does nothing by default
}


@end

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
//  MFAbstractSaveDetailAction.h
//  MFUI
//
//

#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreContext.h>

@interface MFAbstractSaveDetailAction : NSObject<MFActionProtocol>

-(id) doOnSuccess:(id) parameterOut withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch ;

-(BOOL) validateData:(id)parameterIn inContext:(id<MFContextProtocol>)context;

-(id) preSaveData:(id)parameterIn inContext:(id<MFContextProtocol>)context;

-(void) saveData:(id)entity parameter:(id)parameterIn inContext:(id<MFContextProtocol>)context;

-(void) postSaveData:(id)entity parameter:(id)parameterIn inContext:(id<MFContextProtocol>)context;

@end

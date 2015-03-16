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
//  MFTestHelper.h
//  addresslocation
//
//


#import <MFCore/MFCoreContext.h>

@interface MFTestHelper : NSObject

/**
 * @brief donne l'unique instance du starter
 */
+(MFTestHelper *)getInstance;

/**
 * @brief run once, before tests of the classes
 */
- (void) setUpOnce;

/**
 * @brief run once, after tests of the classes
 */
- (void) tearDownOnce;

/**
 * @brief create a mfcontext
 */
- (id<MFContextProtocol>) createContext;

/**
 * @brief rollback mfcontext
 */
- (void) rollbackContext:(id<MFContextProtocol>) mfContext;

/**
 * @brief use this method to start an action in an unit test
 */
- (id) launchAction:(NSString *) actionName withInParameter:(id) parameterIn andContext:(id<MFContextProtocol>) mfContext;

@end

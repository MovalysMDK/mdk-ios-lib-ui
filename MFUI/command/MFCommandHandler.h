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

#import <Foundation/Foundation.h>

@protocol MFCommandProtocol;

@interface MFCommandHandler : NSObject

/*!
 * @brief Returns a command corresponding to the given command key
 * @param baseKey A string that represent the baseKey of the command to return
 * @return The command corresponding to the given key.
 */
+(id<MFCommandProtocol>) commandWithKey:(NSString *)baseKey withQualifier:(NSString *)qualifier;

@end

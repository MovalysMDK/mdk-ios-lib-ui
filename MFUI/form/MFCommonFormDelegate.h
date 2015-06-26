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


#import "MFFormCommonDelegate.h"

@interface MFCommonFormDelegate : NSObject <MFCommonFormProtocol>

#pragma mark - Propriétés


/*!
 * @brief Le parent tenant ce delegate
 */
@property (nonatomic, weak) id<MFCommonFormProtocol> parent;


#pragma mark - Méthodes

/*!
 * @brief Cette méthode construit cette classe avec un parent
 * @param Le parent de ce delegate
 * @return Une instance de ce delegate
 */
-(id)initWithParent:(id<MFCommonFormProtocol>) parent;

/*!
 * @brief Cette méthode permet de réinitialiser les propriétés dynamiques du binding telles que binding ou bindingProperties.
 */
-(void) reinit;

@end

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



/**
 * @protocol MFDefaultConstraintsProtocol
 * @brief A protocol to apply on class that needs to apply default constraints or manage some speicific constraints
 */
@protocol MFDefaultConstraintsProtocol <NSObject>

#pragma mark - Properties
/**
 * @brief Default constraints to apply
 */
@property (nonatomic, weak) NSArray *defaultConstraints;


/**
 * @brief Default constraints to apply
 */
@property (nonatomic, strong) NSMutableDictionary *savedConstraints;


#pragma mark - Methods

@optional
/**
 * @brief Apply some default constraints for this object
 */
-(void)applyDefaultConstraints;

@end



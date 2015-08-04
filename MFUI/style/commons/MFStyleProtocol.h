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


/*!
 * @protocol MFStyleProtocol
 * @brief This protocol declares standars methods for MDK style classes
 * @discussion This protocol should be used to identy a style class.
 */
@protocol MFStyleProtocol <NSObject>

#pragma mark - Methods

/*!
 * @brief This method should be called when the component that uses this
 * style class in an error state
 * @param component The component that is in an error state.
 */
@required
-(void) applyErrorStyleOnComponent:(id)component;

/*!
 * @brief This method should be called when the component that uses this
 * style class in an valid state
 * @param component The component that is in an valid state.
 */
@required
-(void) applyValidStyleOnComponent:(id)component;

/*!
 * @brief This method should be called when the component that uses this
 * style class in an standard state
 * @param component The component that is in an standard state.
 * @discussion A standard state does not mean valid/invalid state. 
 * This method should be always called before any method that applies a style,
 * even if the component has a valid or an invalid state.
 */
@required
-(void) applyStandardStyleOnComponent:(id)component;

@end

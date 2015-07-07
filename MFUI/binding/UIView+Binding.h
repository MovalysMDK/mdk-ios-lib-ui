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


#import <UIKit/UIKit.h>
#import "MFObjectWithBindingProtocol.h"
#import "MFBindingViewDescriptor.h"
#import "MFBindingViewAbstract.h"

@interface UIView (Binding)

/*!
 * @brief Allows to bind this cell from a given descriptor to the given object
 * @param bindingCellDescriptor The binding cell descriptor used to bind this cell
 * @param objectWithBinding An object that conforms the MFObjectWithBindingProtocol protocol, this cell will be binded to
 */
-(void)bindViewFromDescriptor:(MFBindingViewDescriptor *)bindingViewDescriptor onObjectWithBinding:(id<MFObjectWithBindingProtocol>)objectWithBinding;

/*!
 * @brief Performs some treatments the view is binded
 */
-(void) didBinded;

/*!
 * @brief Sets the binded name of the view
 * @param bindedName the binded name of the component
 */
- (void)setBindedName:(NSString *)bindedName;

/*!
 * @brief Returns  the binded name of the view
 * @return The binded name of the view.
 */
- (NSString *)bindedName;
@end

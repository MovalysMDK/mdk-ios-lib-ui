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
#import "MFBindingDelegate.h"
#import "MFUIBaseViewModelProtocol.h"

@class MFUIBaseViewModel;

/*!
 * @protocol MFObjectWithBindingProtocol
 * @brief A protocol that specify an object that need binding.
 */
@protocol MFObjectWithBindingProtocol <NSObject>

#pragma mark - Properties
/*!
 * @brief The binding delegate of the object that implments thus protocol.
 */
@property (nonatomic, strong) MFBindingDelegate *bindingDelegate;

/*!
 * @brief The View Model used to bind, of the object that need the binding
 */
@property(nonatomic, weak, getter=getViewModel) NSObject<MFUIBaseViewModelProtocol> *viewModel;

@end

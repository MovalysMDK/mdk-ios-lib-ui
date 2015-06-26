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

#import "MFUIComponentProtocol.h"
#import "MFFormCommonDelegate.h"

@protocol MFFormViewProtocol <NSObject>


#pragma mark - Properties


/*!
 * @brief Indicates if this view has changed (and need to register components).
 */
@property(nonatomic) BOOL hasChanged;

/*!
 * @brief This is the controller of this view. This controller contains a forms.
 */
@property (nonatomic, weak) id<MFCommonFormProtocol> formController;


@required
#pragma mark - Methods



@end


#pragma mark - MFBindingComponentDescriptor Class

/*!
 * @brief Cette classe est un descripteur pôur le binding des propriétés/composants.
 */
@interface MFComponentDescriptor : NSObject


@end


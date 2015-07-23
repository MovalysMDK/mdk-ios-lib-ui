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

#import "MFViewProtocol.h"
#import "MFFormViewControllerProtocol.h"


/*!
 * @class MFBindingViewAbstract
 * @brief A specific view that can be binded to the MDK iOS Framework
 */
@interface MFBindingViewAbstract : UIView <MFFormViewProtocol, MFFormCellProtocol>

#pragma mark - Properties
/*!
 * @property identifier The identifier of this section
 */
@property (nonatomic, strong) NSNumber *identifier;

/*!
 * @property sender The identifier of this section
 */
@property (nonatomic, weak) id<MFFormViewControllerProtocol> sender;

/*!
 * @property parentEditable Indicated the editable state of the parent.
 */
@property (nonatomic, strong) NSNumber *parentEditable;



#pragma mark - Methods

/*!
 * @brief Common method to initialize some objects of the class
 */
-(void)initialize;

-(void)viewIsConfigured;


@end

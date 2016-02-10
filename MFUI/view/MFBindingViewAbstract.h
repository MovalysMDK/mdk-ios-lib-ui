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
//  MFPickerItemViewAbstract.h
//  MFUI
//
//

#import "MFBindingViewProtocol.h"
#import "MFUIBaseComponent.h"
#import "MFFormViewControllerProtocol.h"

@interface MFBindingViewAbstract : UIView <MFBindingViewProtocol, MFFormCellProtocol>



#pragma mark - Properties
/**
 * @brief The identifier of this section
 */
@property (nonatomic) NSNumber *identifier;

/**
 * @brief The identifier of this section
 */
@property (nonatomic, weak) id<MFFormViewControllerProtocol> sender;

/**
 * @brief Indicated the editable state of the parent.
 */
@property (nonatomic, strong) NSNumber *parentEditable;



#pragma mark - Methods

/**
 * @brief Common method to initialize some objects of the class
 */
-(void)initialize;

-(void)viewIsConfigured;


@end

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


#import "MFUIBinding.h"
#import "MFUIProtocol.h"
#import "MFUIForm.h"
#import "MFUIComponents.h"


/*!
 * @brief The class is an abstract class for framework cells.
 * @discussion It does some basic treatments common to all framework cells. Basically, it allows to bind some properties to a ViewModel.
 */
@interface MFCellAbstract : UITableViewCell<MFFormCellProtocol, MFBindingViewProtocol, MFDefaultConstraintsProtocol>

#pragma mark - Properties
/*!
 * @brief The Storyboard extension for this cell
 */
@property (nonatomic, strong) MFFormExtend *mf;


#pragma mark - Methods

/*!
 * @brief this common methods allows to do some treatment on this cell before using it
 */
-(void) initialize;

/*!
 * @brief Callback called after the cell is configured by its form controller.
 */
-(void) cellIsConfigured;


@end

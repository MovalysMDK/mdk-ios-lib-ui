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
//  TextFieldCell.h
//  Step1
//
//

#import "MFCellAbstract.h"


/**
 * @brief Main default framework cell.
 * @discussion It is used to display a component with a label.
 * @discussion The component must be an MFUIBaseComponent inherited object.
 * @discussion The label is a MFLabel object.
 * @discussion The component and the label have default frames defined with constraints and are responsive to cell size.
 * @discussion The cellPropertyBinding associated to this cell is "componentView". Used this to bind a component to a ViewModel value with the "cellPropertyBinding" attribute in PLIST forms and sections descriptor files.
 */

@interface MFCell1ComponentHorizontal : MFCellAbstract

#pragma mark - Properties

/**
 * @brief The label at the top of the cell
 */
@property(nonatomic, strong) IBOutlet MFLabel *label;


/**
 * @brief The main Movalys component for this cell
 */
@property(nonatomic, strong) IBOutlet MFUIBaseComponent *componentView;

@end

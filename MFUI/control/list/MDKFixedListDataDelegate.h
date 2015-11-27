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




// Protocols and delegates
#import "MFCommonFormProtocol.h"
#import "MFTableConfiguration.h"
#import "MFFormWithDetailViewControllerProtocol.h"
#import "MFFormBaseViewController.h"
#import "MFUIFixedListAdditionalProtocol.h"

@import MDKControl.ControlFixedList;



/*!
 * @class MFFixedListDataDelegate
 * @brief This is a delegate for the MFFixedList component.
 * @discussion This delegate acts as a specific controller to bind FixedList component and its data.
 * This class is also a UITableView DataSource & Delegate.
 */
@interface MDKFixedListDataDelegate : MDKUIFixedListBaseDelegate <MFCommonFormProtocol, MFFormWithDetailViewControllerProtocol, MFUIFixedListAdditionalProtocol, MFObjectWithBindingProtocol>

#pragma mark - Methods

/*!
 * @brief Custom constructor allowing to initialize the delegate with the MFFixedList to manage
 * @param fixedList The MFFixedList component managed by this delegate
 * @return The built object
 */
-(instancetype)initWithFixedList:(MDKUIFixedList *) fixedList;

/**
 * @brief Initializes the ViewModel used by this data delegate
 */
-(void)initializeModel;
/*!
 * @brief Used to create the binding structure of this object with binding
 * @discussion Use a configuration to create the binding structure
 */
-(void) createBindingStructure;

/**
 * @brief Compute the height of the cell that contains the FixedList and dispatch it 
 * to the form controller
 */
-(void) computeCellHeightAndDispatchToFormController;


#pragma mark - Properties

/*!
 * @brief The fixedList that used this data delegate
 */
@property (nonatomic, weak) MDKUIFixedList *fixedList;

@end


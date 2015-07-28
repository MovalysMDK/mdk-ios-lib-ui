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

@class MFFixedList;



/*!
 * @class MFFixedListDataDelegate
 * @brief This is a delegate for the MFFixedList component.
 * @discussion This delegate acts as a specific controller to bind FixedList component and its data.
 * This class is also a UITableView DataSource & Delegate.
 */
@interface MFFixedListDataDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, MFCommonFormProtocol, MFFormWithDetailViewControllerProtocol, MFContentDelegate>

#pragma mark - Methods

/*!
 * @brief Custom constructor allowing to initialize the delegate with the MFFixedList to manage
 * @param fixedList The MFFixedList component managed by this delegate
 * @return The built object
 */
-(instancetype)initWithFixedList:(MFFixedList *) fixedList;

/*!
 * @brief Returns the margin to use for custom buttons. You should implement this method to customize the FixedList appearence
 * @return The margin to use in MFFixedList for custom button
 */
-(CGFloat)marginForCustomButtons;

/*!
 * @brief Returns the size to use for custom buttons. You should implement this method to customize the FixedList appearence
 * @return The size to use in MFFixedList for custom button
 */
-(CGSize)sizeForCustomButtons;

/*!
 * @brief Returns an array of custom buttons to add to the MFFixedList component. 
 * You should implement this method to customize the FixedList appearence
 * @return An array of custom buttons to add to he MFFixedList component managed by this delegate.
 */
-(NSArray *)customButtonsForFixedList;
-(void)addItemOnFixedList:(BOOL) reload;


-(void)initializeModel;
/*!
 * @brief Used to create the binding structure of this object with binding
 * @discussion Use a configuration to create the binding structure
 */
-(void) createBindingStructure;

-(void) computeCellHeightAndDispatchToFormController;


#pragma mark - Properties

/*!
 * @brief Indicates if the FixedList have been reload after cell was created
 */
@property(nonatomic) BOOL hasBeenReload;

/*!
 * @brief Form Binding Delegate. This delegate allow to bind a ViewModel to a Form easily
 */
@property(nonatomic, strong) id<MFCommonFormProtocol> formBindingDelegate ;
/*!
 * @brief The fixedList that used this data delegate
 */
@property (nonatomic, weak) MFFixedList *fixedList;

@end


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
#import "MFUIComponentProtocol.h"
#import "MFControlChangesProtocol.h"

/*!
 * @class MFTextField
 * @brief The Text Field component
 * @discussion This component inherits from iOS UITextField
 */

IB_DESIGNABLE
@interface MFTextField : UITextField <MFUIComponentProtocol, MFControlChangesProtocol>

#pragma mark - Properties

@property (nonatomic) IBInspectable BOOL onError_MDK;
@property (nonatomic) IBInspectable BOOL useCustomBackgroundView_MDK;

@property (nonatomic) Class customStyleClass;


@property (nonatomic, weak) id<MFUIComponentProtocol> sender;


#pragma mark - Methods
-(void)setIsValid:(BOOL) isValid;

/*!
 * @brief A method that is called at the initialization of the component
 * to do some treatments.
 */
-(void) initializeComponent;


/*!
 * @brief This method allows to add some views to the TextField
 * @param accessoryViews A dictionary that contains key/value pairs as follow :
 * key is a NSString  custom identifier object that correspond to a 
 * UIView accessory view value to add to the component. 
 * @discussion The key NSString-typed identifiers should be defined 
 * in a MDK style class (that implements MFStyleProtocol).
 * @see MFStyleProtocol
 */
-(void) addAccessories:(NSDictionary *) accessoryViews;


-(void) onErrorButtonClick:(id)sender;
@end


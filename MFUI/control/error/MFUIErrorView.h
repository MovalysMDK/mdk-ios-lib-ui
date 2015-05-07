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

/*! 
 * @class MFUIError
 * @brief This class represents the view that will display on MDK iOS 
 * components when they are in an invalid state.
 */
@interface MFUIErrorView : UIView

#pragma mark - IBOutlets

/*!
 * @brief The error button the user will click to display error description
 */
@property (weak, nonatomic) IBOutlet UIButton *errorButton;


#pragma mark - IBAction

/*!
 * @brief The action called when the user clicks the errorButton 
 * @param sender The sender of the action
 */
- (IBAction)onErrorButtonClick:(id)sender;

@end

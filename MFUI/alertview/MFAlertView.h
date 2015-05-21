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
#import "MFAlertViewManager.h"

/*!
 * @class MFAlertView
 * @brief This class represents a custom MDK iOS AlertView
 */
@interface MFAlertView : UIAlertView

#pragma properties

/*!
 * @brief An identifier used to identify this AlertView
 */
@property (nonatomic) MFAlertViewIdentifier identifier;


#pragma mark - Methods

/*!
 * @brief Initializes a new MFAlertView
 * @param title The title of the AlertView
 * @param message The message displayed by the AlertView
 * @param identifier The identifier of the Alertview
 * @param delegate The delegate that should manage events of the AlertView
 * @param cancelButtonTitle The title to the cancel button
 * @param otherButtonTitles The titles of the others buttons to display in the AlertView
 * @return An new instance og the AlertView
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message identifier:(NSUInteger)identifier delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

@end

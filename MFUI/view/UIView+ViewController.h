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
 * @category ViewController
 * @brief A category on UIView that allows to retrieve the ViewController
 * and the NavigationController in which is declared this view.
 */
@interface UIView (ViewController)

/*!
 * @brief Returns the parent ViewController of this view
 * @return The parent ViewController of this view if exists, nil otherwhise
 */
- (UIViewController *)parentViewController;

/*!
 * @brief Returns the parent navigation controller of this view
 * @return The parent NavigationController of this view if exists, nil otherwhise
 */
- (UINavigationController *)parentNavigationController;

/*!
 * @brief Returns the parent top ViewController of this view
 * @return The top parent ViewController of this view if exists, nil otherwhise
 */
- (UIViewController *)topParentViewController;
@end

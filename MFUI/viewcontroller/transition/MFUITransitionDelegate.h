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
//  MFUITransitionDelegate.h
//  MFUI
//
//



/**
 * @class MFUITransitionDelegate
 * @brief This protocol defines the Movalys transition delegate
 * @discussion
 */
@protocol MFUITransitionDelegate <NSObject>

@optional
/**
 * @brief Navigates to a specified UIViewController
 * @param toController The ViewController to navigate to.
 */
-(void) navigateTo:(UIViewController *) toController;

@required
/**
 * @brief Shows a specified UIViewController
 * @param  viewControllerToPresent The UIViewController to show
 * @param  flag YES if the viewControllerToPresent should be displayed animated, NO otherwhise
 * @param  completion A block executed after the viewControllerToPresent has been shown. Pass nil if no block should be executed.
 * @return 
 */
- (void)showViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
 
@end

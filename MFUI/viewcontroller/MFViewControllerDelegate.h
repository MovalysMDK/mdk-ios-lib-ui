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
//  MFViewControllerDelegate.h
//  MFCore
//
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "MFViewControllerProtocol.h"

@interface MFViewControllerDelegate : NSObject<MFViewControllerProtocol>

#pragma mark - Properties
/**
 * @brief The ViewController associated to this delegate
 */
@property (nonatomic, weak) UIViewController *viewController;

/**
 * @brief The full Frame of the controller
 */
@property (nonatomic) CGRect fullFrame;

/**
 * @brief The waiting view used during loading
 */
@property (nonatomic, strong) MBProgressHUD *waitingView;



#pragma mark - Methods
/**
 * @brief Custom initializer
 * @param the viewcontroller associated to this delegate
 * @return The create object
 */
-(id) initWithViewController:(UIViewController *)viewController ;


@end

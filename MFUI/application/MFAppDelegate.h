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

#import "MFUIViewController.h"
@import MDKControl.MDKComponentApplicationProtocol;

/*!
 * @class MFAppDelegate
 * @brief This class is the MDK AppDelegate parent class for MDK generated application
 * @discussion It defines some base treatments for MDK iOS generated application in order
 * to make MDK iOS working.
 */
@interface MFAppDelegate :  UIResponder <UIApplicationDelegate, MDKComponentApplicationProtocol>


#pragma mark - Properties

/*!
 * @brief The main window
 */
@property (strong, nonatomic) UIWindow *window;

/*!
 * @brief The transitionController used to display the menu and the central ViewController
 */
@property (strong, nonatomic) MFTransitionController *transitionController;



@end

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
//  MFViewController.h
//
//  Ce contrôleur gère :
//  - l'ouverture générique de story board à partir d'un bouton
//
//

//iOS import


//Protocols
#import "MFViewControllerProtocol.h"
#import "MFDefaultConstraintsProtocol.h"
#import "MFViewControllerObserverProtocol.h"
#import "MFViewControllerAttributes.h"


//Menu
#import "UIViewController+MFMenuManager.h"

//#import "MFUIComponents.h"

@class MFButton;

@interface MFViewController : UIViewController<MFViewControllerProtocol, MFDefaultConstraintsProtocol>


#pragma mark - Properties

/*!
 * The collection of buttons of the HomeScreen
 */
@property (strong, nonatomic) IBOutletCollection(MFButton) NSArray *buttons;

@property(strong, nonatomic) MFViewControllerAttributes *mf;

#pragma mark - Methods

/*!
 * @brief Initialize is called to initialize the view controller
 */
-(void)initialize;

/*!
 * @brief Action called when a button of the screen is called
 * @param sender The sender of the action
 */
- (IBAction)genericButtonPressed:(id)sender;

/*!
 * Show the waiting view in order to block UI
 */
-(void) showWaitingView;

/*!
 * Show the waiting view in order to block UI, with a custom waiting message
 */

-(void) showWaitingViewWithMessageKey:(NSString *) key;

/*!
 * Dismiss the waiting view if it's displayed
 */
-(void) dismissWaitingView;

/*!
 * Show the waiting view in order to block UI during a given time (in seconds)
 * @param seconds The number of seconds for displaying waiting view
 */
-(void) showWaitingViewDuring:(int)seconds;

/*!
* @brief Initialization of the menu with buttons
*
*/

/*!
 * @brief Returns a custom title for this screen
 * @discussion Here is how is the screen title computed : 
 * @discussion 1 - Check is a custom title has already been defined in Storyboard or programmatically.
 * @discussion 2 - Check if this <i>customTitle</i> method has been override. If not, it returns nil value (default).
 * @discussion 3 - If steps 1 an 2 fail, a string is retrieved from LocalizedStrings files from a dynamic-built key.
 * If no value can be retrieved for this built key, the title becomes the key itself.
 * @return The custom title
 */
-(NSString *) customTitle;

- (void) mFViewControllerViewDidAppear:(BOOL)animated;

- (void) registerObserver:(id<MFViewControllerObserverProtocol>) observer;
- (void) unregisterObserver:(id<MFViewControllerObserverProtocol>) observer;
                           

@end




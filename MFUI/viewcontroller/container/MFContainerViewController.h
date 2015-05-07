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

#import <MFCore/MFCoreContext.h>
#import "MFViewController.h"

static const int BACK_BUTTON_TAG = INT32_MAX;
static const int SAVE_BUTTON_TAG = INT32_MAX-1;

static const int ACTION_RESULT_SUCCESS = INT32_MIN;
static const int ACTION_RESULT_PENDING = INT32_MIN+1;
static const int ACTION_RESULT_FAIL = INT32_MIN+2;


/*!
 * @class MFContainerViewController
 * @brief This contraoller is a container. 
 * It can be used to display a WorkspaceViewController or a MultiPanelViewController
 * @discussion The controller manage a lot of treatments specific to the container controller.
 */
@interface MFContainerViewController : MFViewController <UIAlertViewDelegate>

#pragma mark - Methods

/*!
 * @brief  Register the children controller actions
 */
-(void) registerChildrenActions;

/*!
 * @brief  This method check if the children controllers have changed or have invalid values
 * @return YES if one or more of the childrens have changed or has invalid value, NO otherwise.
 */
-(BOOL) checkHasChangedOrAsInvalidValues;


/*!
 * @brief Callback called when the save action has succeeded
 * @param context The context used by the action
 * @param caller The caller object of the action
 * @param result The result of the action
 * @return 
 */
- (void) succeedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result;

/*!
 * @brief Callback called when the save action has failed
 * @param context The context used by the action
 * @param caller The caller object of the action
 * @param result The result of the action
 * @return
 */
- (void) failedSaveAction:(id<MFContextProtocol>)context withCaller:(id)caller andResult:(id)result;


/*!
 * @brief CallBack when back button is pressed
 * @param sender The sender of the event
 */
-(void)onBackPressed:(id)sender;

/*!
 * @brief CallBack when save button is pressed
 * @param sender The sender of the event
 */
-(void)onSavePressed:(id)sender;

/*!
 * @brief Updates the controller
 */
-(void) updateController;

/*!
 * @brief Returns the back button title of the workspace.
 * You can specify a different title when master is visible or no by checking its visibility
 * with the method "isMasterVisible" of the class MFWorkspaceView
 * @return A title for the back button
 */
-(NSString *) backButtonTitle;

/*!
 * @brief Returns the save button title of the workspace.
 * You can specify a different title when master is visible or no by checking its visibility
 * with the method "isMasterVisible" of the class MFWorkspaceView
 * @return A title for the save button
 */
-(NSString *) saveButtonTitle;

/*!
 * @brief Release all retained objects
 */
-(void)releaseRetainedObjects;

/*!
 * @brief 
 * @param 
 * @return 
 */
-(void)popViewControllerAndReleaseObjects;

@end

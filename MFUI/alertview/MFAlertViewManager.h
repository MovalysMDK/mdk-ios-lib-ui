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

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *ALERTVIEW_FAILED_SAVE_ACTION;

/**
 * @typedef MFAlertViewIdentifier
 * @brief An enumeration that allow to identify the AlertViews to show
 * @constant kFailedSavedAction Idneitifes the AlertView to show when a save action failed
 */
typedef NS_ENUM(NSUInteger, MFAlertViewIdentifier) {
    kFailedSavedAction
};


/**
 * @class MFAlertViewManager
 * @brief This class allows to manage the MDK iOS AlertViews
 * @discussion The class allows to show an AlertView and to do some treatments
 * before and.or after showing the AlertView.
 */
@interface MFAlertViewManager : NSObject

#pragma mark - Methods

/*!
 * @brief Creates and return the singleton instance of the AlertViewManager
 * @return The singleton instance of the AlertViewManager
 */
+(instancetype) getInstance;

/*!
 * @brief Shows the given alertView
 * @discussion This method allows also to do some treatmeant before 
 * and/or after showing the AlertView
 * @param alertView An AlertView to show
 */
-(void) showAlertView:(UIAlertView *)alertView ;

@end

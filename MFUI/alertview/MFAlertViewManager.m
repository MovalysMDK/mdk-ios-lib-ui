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

#import "MFAlertViewManager.h"
#import "MFAlertView.h"

NSString *ALERTVIEW_FAILED_SAVE_ACTION = @"ALERTVIEW_FAILED_SAVE_ACTION";


@implementation MFAlertViewManager

#pragma mark - Singleton management
+(instancetype) getInstance{
    //Faire un singleton
    static MFAlertViewManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Showing AlertView
-(void) showAlertView:(UIAlertView *)alertView {
    
    //Do some pre-treatments
    if([alertView isKindOfClass:[MFAlertView class]]) {
        [self treatBefore:(MFAlertView *)alertView];
    }
    
    //Show the alertView
    [alertView show];
    
    //Do some post-treatments
    if([alertView isKindOfClass:[MFAlertView class]]) {
        [self treatAfter:(MFAlertView *)alertView];
    }
}


#pragma Pre/Post treatments
/**
 * @brief Do some treatments before showing the given AlertView
 * @param alertview The AlertView that will be shown after som treatments
 */
-(void) treatBefore:(MFAlertView *)alertview {
    if(alertview.identifier == kFailedSavedAction) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ALERTVIEW_FAILED_SAVE_ACTION object:nil];
    }
}

/**
 * @brief Do some treatments after showing the given AlertView
 * @param alertview The AlertView that has be shown
 */
-(void) treatAfter:(MFAlertView *)alertview {

}
@end

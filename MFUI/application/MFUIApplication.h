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


#import <MessageUI/MFMailComposeViewController.h>
#import <MFCore/MFCoreCoredata.h>

#import "MFUIUtils.h"
#import "MFAppDelegate.h"


@interface MFUIApplication : MFApplication<MFMailComposeViewControllerDelegate>

#pragma mark - Properties
/*!
 * @brief donne le dernier view controller apparu à l'écran
 */
@property (nonatomic, weak) UIViewController *lastAppearViewController;

/*!
 * @brief indique si le traitement de l'erreur est terminée
 */
@property (nonatomic) int openPopup;

/*!
 * @brief la queue d'execution des notifications
 */
@property (nonatomic, readonly) dispatch_queue_t updateVMtoControllerQueue;

/*!
 *  @brief donne l'exception courante
 */
@property (nonatomic, weak) NSException *currentException;


#pragma mark - Methods
/*!
 *  @brief traitement des erreurs générales
 *  @param exception l'exception à logger
 */
-(void) treatUnhandledException: (NSException *) exception;

/*!
 * @brief Method called to push a report
 */
-(void) doOnPushReport;


@end

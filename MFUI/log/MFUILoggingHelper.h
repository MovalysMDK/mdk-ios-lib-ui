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

/*!
 * Help developer to manipulate application's logs.
 */
@interface MFUILoggingHelper : NSObject//<MFCreateEmailViewControllerDelegate>

/*!
 * Open two email creation screen with the two last log files.
 *
 * @param fromController : Current view controller.
 * @param recipients : email addresses.
 * @param delegate : call back for result
 */
+(int) sendEmailFrom:(UIViewController *) fromController To:(NSArray *) recipients withDelegate:(id<MFMailComposeViewControllerDelegate>) delegate;

@end

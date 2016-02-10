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
//  MFUILoggingHelper.m
//  MFUI
//
//



#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreI18n.h>

#import "MFUILoggingHelper.h"
#import "MFCreateEmailViewController.h"
#import "MFUILogging.h"

@implementation MFUILoggingHelper

static NSString *const LOG_FILE_MIME_TYPE = @"text/plain";

+(int) sendEmailFrom:(UIViewController *) fromController To:(NSArray *) recipients withDelegate:(id<MFMailComposeViewControllerDelegate>) delegate
{
    MFUILogVerbose(@"Send debug emails to %lu recipients", (unsigned long)recipients.count);
    // We create the first email with the last log file.
    MFCreateEmailViewController *emailController = [MFUILoggingHelper buildEmailTo:recipients];
    emailController.mailComposeDelegate = delegate;
    [fromController presentViewController:emailController animated:YES completion:nil];
    return 1;
}

+(MFCreateEmailViewController*) buildEmailTo:(NSArray *)recipients
{
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    MFCreateEmailViewController *emailController = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CREATE_EMAIL_VIEW_CONTROLLER];
    [emailController setSubject:[NSString stringWithFormat:MFLocalizedStringFromKey(@"DebugLogEmailTitle"), applicationName]];
    [emailController setToRecipients:recipients];
    NSData *attachment1 = [MFLoggingHelper retrieveLastLogFileWithPosition:1];
    NSData *attachment0 = [MFLoggingHelper retrieveLastLogFileWithPosition:0];
    if(attachment0 != nil || attachment1 != nil)
    {
        if(attachment0 != nil)
        {
            [emailController addAttachmentData:attachment0 mimeType:LOG_FILE_MIME_TYPE fileName:[NSString stringWithFormat:MFLocalizedStringFromKey(@"DebugLogEmailAttachmentName"), 0]];
        }
        if(attachment1 != nil)
        {
            [emailController addAttachmentData:attachment1 mimeType:LOG_FILE_MIME_TYPE fileName:[NSString stringWithFormat:MFLocalizedStringFromKey(@"DebugLogEmailAttachmentName"), 1]];
        }
        [emailController setMessageBody:[NSString stringWithFormat:MFLocalizedStringFromKey(@"DebugLogEmailHTMLBody"), applicationName] isHTML:YES];
    }
    else
    {
        [emailController setMessageBody:[NSString stringWithFormat:MFLocalizedStringFromKey(@"DebugLogEmailHTMLBodyWithNoAttachment"), applicationName] isHTML:YES];
    }
    return emailController;
}
@end

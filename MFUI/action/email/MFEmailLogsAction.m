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
//  MFEmailLogsAction.m
//  MFCore
//
//

#import <MessageUI/MFMailComposeViewController.h>

#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>

#import "MFUILogging.h"
#import "MFEmailLogsAction.h"
#import "MFUIApplication.h"


@implementation MFEmailLogsAction

/**
  * @brief open a mail controller with a attachment containing the log of the application 
  * MFEmailLogsActionSubject localizek key contains the subject of the mail.
  * The attachmnent contains max 10 files. 
  */
-(id) doAction:(id) parameterIn withContext: (id<MFContextProtocol>) context withQualifier:(id<MFActionQualifierProtocol>) qualifier withDispatcher:(MFActionProgressMessageDispatcher*) dispatch {

    MFUILogVerbose(@" MFEmailLogsAction.h doAction parameterIn '%@' ", parameterIn ) ;
    [self composeEmailWithDebugAttachment] ;
    
    return nil ;
}

- (NSMutableArray *)errorLogData
{
    DDFileLogger *logger = [MFLoggingHelper getFileLogger];
    
    NSUInteger maximumLogFilesToReturn = MIN(logger.logFileManager.maximumNumberOfLogFiles, 10);
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    
    NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}

- (void)composeEmailWithDebugAttachment
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CREATE_EMAIL_VIEW_CONTROLLER];
        NSMutableData *errorLogData = [NSMutableData data];
        for (NSData *errorLogFileData in [self errorLogData]) {
            [errorLogData appendData:errorLogFileData];
        }
        
        [mailViewController addAttachmentData:[errorLogData gzipDeflate] mimeType:@"text/plain" fileName:@"ApplicationLogs.txt"];
        [mailViewController setSubject:MFLocalizedStringFromKey(@"MFEmailLogsActionSubject")];
        [[[MFUIApplication getInstance] lastAppearViewController] presentViewController:mailViewController animated:YES completion:nil];
    }else {
        NSString *message = MFLocalizedStringFromKey(@"MFCantSendMailTechnicalError");
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:MFLocalizedStringFromKey(@"OK") otherButtonTitles: nil] show];
    }
}

@end

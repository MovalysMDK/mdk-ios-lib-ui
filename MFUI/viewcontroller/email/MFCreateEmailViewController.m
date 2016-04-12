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

#import "MFCreateEmailViewController.h"
#import "MFUILogging.h"
#import "MFLocalizedString.h"

@import MDKControl.AlertView;

@implementation MFCreateEmailViewController

-(id) init
{
    self = [super init];
    if(self)
    {
        [self initialize];
    }
    return self;
}

-(void) initialize
{
    // By default, the delegate is itself.
    self.mailComposeDelegate = self;
}

/**
 * Default delegate.
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"'Send mail' action result: canceled");
            if(self.createMailDelegate == nil
               || (self.createMailDelegate != nil && [self.createMailDelegate mailComposeController:controller didCancelWithError:error]))
            {
                NSLog(@"%@: %@", MFLocalizedStringFromKey(@"SendMailCancelledInfoTitle"), MFLocalizedStringFromKey(@"SendMailCancelledInfoMessage"));
            }
            break;
        case MFMailComposeResultSaved:
            NSLog(@"'Send mail' action result: saved");
            if(self.createMailDelegate == nil
               || (self.createMailDelegate != nil && [self.createMailDelegate mailComposeController:controller didSaveWithError:error]))
            {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"SendMailSavedAlertTitle") message:MFLocalizedStringFromKey(@"SendMailSavedAlertMessage") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"SendMailDefaultCancelButtonTitle") style:UIAlertActionStyleCancel handler:NULL];
                [alertController addAction:alertAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
            break;
        case MFMailComposeResultSent:
            NSLog(@"'Send mail' action result: Sent");
            if(self.createMailDelegate == nil
               || (self.createMailDelegate != nil && [self.createMailDelegate mailComposeController:controller didSendWithError:error]))
            {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"SendMailSentAlertTitle") message:MFLocalizedStringFromKey(@"SendMailSentAlertMessage") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"SendMailDefaultCancelButtonTitle") style:UIAlertActionStyleCancel handler:NULL];
                [alertController addAction:alertAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"'Send mail' action result: failed. Error : %@", error);
            if(self.createMailDelegate == nil
               || (self.createMailDelegate != nil && [self.createMailDelegate mailComposeController:controller didFailWithError:error]))
            {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"SendMailFailedAlertTitle") message:MFLocalizedStringFromKey(@"SendMailFailedAlertMessage") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"SendMailDefaultCancelButtonTitle") style:UIAlertActionStyleCancel handler:NULL];
                [alertController addAction:alertAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
            break;
        default:
            NSLog(@"'Send mail' action result: not sent");
            if(self.createMailDelegate == nil
               || (self.createMailDelegate != nil && [self.createMailDelegate mailComposeController:controller didNotSendWithError:error]))
            {
                MDKUIAlertController *alertController = [MDKUIAlertController alertControllerWithTitle:MFLocalizedStringFromKey(@"SendMailDefaultAlertTitle") message:MFLocalizedStringFromKey(@"SendMailDefaultAlertMessage") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:MFLocalizedStringFromKey(@"SendMailDefaultCancelButtonTitle") style:UIAlertActionStyleCancel handler:NULL];
                [alertController addAction:alertAction];
                [self.parentViewController presentViewController:alertController animated:true completion:NULL];
            }
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

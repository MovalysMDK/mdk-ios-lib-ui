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
//  MFUIApplication.m
//  MFUI
//
//

#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFStarter.h>

#import "MFUIApplication.h"
#import "MFUILoggingHelper.h"
#import "MFViewControllerProtocol.h"

const int TAG_FOR_EXCEPTION_ALERT = 1 ;

@implementation MFUIApplication

-(id) init {
    if (self = [super init]) {
        _updateVMtoControllerQueue = dispatch_queue_create("updateVMtoControllerQueue", NULL);
    }
    return self;
}

-(void) doOnPushReport {
    MFConfigurationHandler* registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    if ([registry getBooleanProperty:MFPROP_PUSH_MAIL_ON_CRASH withDefault:NO]) {
        self.openPopup += [MFUILoggingHelper sendEmailFrom:self.lastAppearViewController To: [registry getArrayProperty:MFPROP_ADMIN_EMAILS] withDelegate:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *) error{
    self.openPopup--;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) showWaitingView {
    if ([self.lastAppearViewController conformsToProtocol:@protocol(MFViewControllerProtocol)]) {
        [self.lastAppearViewController performSelector:@selector(showWaitingView)];
    }
}

- (void) dismissWaitingView {
    if ([self.lastAppearViewController  conformsToProtocol:@protocol(MFViewControllerProtocol)]) {
        [self.lastAppearViewController performSelector:@selector(dismissWaitingView)];
    }
}

-(void) treatUnhandledException: (NSException *) exception {
    
    MFCoreLogError(@"Exception catched : (name %@), (reason %@) (userinfo%@) (debug %@) (stack symb %@)",
                   exception.name, exception.reason , exception.userInfo , exception.debugDescription ,  exception.callStackSymbols );

    [MFStarter getInstance].appFailure = YES ;
    
    self.currentException = exception;
    self.openPopup = 0;
    if([self isInMainQueue]) {
        [self showAlert:exception];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:exception];
        });
    }
    
    self.openPopup = 1;
    
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (self.openPopup!=0)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    self.currentException = nil;
    self.openPopup = 0;
    
    [exception raise];
    
    NSSetUncaughtExceptionHandler(NULL);
}


- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anAlertView.tag == TAG_FOR_EXCEPTION_ALERT){
        self.openPopup--;
        if (anIndex == 1) {
            [self doOnPushReport];
        }
    }
}


-(void) showAlert:(NSException *) exception {
    UIAlertView *alert = nil;
    MFConfigurationHandler *registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    if ([registry getBooleanProperty:MFPROP_PUSH_MAIL_ON_CRASH withDefault:NO]) {
        alert = [[UIAlertView alloc]
                 initWithTitle:MFLocalizedStringFromKey(@"MFUnhandledExceptionTitle")
                 message:[NSString stringWithFormat:MFLocalizedStringFromKey(@"MFUnhandledExceptionMessage"),
                          [exception reason],
                          [exception name]]
                 delegate:self
                 cancelButtonTitle:MFLocalizedStringFromKey(@"MFUnhandledExceptionQuitButton")
                 otherButtonTitles:MFLocalizedStringFromKey(@"MFUnhandledExceptionSendLogButton"), nil];
    }
    else {
        alert = [[UIAlertView alloc]
                 initWithTitle:MFLocalizedStringFromKey(@"MFUnhandledExceptionTitle")
                 message:[NSString stringWithFormat:MFLocalizedStringFromKey(@"MFUnhandledExceptionMessage"),
                          [exception reason],
                          [exception name]]
                 delegate:self
                 cancelButtonTitle:MFLocalizedStringFromKey(@"MFUnhandledExceptionQuitButton") otherButtonTitles: nil];
    }
    alert.tag = TAG_FOR_EXCEPTION_ALERT ;
    [alert show];
    
}

@end

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
//  MFViewControllerDelegate+MFUIViewControllerDelegate.m
//  MFUI
//
//

#import <MFCore/MFCoreAction.h>
#import "MFViewControllerDelegate+MFUIViewControllerDelegate.h"
#import "MFUILogging.h"
#import "MFUIApplication.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MFCore/MFCoreI18n.h>
#import "MFButton.h"
#import "MFMultiPanelViewController.h"

@implementation MFViewControllerDelegate (MFUIViewControllerDelegate)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"


-(void) showWaitingView {
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
     self.waitingView = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
     self.waitingView.mode = MBProgressHUDModeIndeterminate;
     self.waitingView.labelText = MFLocalizedStringFromKey(@"waiting.view.loading.data");
     });*/
    
    
//    if(![self.viewController isKindOfClass:[MFMultiPanelViewController class]]) {
        [self showWaitingViewWithMessageKey:@"waiting.view.loading.data"];
//    }
    
    
}


-(void) showWaitingViewWithMessageKey:(NSString *) key {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingView = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
        self.waitingView.mode = MBProgressHUDModeIndeterminate;
        self.waitingView.labelText = MFLocalizedStringFromKey(key);
        self.waitingView.removeFromSuperViewOnHide = YES;
    });
}


-(void) dismissWaitingView {
    
    if(self.waitingView && ![self.waitingView isHidden]) {
        [self.waitingView hide:YES];
    }
}

-(void) showWaitingViewDuring:(int)seconds {
    [self showWaitingView];
    if(self.waitingView && ![self.waitingView isHidden]) {
        [self.waitingView hide:YES afterDelay:seconds];
    }}

-(IBAction)genericButtonPressed:(id)sender
{
    if ([sender isKindOfClass:[MFButton class]]){
        
        MFButton *mfbutton = sender;
        
        if ([mfbutton respondsToSelector:@selector(mf)]) {
            NSString *storyboardName = mfbutton.mf.storyboardTargetName;
            if (storyboardName != nil) {
                MFUILogVerbose(@"Button try to load %@", storyboardName);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                
                UIViewController *initialViewController = [storyboard instantiateInitialViewController];
                /*[self.navigationController pushViewController:initialViewController animated:YES];
                 */
                [self.viewController.navigationController pushViewController:initialViewController animated:YES];
                //             [[MFActionLauncher getInstance] launchActionWithoutWaitingView:@"MTestAction" withCaller:self withInParameter:nil];
                MFUILogVerbose(@"After launching ...");
                
            }    else {
                MFUILogVerbose(@"Nothing to launch ...");
            }
            
        }
        
    } else {
        MFUILogWarn(@"You should use a UIButton.");
    }
}
#pragma clang diagnostic pop

@end

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



//MFCore imports
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreFormDescriptor.h>

//Main interface
#import "MFFormViewControllerValidationDelegate.h"

//ViewModel
#import "MFUIBaseViewModel.h"
#import "MFFormViewController.h"

@implementation MFFormViewControllerValidationDelegate


//TODO: sauvegarde automatique
-(BOOL) onCloseFormDoAlert:(BOOL)isAlert andSave:(BOOL)save {
    BOOL hasInvalidInputs = [self hasInvalidValues];
    
    if ( ((MFUIBaseViewModel *)self.formController.viewModel).hasChanged || hasInvalidInputs) {
        if ( isAlert ) {
            
            if ( !save) {
                // Alert and no save => discard changes dialog
                UIAlertView *discardChangesAlert = [[UIAlertView alloc]
                                                    initWithTitle:MFLocalizedStringFromKey(@"alert_discardchanges_title")
                                                    message:MFLocalizedStringFromKey(@"alert_discardchanges_message")
                                                    delegate:self.formController cancelButtonTitle:MFLocalizedStringFromKey(@"alert_discardchanges_no") otherButtonTitles:MFLocalizedStringFromKey(@"alert_discardchanges_yes"), nil];
                discardChangesAlert.tag = kDiscardChangesAlert;
                [discardChangesAlert show];
            }
            else {
                // Alert and save => ask user for save
                UIAlertView *cancelSaveAlert = [[UIAlertView alloc]
                                                initWithTitle:MFLocalizedStringFromKey(@"alert_savechanges_title")
                                                message:MFLocalizedStringFromKey(@"alert_savechanges_message")
                                                delegate:self.formController cancelButtonTitle:MFLocalizedStringFromKey(@"alert_savechanges_no") otherButtonTitles:MFLocalizedStringFromKey(@"alert_savechanges_yes"), nil];
                cancelSaveAlert.tag = kSaveChangesAlert;
                [cancelSaveAlert show];
            }
            return YES ;
        } else if ( save ) {
            MFFormViewController *form = (MFFormViewController *) self.formController ;
            [form doOnKeepModification:self.formController];
            return YES ;
        }
        return YES;
    }
    else {
        return NO;
    }
}


@end

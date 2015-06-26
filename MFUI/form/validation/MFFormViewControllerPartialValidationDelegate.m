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

//Main interface
#import "MFFormViewControllerPartialValidationDelegate.h"

//ViewModel
#import "MFUIBaseViewModel.h"
#import "MFFormViewController.h"

@implementation MFFormViewControllerPartialValidationDelegate


-(BOOL)hasInvalidValues {
    BOOL response = NO;
    if(self.invalidInputs.count > 0 ) {
        return YES;
    }
    MFUIBaseViewModel *mainViewModel = (MFUIBaseViewModel*)self.formController.viewModel;
    MFFormViewController *formBaseController = (MFFormViewController *)self.formController;
    for(NSString *viewModelKey in [formBaseController partialViewModelKeys]) {
        MFUIBaseViewModel *viewModel = [mainViewModel valueForKey:viewModelKey];
        for(MFUIBaseViewModel *childViewModel in [viewModel getChildViewModels]) {
            if([childViewModel getForm]) {
                id<MFCommonFormProtocol> childFormController = [childViewModel getForm];
                if(childFormController && childFormController.formValidation && ![childFormController.formValidation isEqual:self]) {
                    response = response || [childFormController.formValidation hasInvalidValues];
                }
                if(response) {
                    break;
                }
            }
        }
        if(response) {
            break;
        }
    }
    return response;
}

@end

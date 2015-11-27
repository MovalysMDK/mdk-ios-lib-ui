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


#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreI18n.h>

#import "MFUILog.h"

#import "MFFormValidationDelegate.h"
#import "MFUIBaseListViewModel.h"
#import "MFUIControl.h"
#import "MFAbstractControlWrapper.h"

const int kDiscardChangesAlert = 10 ;
const int kSaveChangesAlert = 11 ;

@implementation MFFormValidationDelegate

-(id) initWithFormController:(id<MFCommonFormProtocol>)formController {
    self = [super init];
    if (self) {
        [self initialize:formController];
    }
    return self;
}

-(void) initialize:(id<MFCommonFormProtocol>)formController {
    self.formController = formController ;
    self.invalidInputs = [[NSMutableDictionary alloc] init];
    self.errorForInvalidInputs = [[NSMutableDictionary alloc] init];
    self.deferredErrors = [[NSMutableDictionary alloc] init];
}

-(BOOL) validateViewModel:(id<MFUIBaseViewModelProtocol>)vm {
    BOOL valid = YES;
    if([vm isKindOfClass:[MFUIBaseViewModel class]]) {
        id<MFObjectWithBindingProtocol> objectWithBinding = ((MFUIBaseViewModel *)vm).objectWithBinding;
        NSDictionary *components = objectWithBinding.bindingDelegate.binding.bindingByComponents;
        for(MFBindingValue *bindingValue in components.allValues) {
            UIView *view = [bindingValue.wrapper component];
            if(([view conformsToProtocol:@protocol(MFComponentValidationProtocol)] || [view conformsToProtocol:@protocol(MDKControlValidationProtocol)]) &&
               [view respondsToSelector:@selector(validate)]) {
                //ATTENTION : c'est bien l'opérateur '&' et non '&&' afin de continuer la validation des autres
                //composant même dans le cas ou la validation a déja échoué.
                valid = valid & ([((id<MFComponentValidationProtocol>)view) validate] == 0);
            }
        }
    }
    
    return valid;
}


-(BOOL) hasInvalidValues {
    BOOL response = NO;
    if(self.invalidInputs.count > 0 ) {
        return YES;
    }
    MFUIBaseViewModel *viewModel = (MFUIBaseViewModel*)self.formController.viewModel;
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
    return response;
}

-(void) resetValidation {
    [self.errorForInvalidInputs removeAllObjects];
    [self.deferredErrors removeAllObjects];
    [self.invalidInputs removeAllObjects];
}

@end

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
#import <MFCore/MFCoreFormDescriptor.h>

#import "MFUILog.h"

#import "MFFormValidationDelegate.h"
#import "MFUIBaseListViewModel.h"
#import "MFUIControl.h"

const int kDiscardChangesAlert = 10 ;
const int kSaveChangesAlert = 11 ;

@implementation MFFormValidationDelegate

-(id) initWithFormController:(id<MFBindingFormDelegate>)formController {
    self = [super init];
    if (self) {
        [self initialize:formController];
    }
    return self;
}

-(void) initialize:(id<MFBindingFormDelegate>)formController {
    self.formController = formController ;
    self.invalidInputs = [[NSMutableDictionary alloc] init];
    self.errorForInvalidInputs = [[NSMutableDictionary alloc] init];
    self.deferredErrors = [[NSMutableDictionary alloc] init];
}

-(BOOL) validateViewModel:(id<MFUIBaseViewModelProtocol>)vm {
    BOOL valid = YES;
    
    // Check form has no invalid input
    if ( [self.invalidInputs count] != 0 ) {
        valid = NO;
    }
    
    
    // Check mandatory fields
    int sectionNr = 0 ;
    for( MFSectionDescriptor *sectionDesc in self.formController.formDescriptor.sections ) {
        int groupNr = 0 ;
        NSInteger groupSize = [sectionDesc orderedGroups].count;
        if([self.formController isKindOfClass:[MFFixedListDataDelegate class]]) {
            MFUIBaseListViewModel *parentViewModel = (MFUIBaseListViewModel *)((MFFixedListDataDelegate*)self.formController).viewModel;
            groupSize = parentViewModel.viewModels.count;
        }
        for(int groupIndex = 0 ; groupIndex < groupSize ; groupIndex++) {
           
            MFGroupDescriptor *groupDesc = nil;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:groupNr inSection:sectionNr];
            if([self.formController isKindOfClass:[MFFixedListDataDelegate class]]) {
                MFUIBaseListViewModel *parentViewModel = (MFUIBaseListViewModel *)((MFFixedListDataDelegate*)self.formController).viewModel;
                indexPath = [NSIndexPath indexPathForRow:[parentViewModel.viewModels indexOfObject:vm] inSection:0];
                groupDesc = [[sectionDesc orderedGroups] objectAtIndex:0];
            }
            else {
                groupDesc = [[sectionDesc orderedGroups] objectAtIndex:groupIndex];
            }
            
            for( MFFieldDescriptor *fieldDesc in [groupDesc fields]) {
                
                NSString *fullBindingKey  = [self.formController bindingKeyWithIndexPathFromKey:fieldDesc.bindingKey andIndexPath:indexPath];
                
                // tests mandatory only if no other error before.
                if ( ![self hasInvalidValueForFullBindingKey:fullBindingKey]) {
                    
                    //TODO: mandatory peut etre une methode
                    if ( [fieldDesc.mandatory isEqualToString:@"YES"] ) {
                        id value = nil ;
                        if(self.formController.viewModel) {
                            if([self.formController.viewModel isKindOfClass:[MFUIBaseListViewModel class]]) {
                                if(indexPath.row < ((MFUIBaseListViewModel *)self.formController.viewModel).viewModels.count) {
                                    value = [[((MFUIBaseListViewModel *)self.formController.viewModel).viewModels objectAtIndex:indexPath.row] valueForKeyPath:fieldDesc.bindingKey];
                                }
                                else {
                                    value = [NSNull null];
                                }
                            }
                            else {
                                value = [self.formController.viewModel valueForKeyPath:fieldDesc.bindingKey];
                            }
                        }
                        if (!value  || [value isEqual:[NSNull null]]) {
                            
                            NSString *errorText = [NSString stringWithFormat:@"Champs obligatoire"];
                            NSError *error = [[NSError alloc] initWithDomain:@"Champs obligatoire"
                                                                        code:2 userInfo:@{NSLocalizedDescriptionKey : errorText}];
                            if (! [self.formController addError:@[error] onComponent:fieldDesc.bindingKey atIndexPath:indexPath]) {
                                [self.deferredErrors setObject:@[error] forKey:fullBindingKey];
                            }
                            MFUILogError(@"*******************************************");
                            MFUILogError(@"ERREUR : %@ on FIELD : %@", error, fieldDesc.bindingKey);
                            MFUILogError(@"*******************************************");
                            valid = NO;
                        }
                        else {
                            if ( [[value class] conformsToProtocol:@protocol(MFUIBaseViewModelProtocol)] ){
                                id<MFUIBaseViewModelProtocol> subVm = (id<MFUIBaseViewModelProtocol> )value;
                                if ( ![subVm validate]) {
                                    NSString *errorText = [NSString stringWithFormat:@"Champs obligatoire"];
                                    NSError *error = [[NSError alloc] initWithDomain:@"Champs obligatoire"
                                                                                code:2 userInfo:@{NSLocalizedDescriptionKey : errorText}];
                                    MFUILogError(@"*******************************************");
                                    MFUILogError(@"ERREUR : %@ on FIELD : %@", error, fieldDesc.bindingKey);
                                    MFUILogError(@"*******************************************");
                                    
                                    [self.formController addError:@[error] onComponent:fieldDesc.bindingKey atIndexPath:indexPath];
                                    valid = NO;
                                }
                            }
                        }
                    }
                }
            }
            groupNr++;
        }
        sectionNr++;
    }
    return valid;
}


-(BOOL) validateNewValue:(id)newValue onComponent:(id<MFUIComponentProtocol>)component withFullBindingKey:(NSString *)fullBindingKey {
    BOOL valid = YES ;
    
    // remove from deferred errors because component is visible
    [self.deferredErrors removeObjectForKey:fullBindingKey];
    
    if ( [component isValid] ) {
        [self.invalidInputs removeObjectForKey:fullBindingKey];
        [self.errorForInvalidInputs removeObjectForKey:fullBindingKey];
    }
    else {
        [self.invalidInputs setObject:newValue forKey:fullBindingKey];
        [self.errorForInvalidInputs setObject:[component getErrors] forKey:fullBindingKey];
        valid = NO ;
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
            id<MFBindingFormDelegate> childFormController = [childViewModel getForm];
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


-(BOOL) hasInvalidValueForFullBindingKey:(NSString *)fullBindingKey {
    BOOL hasInvalidValue = [[self.invalidInputs allKeys] containsObject:fullBindingKey];
    return hasInvalidValue;
}

-(id) getInvalidValueForFullBindingKey:(NSString *)fullBindingKey {
    id invalidValue = [self.invalidInputs objectForKey:fullBindingKey];
    return invalidValue;
}

-(NSArray *) getErrorsForFullBindingKey:(NSString *)fullBindingKey {
    NSArray *errors = [self.errorForInvalidInputs objectForKey:fullBindingKey];
    return errors;
}

-(id) getDeferredErrorForFullBindingKey:(NSString *)fullBindingKey {
    return [self.deferredErrors objectForKey:fullBindingKey];
}

-(void) addDeferredErrorsOnComponent:(id<MFUIComponentProtocol>)component withFullBindingKey:(NSString *)fullBindingKey{
    NSArray *errors = [self getDeferredErrorForFullBindingKey:fullBindingKey];
    if ( errors != nil ) {
        [component addErrors:errors];
    }
}

-(void) resetValidation {
    [self.errorForInvalidInputs removeAllObjects];
    [self.deferredErrors removeAllObjects];
    [self.invalidInputs removeAllObjects];
}

@end

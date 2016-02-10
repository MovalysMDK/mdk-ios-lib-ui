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
//  MFUIBaseViewModel.m
//  MFUI
//
//

#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreLog.h>

#import "MFUIBaseViewModel.h"
#import "MFUIApplication.h"
#import "MFUILogging.h"
#import "MFFormViewController.h"
#import "MFFormValidationDelegate.h"

@implementation MFUIBaseViewModel
@synthesize form = _form;
@synthesize hasChanged = _hasChanged;

#pragma mark - Constructeurs

- (id)init
{
    self = [super init];
    if (self) {
        [self addListenerForSyncProperties];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    if (copy) {
        for (NSString *key in [self getCopyProperties]) {
            [copy setValue:[self valueForKey:key] forKey:key];
        }
    }
    return copy;
}


#pragma mark - Méthodes privées

/**
 * @brief Cette méthode permet d'ajouter un écouteur sur toutes les propriétés définies comme bindées au formulaire
 */
- (void) addListenerForSyncProperties
{
    
    NSArray * allProperties = [[self getBindedProperties] arrayByAddingObjectsFromArray:[self getCustomBindedProperties]];
    for (NSString *key in allProperties) {
        [self addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    }
}


/**
 * @brief Surcharge pour modifier la valeur du booléen hasChanged
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];

    if (![value isEqual:self] && [value isKindOfClass:[MFUIBaseViewModel class]]) {
        ((MFUIBaseViewModel *) value).parentViewModel = self;
    }

    self.hasChanged = YES;
}


#pragma mark - Méthodes publiques

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    //    MFCoreLogVerbose(@"Les changements qui ont eu lieu sur le champ %@ sont les suivants : \n %@",keyPath,change);

    //Vérification de la nouvelle valeur par rapport à l'ancienne avant de propager l'évènement
    id oldValue = [change objectForKey:@"old"];
    id newValue = [change objectForKey:@"new"];

    if (oldValue != nil || newValue != nil) {
        if (oldValue != nil && newValue != nil) {
            if ([oldValue respondsToSelector:@selector(isEqualToString:)]) {
                if (![oldValue isEqualToString:newValue]) {
                    self.hasChanged = YES;
                    //                   dispatch_async([MFUIApplication getInstance].updateVMtoControllerQueue, ^{
                    [[self getForm] dispatchEventOnViewModelPropertyValueChangedWithKey:keyPath sender:self];
                    //                   });
                }
            }else {
                if (![oldValue isEqual:newValue]) {
                    self.hasChanged = YES;
                    //                    dispatch_async([MFUIApplication getInstance].updateVMtoControllerQueue, ^{
                    [[self getForm] dispatchEventOnViewModelPropertyValueChangedWithKey:keyPath sender:self];
                    //                    });
                }
            }
        }else {
            self.hasChanged = YES;
            //            dispatch_async([MFUIApplication getInstance].updateVMtoControllerQueue, ^{
            [self.form dispatchEventOnViewModelPropertyValueChangedWithKey:keyPath sender:self];
            //            });
        }
    }
}


- (NSArray *)getBindedProperties
{
    [MFException throwNotImplementedExceptionOfMethodName:@"getBindedProperties" inClass:self.class andUserInfo:nil];
    return @[];
}


- (NSArray *)getChildViewModels
{
    [MFException throwNotImplementedExceptionOfMethodName:@"getChildViewModels" inClass:self.class andUserInfo:nil];
    return @[];
}


- (NSArray *)getCustomBindedProperties
{
    return [NSArray array];
}


- (id)valueForUndefinedKey:(NSString *)key
{
    NSString * className = NSStringFromClass([self class]);
    if ([key rangeOfString:@"-label"].location == NSNotFound) {
        MFCoreLogWarn(@"Binding error of the key '%@' in the class %@ ", key, className );
    }
    //Arc ne fait pas le boulot quand on lance une exception (à priori c'est fait exprès on ne doit lancer une exception
    //que si l'application est arrêtée
    //donc pas d'exception dans ce cas
    //[NSException raise:@"Binding error" format:@"No binding %@.%@", className, key];
    return [MFKeyNotFound keyNotFound];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    MFCoreLogWarn(@"The property with key %@ is not defined in %@", key, NSStringFromClass([self class]) );
}


- (void)dealloc
{
    [self resetViewModel];
}


- (void) resetViewModel
{
    for (NSString *keyPath in [self getBindedProperties]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
    for (NSString *keyPath in [self getCustomBindedProperties]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}


- (void)clear
{
    // does nothing at the moment
}


- (void) setForm:(id<MFViewModelChangedListenerProtocol, MFBindingFormDelegate>)form
{
    _form = form;
    for (MFUIBaseViewModel *childViewModel in [self getChildViewModels]) {
        childViewModel.form = form;
    }
}


- (id<MFViewModelChangedListenerProtocol, MFBindingFormDelegate>) getForm
{
    if (self.form) {
        return self.form;
    }
    if (self.parentViewModel) {
        return self.parentViewModel.form;
    }
    return nil;
}


- (NSArray *)getCopyProperties
{
    NSMutableArray *allCopyProperties = [[self getBindedProperties] mutableCopy];
    [allCopyProperties addObjectsFromArray:[self getCustomBindedProperties]];
    return allCopyProperties;
}


- (BOOL) validate
{
    BOOL isValid = YES;
    id<MFViewModelChangedListenerProtocol,
       MFBindingFormDelegate> formController = (id<MFViewModelChangedListenerProtocol, MFBindingFormDelegate>) [self getForm];
    if (formController) {
        isValid = [formController.formValidation validateViewModel:self];
    }
    for (MFUIBaseViewModel *childViewModel in [self getChildViewModels]) {
        //        childViewModel.form = formController;
        isValid = isValid && [childViewModel validate];
    }
    return isValid;
}


- (void) setHasChanged:(BOOL)hasChanged
{
    _hasChanged = hasChanged;
    if (_hasChanged && self.parentViewModel != nil) {
        self.parentViewModel.hasChanged = YES;
    }
}


- (void) resetChanged
{
    _hasChanged = NO;
    for (id<MFUIBaseViewModelProtocol> vmChild in self.getChildViewModels) {
        [vmChild resetChanged];
    }
}


- (void) updateFromIdentifiable:(id)entity
{
    MFCoreLogVerbose(@"MFUIBaseViewModel updateFromIdentifiable does nothing");
}


- (void) modifyToIdentifiable:(id)entity inContext:(id<MFContextProtocol>)context
{
    MFCoreLogVerbose(@"MFUIBaseViewModel modifyToIdentifiable does nothing");
}


@end


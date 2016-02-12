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


#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreLog.h>

#import "MFUIForm.h"

#import "MFUIBaseListViewModel.h"

@implementation MFUIBaseListViewModel
@synthesize form = _form;
@synthesize hasChanged = _hasChanged;
@synthesize objectWithBinding = _objectWithBinding;

-(id) init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void) initialize {
    self.viewModelName = [self defineViewModelName];
    NSMutableArray *tempMutable = [NSMutableArray array];
    
    if(self.viewModelName && self.numberOfItems) {
        for (int index = 0 ; index < self.numberOfItems ; index++) {
            id<MFUIBaseViewModelProtocol> viewModel = (id<MFUIBaseViewModelProtocol>)[[NSClassFromString(self.viewModelName) alloc] init];
            [tempMutable addObject:viewModel];
        }
    }
    [self updateViewModels:tempMutable];
    self.hasChanged = NO ;
    //[self addListenerForSyncProperties];
}

-(NSString *)defineViewModelName {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes" userInfo:nil]);
    
}

-(NSUInteger)defineNumberOfItems {
    return self.viewModels.count;
}

-(void)setForm:(id<MFCommonFormProtocol>)form {
    if(self.viewModels && form) {
        for(id<MFUIBaseViewModelProtocol> viewModel in self.viewModels) {
            [viewModel setForm:form];
        }
    }
    _form = form;
}

-(void)setObjectWithBinding:(NSObject<MFObjectWithBindingProtocol> *)objectWithBinding {
    if(self.viewModels && objectWithBinding) {
        for(id<MFUIBaseViewModelProtocol> viewModel in self.viewModels) {
            [viewModel setObjectWithBinding:objectWithBinding];
        }
    }
    _objectWithBinding = objectWithBinding;
}

- (id)valueForUndefinedKey:(NSString *)key{
    NSString* className = NSStringFromClass([self class]);
    if([className rangeOfString:@"-label"].location == NSNotFound) {
        MFCoreLogWarn(@"Binding error of the key '%@' in the class %@ " , key , className );
    }    //Arc ne fait pas le boulot quand on lance une exception (a priori c'est fait expres on ne doit lancer une exception
    //que si l'application est arretee
    //donc pas d'exception dans ce cas
    //[NSException raise:@"Binding error" format:@"No binding %@.%@", className, key];
    return [MFKeyNotFound keyNotFound];
}

-(void) clear {
    self.fetch = nil;
    @synchronized(self.viewModels) {
        [self.viewModels removeAllObjects];

    }
}

-(void) updateViewModels:(NSArray <MFUIBaseViewModel *>*)viewModels {
    _viewModels = viewModels;
}

-(void) add:(MFUIBaseViewModel *)itemVm {
	[self.viewModels addObject:itemVm];
    itemVm.parentViewModel = self;
    self.hasChanged = YES ;
}

-(void) add:(MFUIBaseViewModel *)itemVm atIndex:(NSInteger)index {
	while( [self.viewModels count] <= index ) {
        [self.viewModels addObject:[NSNull null]];
    }
    [self.viewModels replaceObjectAtIndex:index withObject:itemVm];
    itemVm.parentViewModel = self;
    self.hasChanged = YES ;
}

-(void) deleteItem:(MFUIBaseViewModel *)itemVm {
    [self.viewModels removeObject:itemVm];
    self.hasChanged = YES ;
}

-(void) deleteItemAtIndex:(NSInteger)index {
    if(index < self.viewModels.count && index >= 0) {
        [self.viewModels removeObjectAtIndex:index];
    }
    self.hasChanged = YES ;
}


-(void) setHasChanged:(BOOL)hasChanged {
    _hasChanged = hasChanged ;
    if ( _hasChanged && self.parentViewModel != nil ) {
        self.parentViewModel.hasChanged = YES ;
    }
}

-(void) resetChanged {
    _hasChanged = NO ;
    
    // reset changed of all items in the viewmodel
    for( id<MFUIBaseViewModelProtocol> vmChild in self.viewModels) {
        if(![vmChild isEqual:[NSNull null]]) {
            [vmChild resetChanged];
        }
    }
}

-(id<MFCommonFormProtocol>) getForm {
    if(self.form) {
        return self.form;
    }
    if(self.parentViewModel) {
        return self.parentViewModel.form;
    }
    return nil;
}

-(BOOL) validate {
    BOOL validate = YES;
    id<MFCommonFormProtocol> formController = (id<MFCommonFormProtocol>) [self getForm];
    for(MFUIBaseViewModel *model in self.viewModels) {
        if(formController && [formController respondsToSelector:@selector(formValidation)]) {
            validate = validate && [formController.formValidation validateViewModel:model];
        }
    }
    return validate;
}

- (NSArray *)getChildViewModels
{
    return [self viewModels];
}
@end

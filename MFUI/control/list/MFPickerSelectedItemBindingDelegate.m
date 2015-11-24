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

#import "MFPickerSelectedItemBindingDelegate.h"
#import "MFPickerList.h"
#import "MFObjectWithBindingProtocol.h"
#import "MFPickerListconfiguration.h"

@interface MFPickerSelectedItemBindingDelegate()
@property (nonatomic) BOOL computeAlreadyDone;

@end



@implementation MFPickerSelectedItemBindingDelegate
@synthesize bindingDelegate = _bindingDelegate;
@synthesize viewModel = _viewModel;
@synthesize formValidation = _formValidation;

- (instancetype)initWithPickerList:(MFPickerList *)pickerList
{
    self = [super init];
    if (self) {
        self.picker = pickerList;
        [self initialize];
        
    }
    return self;
}


-(void) initialize {
    [self initializeBinding];
    [self initializeModel];
    [self.bindingDelegate clear];
    [self createBindingStructure];
    [self initializeStaticBinding];
}

-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
}

#pragma mark - New Binding
-(void)setBindingDelegate:(MFBindingDelegate *)bindingDelegate {
    _bindingDelegate = bindingDelegate;
    if(bindingDelegate) {
        [self createBindingStructure];
    }
    
}

-(void)createBindingStructure {
    for(MFBindingValue *bindingValue in [self.bindingDelegate allBindingValues]) {
        [self.bindingDelegate.binding dispatchValue:[self.viewModel valueForKey:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName fromSource:bindingValue.bindingSource];
    }
}

-(void) initializeStaticBinding {
    MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[SELECTEDITEM_PICKERLIST_DESCRIPTOR];
    NSString *xibName = bindingData.viewIdentifier;
    self.picker.selectedView = [[[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil] firstObject];
    [self.picker.selectedView bindViewFromDescriptor:bindingData onObjectWithBinding:self];
}

-(void) initializeModel {
    self.viewModel.objectWithBinding = self;
}


-(id<MFUIBaseViewModelProtocol>)getViewModel {
    id object = [self.picker getData];
    return object;
}

-(void) computeCellHeightAndDispatchToFormController {
    
    if(!self.computeAlreadyDone) {
        MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[SELECTEDITEM_PICKERLIST_DESCRIPTOR];
        float itemHeight = [bindingData.viewHeight floatValue];
        
        UIViewController *parent = self.picker.parentViewController;
        if(parent && [parent conformsToProtocol:@protocol(MFObjectWithBindingProtocol)]) {
            id<MFObjectWithBindingProtocol> parentObjectWithBinding = (id<MFObjectWithBindingProtocol>)parent;
            MFBindingValue *selfBindingValue = parentObjectWithBinding.bindingDelegate.binding.bindingByComponents[@(self.picker.hash)];
            if(selfBindingValue) {
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"MDK_ComponentSize_%@_%@", parentObjectWithBinding, [selfBindingValue.bindingIndexPath stringIndexPath]] object:@{@"height":@(itemHeight), @"mustReload":@(YES)}];

            }
        }
        self.computeAlreadyDone = YES;
    }
}

-(void) updateStaticView {
    MFBindingViewDescriptor *bindingData = ((MFBindingViewDescriptor *)self.bindingDelegate.structure[SELECTEDITEM_PICKERLIST_DESCRIPTOR]);
    for(MFBindingValue *bindingValue in [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]]) {
        [self.bindingDelegate.binding dispatchValue:[[self getViewModel] valueForKey:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName fromSource:bindingValue.bindingSource];
    }
}

-(void)dealloc {
    self.bindingDelegate = nil;
}

@end

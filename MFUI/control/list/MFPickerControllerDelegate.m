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
//  MFPickerControllerDelegate.m
//  MFUI
//
//

//MFCore imports
#import <MFCore/MFCoreError.h>


//Main intrface
#import "MFPickerControllerDelegate.h"

//Cell import
#import "MFCellAbstract.h"

//Protocol imports
#import "MFUIBaseViewModelProtocol.h"
#import "MFTypeValueProcessingProtocol.h"

#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import "MFUIBaseListViewModel.h"

#import "MFAbstractComponentWrapper.h"



int static UNIQUE_PICKER_LIST_SECTION_INDEX = 0;


@interface MFPickerControllerDelegate()
@property (nonatomic) BOOL computeAlreadyDone;

@end


@implementation MFPickerControllerDelegate

@synthesize viewModel =_viewModel;
@synthesize formValidation =_formValidation;
@synthesize bindingDelegate = _bindingDelegate;


#pragma mark - Initialization and lifecycle

-(id) initWithPickerList:(MFPickerList *)pickerList {
    self = [super init];
    if(self) {
        self.picker = pickerList;
        [self initialize];
    }
    return self;
}

-(void) initialize {
    self.filteredViewModels = [self initializeFilteredViewModels];
    
    [self initializeBinding];
    [self initializeModel];
    [self.bindingDelegate clear];
    [self createBindingStructure];
    [self initializeStaticBinding];
}

-(void) initializeStaticBinding {
    MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[SELECTEDITEM_PICKERLIST_DESCRIPTOR];
    NSString *xibName = bindingData.viewIdentifier;
    self.picker.staticView = [[[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil] firstObject];
    [self.picker.staticView bindViewFromDescriptor:bindingData onObjectWithBinding:self];
}

#pragma mark - UIPickerView DataSource & Delegate


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filteredViewModels.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:component];
    
    MFBindingViewDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    NSString *identifier = bindingData.viewIdentifier;
    
    MFBindingViewAbstract *pickerItemView = (MFBindingViewAbstract *)view;
    if(!pickerItemView) {
        pickerItemView = [self itemView];
    }
    
    bindingData.viewIndexPath = indexPath;
    
    [pickerItemView bindViewFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData atIndexPath:indexPath];
    
    CGRect pickerItemViewframe = pickerItemView.frame;
    pickerItemViewframe.size.height = [self pickerView:pickerItemView rowHeightForComponent:component];
    pickerItemViewframe.size.width = pickerView.frame.size.width;
    pickerItemView.frame = pickerItemViewframe;
    
    return pickerItemView;
}

-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
}


-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return [((MFBindingViewDescriptor *)self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR]).viewHeight floatValue];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(self.filteredViewModels.count == 0) {
        return;
    }
}


-(void) updateStaticView {
    MFBindingViewDescriptor *bindingData = ((MFBindingViewDescriptor *)self.bindingDelegate.structure[SELECTEDITEM_PICKERLIST_DESCRIPTOR]);
    for(MFBindingValue *bindingValue in [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]]) {
        [self.bindingDelegate.binding dispatchValue:[[self getSelectedViewModel] valueForKey:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName fromSource:bindingValue.bindingSource];
    }
}

/**
 * @brief Creates and returns the view of an item of the pickerView
 * @return The itemView of the picker
 */
-(MFBindingViewAbstract *)itemView {
    MFBindingViewAbstract *returnView = nil;
    NSString *xibName = ((MFBindingViewDescriptor *)self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR]).viewIdentifier;
    if(xibName) {
        returnView = [[[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil] firstObject];
    }
    else {
        [MFException throwExceptionWithName:@"No View Identifier" andReason:@"You must define a ViewIdentifier for the item PickerList view" andUserInfo:nil];
    }
    return returnView;
}

#pragma mark - ViewModels management

-(void) selectViewModel:(NSInteger)row {
    MFUIBaseViewModel *itemViewModel = [self.filteredViewModels objectAtIndex:row];
    [self setSelectedViewModel:itemViewModel];
}


-(id<MFUIBaseViewModelProtocol>) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    id<MFUIBaseViewModelProtocol> vmItem = nil;
    MFUIBaseListViewModel *listVm = ((MFUIBaseListViewModel *)[self.picker getValues]);
    
    
    if ( [listVm.viewModels count]>indexPath.row) {
        vmItem = [listVm.viewModels objectAtIndex:indexPath.row];
        if ( [[NSNull null] isEqual: vmItem]) {
            vmItem = nil ;
        }
    }
    if (vmItem == nil ) {
        
        id vmCreator = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_VIEW_MODEL_CREATOR];
        if([[listVm.fetch.sections objectAtIndex:0] objects].count > indexPath.row) {
            id temp = [listVm.fetch objectAtIndexPath:indexPath];
            
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
            id tempVM =[vmCreator performSelector:@selector(createOrUpdateItemVM:withData:) withObject:[listVm defineViewModelName] withObject: temp];
#pragma clang diagnostic pop
            
            [listVm add:tempVM atIndex:indexPath.row];
            vmItem = tempVM ; //[listVm.viewModels objectAtIndex:indexPath.row];
        }
    }
    return vmItem;
}

/**
 * @brief Initialize the dictionary of filtered view Models with all view models
 * @return A dictionary containing the list of view models
 */
-(NSMutableArray *) initializeFilteredViewModels {
    NSMutableArray *array = nil;
    array = [self pickerListViewModel].viewModels;
    return array;
}


-(id<MFUIBaseViewModelProtocol>)getViewModel {
    id object = [self.picker getData];
    return object;
}

-(MFUIBaseListViewModel *) pickerListViewModel {
    return (MFUIBaseListViewModel *)[self.picker getValues];
}

-(MFUIBaseViewModel *) getSelectedViewModel {
    return [self.picker getData];
}


-(void) setSelectedViewModel:(MFUIBaseViewModel *)viewModel {
    [self.picker setData:viewModel];
}

#pragma mark - MFSearchDelegate

/**
 * @see MFSearchDelegate
 */
-(BOOL)filterViewModel:(MFUIBaseViewModel *)viewModel withCurrentSearch:(NSString *)searchText {
    @throw([NSException exceptionWithName:@"Unimplemented Method" reason:[NSString stringWithFormat:@"The method named \"filterViewModel:withCurrentSearch:\" should be implemented in %@", [self class]] userInfo:nil]);
}



/**
 * @see MFSearchDelegate
 */
-(void)updateFilterWithText:(NSString *)searchText {
    if([searchText length] == 0) {
        self.filteredViewModels = [self initializeFilteredViewModels];
    }
    else {
        NSMutableArray *tempoArray = [NSMutableArray array];
        int index = 0;
        for(MFUIBaseViewModel *viewModel in [self pickerListViewModel].viewModels) {
            if([self filterViewModel:viewModel withCurrentSearch:searchText]) {
                [tempoArray addObject:viewModel];
            }
            index++;
        }
        if(tempoArray.count == 0 ) {
            Class itemViewModelClass = [[self getSelectedViewModel] class];
            id emptyObject = [[itemViewModelClass alloc] init];
            if(emptyObject) {
                [tempoArray addObject:emptyObject];
            }
        }
        self.filteredViewModels = tempoArray;
    }
    
    [self.picker.pickerView reloadComponent:0];
    if(searchText.length > 0 ) {
        [self.picker.pickerView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:self.picker.pickerView didSelectRow:0 inComponent:0];
    }
}


#pragma mark - Binding

-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
}
-(void) initializeModel {
    self.viewModel.objectWithBinding = self;
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
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"MDK_ComponentSize_%@", [selfBindingValue.bindingIndexPath stringIndexPath]] object:@(itemHeight)];
            }
        }
        self.computeAlreadyDone = YES;
    }
}

@end

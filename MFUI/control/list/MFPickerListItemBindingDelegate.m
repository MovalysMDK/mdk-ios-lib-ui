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

#import "MFPickerListItemBindingDelegate.h"
#import "MFPickerList.h"
#import "MFCommonFormProtocol.h"
#import "MFUIBaseListViewModel.h"
#import "MFObjectWithBindingProtocol.h"
#import "MFAbstractComponentWrapper.h"
#import "MFPickerListConfiguration.h"

@interface MFPickerListItemBindingDelegate ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic) BOOL hasComputeContentSize;
@end

@implementation MFPickerListItemBindingDelegate
@synthesize bindingDelegate = _bindingDelegate;


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
    self.hasComputeContentSize = NO;
     MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    UINib *cellNib = [UINib nibWithNibName:bindingData.cellIdentifier bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:bindingData.cellIdentifier];
}

-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
}

-(void) initializeModel {
    self.viewModel.objectWithBinding = self;
}


#pragma mark - TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger value = 0 ;
    MFUIBaseListViewModel *lvm = ((MFUIBaseListViewModel *)[self getViewModel]);
    NSFetchedResultsController *fetch =lvm.fetch;
    if ( fetch != nil ) {
        // mode curseur (le view model est construit au fur et à mesure)
        id <NSFetchedResultsSectionInfo> sectionInfo = [fetch.sections objectAtIndex:section];
        value  = sectionInfo ? [sectionInfo numberOfObjects]  : 0;
    }
    else {
        // mode direct (le view model est complet tout de suite)
        value = (lvm.viewModels == nil)?0:lvm.viewModels.count;
    }
    
    if(!self.hasComputeContentSize) {
        MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
        [self.tableView registerNib:[UINib nibWithNibName:bindingData.cellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:bindingData.cellIdentifier];
        int contentSize = value * ([bindingData.cellHeight intValue]);
        NSLayoutConstraint *realHeight = [NSLayoutConstraint constraintWithItem:self.picker.pickerListTableView.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentSize];
        realHeight.priority = UILayoutPriorityDefaultHigh;
        [self.picker.parentNavigationController.view addConstraint:realHeight];
    }
    return value;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:tableView options:nil] firstObject];
    }
    bindingData.cellIndexPath = indexPath;
    [cell bindCellFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData atIndexPath:indexPath];
    
    if([[self viewModelAtIndexPath:indexPath] isEqual:[self.picker getData]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    bindingData.cellIndexPath = indexPath;
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingData generatedBindingKey]];
}



-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    return [bindingData.cellHeight floatValue];
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.picker.pickerListTableView dismiss];
    [self.picker setData:[self viewModelAtIndexPath:indexPath]];
    [self.picker performSelector:@selector(valueChanged:) withObject:self.picker];
}



#pragma mark - ViewModels management

-(NSObject<MFUIBaseViewModelProtocol> *) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<MFUIBaseViewModelProtocol> *vmItem = nil;
    MFUIBaseListViewModel *listVm = ((MFUIBaseListViewModel *)[self getViewModel]);
    
    
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

-(MFUIBaseListViewModel *)getViewModel {
    id object = [self.picker getValues];
    return object;
}

@end

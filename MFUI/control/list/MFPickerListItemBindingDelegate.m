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
#import "MFCommonFormProtocol.h"
#import "MFUIBaseListViewModel.h"
#import "MFObjectWithBindingProtocol.h"
#import "MFAbstractControlWrapper.h"
#import "MFPickerListConfiguration.h"
#import "MFFormViewController.h"
#import "MFDetailViewControllerProtocol.h"


@interface MFPickerListItemBindingDelegate ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *filteredViewModels;

@property (nonatomic) BOOL hasComputeContentSize;
@end

NSString *tableViewHeightConstraintIdentifier = @"realHeightConstraintIdentifier";

@implementation MFPickerListItemBindingDelegate
@synthesize bindingDelegate = _bindingDelegate;
@synthesize formValidation = _formValidation;
@synthesize viewModel = _viewModel;

- (instancetype)initWithPickerList:(MDKUIPickerList *)pickerList
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
    NSInteger value = self.filteredViewModels.count ;
    
    if(!self.hasComputeContentSize) {
        MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
        [self.tableView registerNib:[UINib nibWithNibName:bindingData.cellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:bindingData.cellIdentifier];
        NSInteger contentSize = value * ([bindingData.cellHeight integerValue]);
        if(self.hasSearch) {
            contentSize += 44;
        }
        
        NSLayoutConstraint *constraintToUpdate = nil;
        for(NSLayoutConstraint *constraint in self.picker.parentNavigationController.view.constraints) {
            if([constraint.identifier isEqualToString:tableViewHeightConstraintIdentifier]) {
                constraintToUpdate = constraint;
                break;
            }
        }
        if(!constraintToUpdate) {
            NSLayoutConstraint *realHeight = [NSLayoutConstraint constraintWithItem:self.picker.uiList.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:contentSize];
            realHeight.priority = UILayoutPriorityDefaultHigh;
            realHeight.identifier = tableViewHeightConstraintIdentifier;
            [self.picker.parentNavigationController.view addConstraint:realHeight];
        }
        else {
            constraintToUpdate.constant = contentSize;
        }
        
        [UIView animateWithDuration:0.15 animations:^{
            [self.picker.parentNavigationController.view layoutIfNeeded];
        }];
    }
    return value;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self xibNameForPickerListCells]];
    if(!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:[self xibNameForPickerListCells] owner:tableView options:nil] firstObject];
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


-(NSString *)xibNameForPickerListCells {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    return identifier;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[LISTITEM_PICKERLIST_DESCRIPTOR];
    bindingData.cellIndexPath = indexPath;
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingData generatedBindingKey]];
}


-(BOOL)hasSearch {
    return [self.picker.controlAttributes[PICKER_PARAMETER_SEARCH_KEY] boolValue];
}

-(void) willDisplayPickerListView {
    self.filteredViewModels = [self getContent];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.picker.uiList dismiss];
    [self.picker setControlData:[self viewModelAtIndexPath:indexPath]];
    [self.picker valueChanged:self.picker.button];
}



#pragma mark - ViewModels management

-(NSObject<MFUIBaseViewModelProtocol> *) viewModelAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<MFUIBaseViewModelProtocol> *vmItem = nil;
    NSArray *items = self.filteredViewModels;
    
    
    if ( [items count]>indexPath.row) {
        vmItem = [items objectAtIndex:indexPath.row];
        if ( [[NSNull null] isEqual: vmItem]) {
            vmItem = nil ;
        }
    }
    
    return vmItem;
}

-(id)getContent {
    MFUIBaseListViewModel *values = nil;
    if(self.picker.controlAttributes[PICKER_PARAMETER_VALUES_KEY]) {
        MFUIBaseViewModel *formViewModel = (MFUIBaseViewModel *)[((MFFormViewController *)self.picker.parentViewController) getViewModel];
        
        BOOL hasParentFormController = NO;
        if([self.picker.parentViewController conformsToProtocol:@protocol(MFDetailViewControllerProtocol)] && [self.picker.parentViewController respondsToSelector:@selector(parentFormController)]) {
            hasParentFormController = YES;
            formViewModel = (MFUIBaseViewModel *)[((MFFormBaseViewController *)[((id<MFDetailViewControllerProtocol>)self.picker.parentViewController) parentFormController]) getViewModel];
        }
        
        
        //SI le controller répond à partialViewModelKeys, on est dans le cas d'un controller conteneur
        // et on prend du coup le ViewModel associé à l'une des clés qui nous est donnée,
        //SINON on remontre dans les parentViewModel jusqu'à trouver le ListViewModel recherché.
        MFFormViewController *formViewController = self.picker.parentViewController;
        if(hasParentFormController) {
            formViewController = [((id<MFDetailViewControllerProtocol>)self.picker.parentViewController) parentFormController];
        }
        if([formViewController respondsToSelector:@selector(partialViewModelKeys)]
           && [(NSArray *)[formViewController performSelector:@selector(partialViewModelKeys)] count] > 0 ) {
            MFFormViewController *controller = (MFFormViewController *)formViewController;
            for(NSString *key in [controller partialViewModelKeys]) {
                if([formViewModel respondsToSelector:NSSelectorFromString(key)]) {
                    id tempViewModel = [formViewModel valueForKey:key];
                    id object = [tempViewModel valueForKeyPath:self.picker.controlAttributes[PICKER_PARAMETER_VALUES_KEY]];
                    if(object && [object isKindOfClass:[MFUIBaseListViewModel class]]) {
                        values = (MFUIBaseListViewModel *) object;
                        break;
                    }
                    
                }
            }
        }
        else {
            values = [formViewModel valueForKeyPath:self.picker.controlAttributes[PICKER_PARAMETER_VALUES_KEY]];
            while(formViewModel && ![formViewModel respondsToSelector:NSSelectorFromString(self.picker.controlAttributes[PICKER_PARAMETER_VALUES_KEY])]) {
                formViewModel = (MFUIBaseViewModel *)formViewModel.parentViewModel;
            }
        }
        
    }
    return values.viewModels;
}


#pragma mark - Search Bar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self checkFilter];
    if(searchText && searchText.length > 0) {
        self.filteredViewModels = [self.filter filterItems:[self getContent] withString:searchText];
        if(!self.filteredViewModels) {
            self.filteredViewModels = @[];
        }
    }else {
        self.filteredViewModels = [self getContent];
    }    self.hasComputeContentSize = NO;
    
    self.hasComputeContentSize = NO;
    [self.list.tableView reloadData];
}

-(void) checkFilter {
    if(!self.filter) {
        self.filter = [MDKPickerListDefaultFilter new];
    }
}

-(void)dealloc {
    self.bindingDelegate = nil;
}

@end

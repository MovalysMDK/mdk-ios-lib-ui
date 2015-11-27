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


//Interface import
#import "MDKFixedListDataDelegate.h"

//MFCore imports
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreI18n.h>

//UI
#import <MBProgressHUD/MBProgressHUD.h>


//FixedList import
#import "MFFormDetailViewController.h"
#import "MFPhotoDetailViewController.h"

//MFCell import
#import "MFCellAbstract.h"

//Utils
#import "MFHelperIndexPath.h"
#import "MFTypeValueProcessingProtocol.h"
#import "MFUILog.h"

//Binding
#import "MFUIBaseListViewModel.h"

//Forms
#import "MFFormWithDetailViewControllerProtocol.h"
#import "MFFormBaseViewController.h"


#import "MFAbstractControlWrapper.h"
#import "MFObjectWithBindingProtocol.h"

//FIXME : A supprimer ?
const static int TABLEVIEW_SEPARATOR_HEIGHT = 1;


@interface MDKFixedListDataDelegate ()



/**
 * @brief The view that is shown during loading
 */
@property (nonatomic, strong) MBProgressHUD *HUD;


@end

@implementation MDKFixedListDataDelegate
@synthesize viewModel = _viewModel;
@synthesize formValidation = _formValidation;
@synthesize bindingDelegate = _bindingDelegate;



#pragma mark - Initialization
-(instancetype)initWithFixedList:(MDKUIFixedList *) fixedList {
    self = [super init];
    if(self) {
        self.fixedList = fixedList;
        [self initialize];
        
    }
    return self;
}

-(void) initialize {
    self.formValidation = [[MFFormValidationDelegate alloc] initWithFormController:self];
    [self initializeBinding];
}




#pragma  mark - Fixed List Base Data Delegate implementation
-(void)fixedList:(MDKUIFixedList *)fixedList mapCell:(UITableViewCell *)cell withObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    
    
    bindingData.cellIndexPath = indexPath;
    [cell bindCellFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData atIndexPath:indexPath];
    
    if([cell isKindOfClass:[MFCellAbstract class]]) {
        [(MFCellAbstract *)cell cellIsConfigured];
    }
    [self.fixedList validate];
}


-(void)fixedList:(MDKUIFixedList *)fixedList addItemFromSender:(id)sender {
    
    //Get de detail controller
    MFFormDetailViewController *detailController = [self instantiateDetailViewControllerForEditionType:MFFormDetailEditionTypeAdd];
    [detailController setIndexPath:nil];
    
    //Creating an empty ViewModel copy
    MFUIBaseViewModel *viewModel = [[MFBeanLoader getInstance] getBeanWithKey:[self itemListViewModelName]];
    [viewModel updateFromIdentifiable:nil];
    [detailController setOriginalViewModel:viewModel];

    //Display the controller
    [[self.fixedList parentNavigationController] pushViewController:detailController animated:YES];
}

-(void)fixedList:(MDKUIFixedList *)fixedList didSelectRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    //Get de detail controller
    MFFormDetailViewController *detailController = [self instantiateDetailViewControllerForEditionType:MFFormDetailEditionTypeEdit];
    [detailController setIndexPath:indexPath];
    
    //Creating a ViewModel copy
    MFUIBaseViewModel *tempViewModel = [object copy];
    [detailController setOriginalViewModel:tempViewModel];
    
    //Display the controller
    [[self.fixedList parentNavigationController] pushViewController:detailController animated:YES];
}

-(MFFormDetailViewController *)instantiateDetailViewControllerForEditionType:(MFFormDetailEditionType)editionType {
    //Get de detail controller
    MFFormDetailViewController *detailController = [self detailController];
    [detailController setParentFormController:self.fixedList.parentViewController];
    [detailController setSender:self];
    [detailController setEditionType:MFFormDetailEditionTypeEdit];
    return detailController;
}

-(void)fixedList:(MDKUIFixedList *)fixedList didDeleteRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    [super fixedList:fixedList didDeleteRowAtIndexPath:indexPath withObject:object];
    [fixedList valueChanged:fixedList.tableView];
    [self computeCellHeightAndDispatchToFormController];
}

-(NSArray *)fixedList:(MDKUIFixedList *)fixedList topOffsets:(NSArray *)baseOffsets {
    return baseOffsets;
}

#pragma mark - Binding


-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
    [self.fixedList.tableView reloadData];
}

-(void)setBindingDelegate:(MFBindingDelegate *)bindingDelegate {
    _bindingDelegate = bindingDelegate;
    if(bindingDelegate) {
        [self createBindingStructure];
        MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
        NSString *identifier = bindingData.cellIdentifier;
        UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle mainBundle]];
        if([identifier isEqualToString:@"PhotoFixedListItemCell"]) {
            nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[MFCellAbstract class]]];
        }
        [self.fixedList.tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
}

-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData atIndexPath:(NSIndexPath *)indexPath{
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        bindingValue.wrapper.wrapperIndexPath = indexPath;
        [self.bindingDelegate.binding dispatchValue:[[self viewModelAtIndexPath:indexPath] valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName atIndexPath:indexPath fromSource:bindingValue.bindingSource];
    }
    
}


-(void)createBindingStructure {
    MFTableConfiguration *tableConfiguration = [MFTableConfiguration createTableConfigurationForObjectWithBinding:self];
    MFBindingCellDescriptor *photoCellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:@"PhotoFixedListItemCell" withCellHeight:@(123) withCellBindingFormat:@"outlet.photoValue.binding : vm.photo<->c.data", nil];
    [tableConfiguration createFixedListTableCellWithDescriptor:photoCellDescriptor];
}

#pragma mark - FixedList Events

-(void) updateChangesFromDetailControllerOnCellAtIndexPath:(NSIndexPath *)indexPath withViewModel:(MFUIBaseViewModel *)viewModel editionType:(MFFormDetailEditionType)editionType {
    NSMutableArray * tempViewModels = [[self.fixedList getData] mutableCopy] ;
    MFUIBaseViewModel *oldViewModel = [tempViewModels objectAtIndex:indexPath.row];

    switch (editionType) {
        case MFFormDetailEditionTypeEdit:
            viewModel.parentViewModel = oldViewModel.parentViewModel;
            [tempViewModels replaceObjectAtIndex:indexPath.row withObject:viewModel];
            break;
        case MFFormDetailEditionTypeAdd:
            [tempViewModels addObject:viewModel];
            break;
        default:
            break;
    }
    [self.fixedList setControlData:tempViewModels];
    [self.fixedList valueChanged:self.fixedList.tableView];
    [self.fixedList setDisplayComponentValue:[self.fixedList getData]];
    
    
}

#pragma mark - View Models management
-(NSString *)itemListViewModelName {
    [MFException throwNotImplementedExceptionOfMethodName:@"itemListViewModelName" inClass:[self class] andUserInfo:nil];
    return @"";
}


-(MFUIBaseViewModel *)viewModelAtIndexPath:(NSIndexPath *)indexPath {
    return ((NSArray *)[self.fixedList getData])[indexPath.row];
}


#pragma mark - FixedList Utils

-(MFFormDetailViewController *)detailController {
    MFCoreLogError(@"MDKFixedListDataDelegate : %@",[MFException getNotImplementedExceptionOfMethodName:@"detailController" inClass:self.class andUserInfo:nil]);
    return nil;
}

-(void) computeCellHeightAndDispatchToFormController {
    
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    float itemHeight = [bindingData.cellHeight floatValue];
    
    UIViewController *parent = self.fixedList.parentViewController;
    if(parent && [parent conformsToProtocol:@protocol(MFObjectWithBindingProtocol)]) {
        id<MFObjectWithBindingProtocol> parentObjectWithBinding = (id<MFObjectWithBindingProtocol>)parent;
        MFBindingValue *selfBindingValue = parentObjectWithBinding.bindingDelegate.binding.bindingByComponents[@(self.fixedList.hash)];
        if(selfBindingValue && [self.fixedList getData]) {
            NSInteger numberOfItems = ((NSArray *)[self.fixedList getData]).count;
            float height = numberOfItems * itemHeight ;
            height += MAX((numberOfItems - 1), 0) * TABLEVIEW_SEPARATOR_HEIGHT;
            for(NSNumber *offet in [self fixedList:self.fixedList topOffsets:@[@(self.fixedList.addButton.frame.size.height)]]) {
                height += [offet floatValue];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"MDK_ComponentSize_%@_%@", parentObjectWithBinding, [selfBindingValue.bindingIndexPath stringIndexPath]] object:@{@"height":@(height), @"mustReload":@(YES)}];
        }
    }
}

-(NSString *)xibNameForFixedListCells {
    MFBindingCellDescriptor *bindingData = self.bindingDelegate.structure[CELL_FIXEDLIST_DESCRIPTOR];
    NSString *identifier = bindingData.cellIdentifier;
    
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle mainBundle]];
    [self.fixedList.tableView registerNib:nib forCellReuseIdentifier:identifier];
    
    return identifier;
}






@end

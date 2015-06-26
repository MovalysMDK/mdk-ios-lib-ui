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
#import <MFCore/MFCoreConfig.h>
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



int static UNIQUE_PICKER_LIST_SECTION_INDEX = 0;


@interface MFPickerControllerDelegate()

/**
 * @brief The NIB name corresponding to the item view int the pickerList
 */
@property (nonatomic, strong) NSString *itemViewNibName;

/**
 * @brief The NIB name corresponding to the static view in this cell
 */
@property (nonatomic, strong) NSString *staticViewNibName;

/**
 * @brief Indicates if this component should set the cell height to its form container
 */
@property (nonatomic) BOOL shouldSetCellHeight;

/**
 * @brief Indicates if this component should set the cell height to its form container
 */
@property (nonatomic, strong) MFConfigurationHandler *registry;

@end


@implementation MFPickerControllerDelegate

@synthesize viewModel =_viewModel;
@synthesize formValidation =_formValidation;


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
    self.registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    self.filteredViewModels = [self initializeFilteredViewModels];
    self.shouldSetCellHeight = YES;
}

-(void)setContent {
    
    //Récupération des données
    self.viewModel = [self.picker getData];
    
    self.viewModel.form = self;
    
    
    
    //    [self.pickerList.staticView registerComponent:self];
    
    //Calcul de la taille de la cellule en fonction de la taille de la vue statique
    if(self.shouldSetCellHeight == YES) {
        if([((MFCellAbstract *)self.picker.cellContainer).formController respondsToSelector:@selector(setCellHeight:atIndexPath:)]) {
            int finalHeight = self.picker.frame.origin.y + self.picker.frame.size.height + 20;
            [((MFCellAbstract *)self.picker.cellContainer).formController setCellHeight:finalHeight atIndexPath:self.picker.cellContainer.cellIndexPath];
            self.shouldSetCellHeight = NO;
        }
    }
    
    // Remplissage de la vue statique au premier affichage (par défaut récupération du premier item
    MFUIBaseViewModel *currentViewModel = [self getSelectedViewModel];
    if(!currentViewModel && ([self pickerListViewModel].viewModels.count > 0)) {
        currentViewModel = [[self pickerListViewModel].viewModels objectAtIndex:0];
    }
    if(currentViewModel) {
        [self fillSelectedViewWithViewModel:currentViewModel];
    }
    
    self.filteredViewModels = [self initializeFilteredViewModels];
    [self.picker.staticView viewIsConfigured];
}



-(void)dealloc {
    if(self.picker) {
        self.picker.cellContainer = nil;
        self.picker.pickerView.dataSource = nil;
        self.picker.pickerView.delegate = nil;
    }
}




#pragma mark - UIPickerView DataSource & Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSIndexPath *virtualIndexPath = [NSIndexPath indexPathForItem:row inSection:component];
    
    
    //PROTODO : Mécanisme binding ici
    MFBindingViewAbstract *pickerItemView = (MFBindingViewAbstract *)view;
    
    //Création de la vue
    if(pickerItemView == nil) {
        pickerItemView = [self itemView];
    }
    CGRect itemFrame = pickerItemView.frame;
    itemFrame.size.height = [self pickerView:pickerView rowHeightForComponent:component];
    itemFrame.size.width = pickerView.frame.size.width;
    pickerItemView.frame = itemFrame;
    
    
    [pickerItemView viewIsConfigured];
    return pickerItemView;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filteredViewModels.count;
}

//PROTODO : Nimber of section

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(self.filteredViewModels.count == 0) {
        return;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(void) selectViewModel:(NSInteger)row {
    MFUIBaseViewModel *itemViewModel = [self.filteredViewModels objectAtIndex:row];
    [self setSelectedViewModel:itemViewModel];
    [self fillSelectedViewWithViewModel:[self.filteredViewModels objectAtIndex:row]];
}


/**
 * @brief Creates and returns the view of an item of the pickerView
 * @return The itemView of the picker
 */
-(MFBindingViewAbstract *)itemView {
    MFBindingViewAbstract *returnView = nil;
    if(self.itemViewNibName) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:self.itemViewNibName owner:nil options:nil];
        if(topLevelObjects && topLevelObjects.count > 0) {
            returnView = [topLevelObjects objectAtIndex:0];
        }
        topLevelObjects = nil;
    }
    return returnView;
}

#pragma mark - ViewModels management

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

/**
 * @brief Initialize the dictionary of filtered view Models with all view models
 * @return A dictionary containing the list of view models
 */
-(NSMutableArray *) initializeFilteredViewModels {
    NSMutableArray *array = nil;
    array = [self pickerListViewModel].viewModels;
    return array;
}

/**
 * @brief Fill the staticView with the data of a viewModel
 * @param viewModel A View Model (should be the current selected ViewModel of the ListViewModel)
 */
-(void) fillSelectedViewWithViewModel:(MFUIBaseViewModel *)viewModel {
    
    if([viewModel isKindOfClass:NSClassFromString(@"MFEmptyViewModel")]) {
        MFBindingViewAbstract *emptyView = nil;
        if(self.picker.emptyViewNibName) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:self.picker.emptyViewNibName owner:self options:nil];
            if(topLevelObjects && topLevelObjects.count >0) {
                emptyView = [topLevelObjects objectAtIndex:0];
            }
            self.picker.emptyStaticView = emptyView;
        }
        self.picker.staticView = self.picker.emptyStaticView ? self.picker.emptyStaticView : [[MFBindingViewAbstract alloc] init];
        [self.picker setNeedsDisplay];
    }
}




#pragma mark - Manage data
-(void) setSelectedViewModel:(MFUIBaseViewModel *)viewModel {
    [self.picker setData:viewModel];
}


-(id<MFUIBaseViewModelProtocol>)getViewModel {
    id object = [self.picker getData];
    return object;
}

-(MFUIBaseViewModel *) getSelectedViewModel {
    MFUIBaseViewModel *selectedViewModel = [self.picker getData];
    return selectedViewModel;
}

-(MFUIBaseListViewModel *) pickerListViewModel {
    return (MFUIBaseListViewModel *)[self.picker getValues];
}

@end

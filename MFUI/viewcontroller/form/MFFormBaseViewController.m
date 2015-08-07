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


// iOS imports
#import <QuartzCore/QuartzCore.h>

// MFCore imports
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreDataloader.h>

// Interface
#import "MFFormBaseViewController.h"

// Logging
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"



// ViewModel
#import "MFUIBaseListViewModel.h"
#import "MFUIBaseViewModelProtocol.h"
#import "MFPickerList.h"
#import "MFCell1ComponentHorizontal.h"

//Application
#import "MFUIApplication.h"

// ViewController
#import "MFWorkspaceColumnProtocol.h"
#import "MFWorkspaceViewController.h"
#import "MFForm3DListViewController.h"


//Converter
#import "MFConverterProtocol.h"

//Forms


#pragma mark - MFFormBaseViewController : private interface

@interface MFFormBaseViewController ()

/**
 * @brief The application context used to create beans
 */
@property (nonatomic, strong) MFApplication *applicationContext;

/**
 * @brief A boolean that indicates if a picker is actually shown.
 */
@property (nonatomic) BOOL isPickerDisplayed;

@property (nonatomic, strong) NSMutableDictionary *cellSizes;

@end



#pragma mark - Constructeurs et initialisation

@implementation MFFormBaseViewController
@synthesize viewModel = _viewModel;
@synthesize formValidation = _formValidation;
@synthesize searchDelegate =_searchDelegate;
@synthesize bindingDelegate = _bindingDelegate;

#pragma mark - Initialization
-(id) init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

-(void)initialize {
    //Initialisation des principaux composant du controller.
    
    self.applicationContext = [MFApplication getInstance];
    
    self.cellSizes = [NSMutableDictionary dictionary];
    self.viewModel = [self createViewModel];
    self.viewModel.form = self;
    
    
    self.isPickerDisplayed = NO;
    self.needDoFillAction = YES;
    self.onDestroy = NO;
    
    
}


#pragma mark - Controller lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self initializeBinding];
    [self initializeModel];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(displayBackButton:)
                   name:PICKER_NOTIFICATION_SHOW object:nil];
    [center addObserver:self selector:@selector(displayBackButton:)
                   name:PICKER_NOTIFICATION_HIDE object:nil];
    
    //    [self.navigationController.view setTag:NSIntegerMax];
    self.tableView.tag = FORM_BASE_TABLEVIEW_TAG;
    self.view.tag = FORM_BASE_VIEW_TAG;
    
    if ([self hasSearchForm]) {
        self.searchDelegate = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_FORM_SEARCH_DELEGATE];
        self.searchDelegate.baseController = self;
        
        //PROTODO : Refaire la recherche.
        //        self.searchDelegate.isSimpleSearch = self.mf.search.simpleSearch;
        //        self.searchDelegate.isLiveSearch = self.mf.search.liveSearch;
        //        self.searchDelegate.displayNumberOfResults = self.mf.search.displayNumberOfResults;
    }
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.needDoFillAction) {
        [self doFillAction];
        self.needDoFillAction = NO;
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MFActionLauncher getInstance] MF_register:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // On vérifie que le controller n'est plus dans la liste des viewcontrollers, s'il est dans un conteneur, on vérifie si le conteneur est dans la liste
    // Attention : très impactant, à ne modifier qu'en cas d'extrême nécessité
    if(![self isInWorkspace]) {
        [[MFActionLauncher getInstance] MF_unregister:self];
    }
    
    
    if (([self.class conformsToProtocol:@protocol(MFChildViewControllerProtocol)] ?
         ([self.navigationController.viewControllers indexOfObject:((id<MFChildViewControllerProtocol>) self).containerViewController] == NSNotFound) :
         ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound))) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        ((id<MFUIBaseViewModelProtocol>)self.viewModel).form = nil;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.bindingDelegate = nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    if([self isInWorkspace]) {
        [[MFActionLauncher getInstance] MF_unregister:self];
    }
    [super viewDidDisappear:animated];
}

#pragma mark - Table view delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionIdentifier = self.bindingDelegate.structure[SECTION_ORDER_KEY][indexPath.section];
    MFBindingCellDescriptor *bindingData = ((NSArray *)self.bindingDelegate.structure[sectionIdentifier])[indexPath.row];
    NSString *identifier = bindingData.cellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    //    if(!cell) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    //    }
    bindingData.cellIndexPath = indexPath;
    [cell bindCellFromDescriptor:bindingData onObjectWithBinding:self];
    [self updateCellFromBindingData:bindingData];
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return ((NSArray *)self.bindingDelegate.structure[SECTION_ORDER_KEY]).count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionIdentifier = self.bindingDelegate.structure[SECTION_ORDER_KEY][section];
    return ((NSArray *)self.bindingDelegate.structure[sectionIdentifier]).count;
}

-(void) updateCellFromBindingData:(MFBindingCellDescriptor *)bindingData {
    NSArray *bindingValues = [self.bindingDelegate bindingValuesForCellBindingKey:[bindingData generatedBindingKey]];
    for(MFBindingValue *bindingValue in bindingValues) {
        [self.bindingDelegate.binding dispatchValue:[self.viewModel valueForKeyPath:bindingValue.abstractBindedPropertyName] fromPropertyName:bindingValue.abstractBindedPropertyName fromSource:bindingValue.bindingSource];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = self.bindingDelegate.structure[SECTION_ORDER_KEY][indexPath.section];
    MFBindingCellDescriptor *bindingData = ((NSArray *)self.bindingDelegate.structure[sectionIdentifier])[indexPath.row];
    [self.bindingDelegate.binding clearBindingValuesForBindingKey:[bindingData generatedBindingKey]];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.bindingDelegate.structure[SECTION_ORDER_KEY][section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionIdentifier = self.bindingDelegate.structure[SECTION_ORDER_KEY][indexPath.section];
    MFBindingCellDescriptor *bindingData = ((NSArray *)self.bindingDelegate.structure[sectionIdentifier])[indexPath.row];
    CGFloat height = [bindingData.cellHeight floatValue];
    
    return height;
}



#pragma mark - Observers selectors

-(void)displayBackButton:(NSNotification *)notification  {
    self.navigationItem.leftBarButtonItem.enabled = !self.navigationItem.leftBarButtonItem.enabled;
    self.isPickerDisplayed = !self.navigationItem.hidesBackButton;
}


- (void)reloadDataWithAnimationFromRight:(BOOL)fromRight
{
    [self.tableView reloadData];
}


#pragma mark - Search
-(BOOL)hasSearchForm {
    return NO;
}

-(MFFormSearchViewController *)searchViewController {
    [MFException throwNotImplementedExceptionOfMethodName:@"searchViewController" inClass:self.class andUserInfo:nil];
    return nil;
}

-(void)simpleSearchActionWithText:(NSString *)text {
    [MFException throwNotImplementedExceptionOfMethodName:@"simpleSearchActionWithText:(NSString *)text" inClass:self.class andUserInfo:nil];
}

-(NSString *)dataLoaderName {
    [MFException throwNotImplementedExceptionOfMethodName:@"dataLoaderName" inClass:self.class andUserInfo:nil];
    return nil;
}



#pragma mark - Protocols

-(id<MFUIBaseViewModelProtocol>)createViewModel {
    [MFException throwNotImplementedExceptionOfMethodName:@"createViewModel" inClass:self.class andUserInfo:nil];
    return nil;
}

-(void)doFillAction {
    //Do some base treatments here
}

- (void)showViewController:(UIViewController *)viewControllerToPresent
                  animated: (BOOL)flag
                completion:(void (^)(void))completion;
{
    
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

-(BOOL)isInWorkspace {
    return [self conformsToProtocol:@protocol(MFWorkspaceColumnProtocol)];
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

-(void) initializeBinding {
    self.bindingDelegate = [[MFBindingDelegate alloc] initWithObject:self];
    [self.tableView reloadData];
}
-(void) initializeModel {
    self.viewModel.objectWithBinding = self;
}

-(void) cellSizeChanges:(NSNotification *)notification {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathFromString:[[notification.name componentsSeparatedByString:@"_"] lastObject]];
    if(cellIndexPath) {
        NSString *sectionIdentifier = self.bindingDelegate.structure[SECTION_ORDER_KEY][cellIndexPath.section];
        MFBindingCellDescriptor *cellDescriptor = ((MFBindingCellDescriptor *)((NSArray *)self.bindingDelegate.structure[sectionIdentifier])[cellIndexPath.row]);
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:cellIndexPath];
        float height = cell.frame.size.height;
        if([cell isKindOfClass:[MFCellAbstract class]]) {
            UIView *componentView = [cell valueForKey:@"componentView"];
            height -= componentView.frame.size.height;
            height += [notification.object floatValue];
            
        }
        cellDescriptor.cellHeight = @(height);
        
        //        cellDescriptor.cellHeight = notification.object;
        [self.tableView reloadData];
    }
}


@end

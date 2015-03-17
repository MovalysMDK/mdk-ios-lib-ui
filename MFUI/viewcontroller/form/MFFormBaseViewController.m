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
//  MFFormBaseViewController.m
//  MFUI
//
//

// iOS imports
#import <QuartzCore/QuartzCore.h>

// MFCore imports
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreFormDescriptor.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreAction.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreDataloader.h>
#import <MFCore/MFCoreFormConfig.h>

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

// Components and cells
#import "MFUIBaseComponent.h"

//Application
#import "MFUIApplication.h"

// ViewController
#import "MFWorkspaceColumnProtocol.h"
#import "MFWorkspaceViewController.h"
#import "MFForm3DListViewController.h"

//Binding
#import "MFBaseBindingForm.h"

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


@end



#pragma mark - Constructeurs et initialisation

@implementation MFFormBaseViewController

@synthesize  viewModel = _viewModel;
@synthesize formDescriptor =_formDescriptor;
@synthesize formValidation = _formValidation;
@synthesize searchDelegate =_searchDelegate;
@synthesize mf = _mf;

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
    
    self.formBindingDelegate = [[MFBaseBindingForm alloc] initWithParent:self];
    
    self.applicationContext = [MFApplication getInstance];
    self.reusableBindingViews = [NSMutableArray array];
    
    
    self.viewModel = [self createViewModel];
    self.viewModel.form = self;
    
    self.mf = [[MFFormExtend alloc] init];
    
    self.isPickerDisplayed = NO;
    self.needDoFillAction = YES;
    self.onDestroy = NO;
    
}

#pragma mark - Controller lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.mf.formDescriptorName) {
        MFConfigurationHandler *configurationHandlerInstance = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
        [configurationHandlerInstance loadFormWithName:self.mf.formDescriptorName];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(displayBackButton:)
                   name:PICKER_NOTIFICATION_SHOW object:nil];
    [center addObserver:self selector:@selector(displayBackButton:)
                   name:PICKER_NOTIFICATION_HIDE object:nil];
    //    [self.navigationController.view setTag:NSIntegerMax];
    self.tableView.tag = FORM_BASE_TABLEVIEW_TAG;
    self.view.tag = FORM_BASE_VIEW_TAG;
    
    if ([self hasSearchForm]) {
        self.searchDelegate = [self.applicationContext getBeanWithKey:BEAN_KEY_FORM_SEARCH_DELEGATE];
        self.searchDelegate.baseController = self;
        self.searchDelegate.isSimpleSearch = self.mf.search.simpleSearch;
        self.searchDelegate.isLiveSearch = self.mf.search.liveSearch;
        self.searchDelegate.displayNumberOfResults = self.mf.search.displayNumberOfResults;
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
        [self unregisterAllComponents];
        self.formBindingDelegate = nil;
        ((id<MFUIBaseViewModelProtocol>)self.viewModel).form = nil;
    }
    
}




-(void)viewDidDisappear:(BOOL)animated {
    if([self isInWorkspace]) {
        [[MFActionLauncher getInstance] MF_unregister:self];
    }
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Child classes must implement this method
    return 0;
}



#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(![self isKindOfClass:[MFForm2DListViewController class]] && indexPath.section >= self.formDescriptor.sections.count) {
        return nil;
    }
    MFSectionDescriptor *currentSection = nil;
    MFGroupDescriptor *currentGd = nil;
    
    if([self.viewModel isKindOfClass:[MFUIBaseListViewModel class]]) {
        currentSection = self.formDescriptor.sections[0];
        currentGd = nil;
        currentGd = currentSection.orderedGroups[0];
    }
    else {
       currentSection = self.formDescriptor.sections[indexPath.section];
        currentGd = nil;
        currentGd = currentSection.orderedGroups[indexPath.row];
    }

    
//    MFCellAbstract *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%@", [self cellIdentifierAtIndexPath:indexPath withGroupDescriptor:currentGd], ([MFHelperBOOL booleanValue:currentGd.noLabel] ? @"-noLabel" : @"")] forIndexPath:indexPath];
    MFCellAbstract *cell = [self retrieveCellAtIndexPath:indexPath fromCurrentGroupDescriptor:currentGd];
    // We check if it's a framework cell
    if ([cell conformsToProtocol:@protocol(MFFormCellProtocol)]) {
        // Si c'est une cellule que l'on a deja instancié, on désenregistre ses composants précédents, sinon on l'ajoute
        // à notre tableau de cellules déja instanciées.
        id<MFFormCellProtocol> formCell = (id<MFFormCellProtocol>)cell;
        ((MFCellAbstract *)formCell).formController = self;
        ((MFCellAbstract *)formCell).cellIndexPath = indexPath;
        if(![self.reusableBindingViews containsObject:formCell]) {
            [self.reusableBindingViews addObject:formCell];
        }
        else {
            [formCell unregisterComponents:self];
        }
        
        [self.binding unregisterComponentsAtIndexPath:indexPath withBindingKey:nil];
        [formCell setCellIndexPath:indexPath];
        formCell.transitionDelegate = self;

        [formCell configureByGroupDescriptor:currentGd andFormDescriptor:self.formDescriptor];
        
        
        //Enregistrement des composants graphiques du formulaire pour les cellules visibles
        NSDictionary *newRegisteredComponents = [self registerComponentsFromCell:formCell];
        
        for(NSString *key in [newRegisteredComponents allKeys]) {
            //Récupération de la liste des composants associé à ce keyPath
            
            NSMutableArray *componentList = [[self.binding componentsAtIndexPath:indexPath withBindingKey:key] mutableCopy];
            if(componentList) {
                for(id<MFUIComponentProtocol> component in componentList)
                {
                    //Initialisation des composants
                    //                    if(![self isKindOfClass:[MFForm2DListViewController class]] && ![self isKindOfClass:[MFForm3DListViewController class]]) {
                    [self initComponent:component atIndexPath:indexPath];
                    //                    }
                }
            }
        }
    }
    
    if([cell conformsToProtocol:@protocol(MFContentDelegate) ]) {
        [(id<MFContentDelegate>)cell setContent];
    }
    
    [cell cellIsConfigured];
    
    if(![MFHelperBOOL booleanValue:currentGd.visible]) {
        cell.hidden = YES;
    }
    return cell;
}


-(UITableViewCell<MFFormCellProtocol> *) retrieveCellAtIndexPath:(NSIndexPath *)indexPath fromCurrentGroupDescriptor:(MFGroupDescriptor *)currentGd {
    MFCellAbstract * cell = [self.tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%@", [self cellIdentifierAtIndexPath:indexPath withGroupDescriptor:currentGd], ([MFHelperBOOL booleanValue:currentGd.noLabel] ? @"-noLabel" : @"")] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Child classes must implement this method
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    MFSectionDescriptor *sectionDescriptor = self.formDescriptor.sections[section];
    
    if(sectionDescriptor.titled) { return UITableViewAutomaticDimension; } // Si Mm_title est présent, titre de section avec hauteur par défaut
    else                         { return 0.01f;                         } // Sinon titre de section avec taille égale à zéro
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MFSectionDescriptor *sectionDescriptor = self.formDescriptor.sections[section];
    
    if(sectionDescriptor.titled) { return MFLocalizedStringFromKey(sectionDescriptor.name); } // Si Mm_title est présent, titre la section avec le nom du panel
    else                         { return nil;                                              } // Sinon pas de titre
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFGroupDescriptor *group = [self getGroupDescriptor:indexPath];
    BOOL noLabel = [MFHelperBOOL booleanValue:group.noLabel];
    CGFloat value = (noLabel ? [group.heightNoLabel floatValue] : [group.height floatValue]);
    
    if(value == 0 ) {
        value = self.tableView.frame.size.height;
        if(!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            value -= self.navigationController.navigationBar.frame.size.height;
        }
    }
    for (MFFieldDescriptor *componentDescriptor in group.fields) {
        if ([componentDescriptor.uitype isEqualToString:@"MFFixedList"]) {
            //            hasFixedList = YES;
            
            id valueForKeyPath = [self.viewModel valueForKeyPath:componentDescriptor.bindingKey];
            NSUInteger num = 1;
            if ([valueForKeyPath isKindOfClass:[MFUIBaseListViewModel class]]){
                num = [(MFUIBaseListViewModel*)valueForKeyPath viewModels].count;
            } else if (valueForKeyPath == nil) {
                num = 0;
            }
            value = [group.height floatValue] * num + (!noLabel ? ([group.heightNoLabel floatValue] ? [group.height floatValue] - [group.heightNoLabel floatValue] : 62) : 41); // 62 : label + boutons + 2 * marge ; 41 : boutons + 2 * marge
        }
    }
    
    return value;
}



/**
 * @brief Cette méthode permet à des cellules d'indiquer elles-mêmes leur hauteur. Cela permet d'adapter
 * la hauteur d'une cellule à son contenu. C'est par exemple le cas d'es cellules à listes éditales.
 * Après que la cellule ait annoncée sa hauteur, celle-ci est stockée dans un dictionnaire recensant les hauteurs
 * de toutes les cellules de la tableView, et la tableView est rechargée pour affecter directement la hauteur à la cellule
 * @param height La hauteur de la cellule
 * @param indexPath L'indexPath de la cellule qui annonce sa hauteur
 */
-(void) setCellHeight:(float)height atIndexPath:(NSIndexPath *)indexPath {
    //    [self.cellSizes setObject:[NSNumber numberWithFloat:height] forKey:[MFHelperIndexPath toString:indexPath]];
    // Animation du rechargement de la liste
    [UIView transitionWithView: self.tableView
                      duration: 0.20f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }
                    completion: ^(BOOL isFinished)
     {
         //block de code à exécuter ici après l'animation
     }];
    
    //On stocke la hauteur de la cellule avec comme clé, son indexPath
    
}


#pragma mark - Méthode de MFFormBaseViewController

-(MFGroupDescriptor *) getGroupDescriptor:(NSIndexPath *)indexPath {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"Method is not implemented" userInfo:nil]);
}


/**
 * @brief Cette méthode enregistre dans le mapping les composants principaux de
 * la cellule
 * @param cell La cellule dont on souhaite enregisrer les composants
 */
-(NSDictionary *)registerComponentsFromCell:(id<MFFormCellProtocol>) cell {
    return [cell registerComponent:self];
}


#pragma mark - Forwarding getters - MFBindingFormDelegate

-(MFBinding *)binding {
    return self.formBindingDelegate.binding;
}

-(NSDictionary *)filtersFromViewModelToForm {
    return self.formBindingDelegate.filtersFromViewModelToForm;
}

-(NSDictionary *)filtersFromFormToViewModel {
    return self.formBindingDelegate.filtersFromFormToViewModel;
}

-(NSDictionary *)bindableProperties {
    return self.formBindingDelegate.bindableProperties;
}

-(NSMutableDictionary *)propertiesBinding {
    return self.formBindingDelegate.propertiesBinding;
}

-(NSMutableArray *)reusableBindingViews {
    return self.formBindingDelegate.reusableBindingViews;
}


#pragma mark - Forwarding setters - MFBindingFormDelegate

-(void)setBinding:(NSMutableDictionary *)mB {
    [self.formBindingDelegate setBinding:mB];
}

-(void)setFiltersFromFormToViewModel:(NSDictionary *)filters {
    [self.formBindingDelegate setFiltersFromFormToViewModel:filters];
}

-(void)setFiltersFromViewModelToForm:(NSDictionary *)filters {
    [self.formBindingDelegate setFiltersFromViewModelToForm:filters];
}

-(void)setPropertiesBinding:(NSMutableDictionary *)propertiesBinding {
    [self.formBindingDelegate setPropertiesBinding:propertiesBinding];
}

-(void)setBindableProperties:(NSDictionary *)bindableProperties {
    [self.formBindingDelegate setBindableProperties:bindableProperties];
}

-(void) setReusableBindingViews:(NSMutableArray *)reusableBindingViews {
    [self.formBindingDelegate setReusableBindingViews:reusableBindingViews];
}

#pragma mark - Forwarding methods - MFBindingFormDelegate

-(BOOL)mutexForProperty:(NSString *)propertyName {
    return  [self.formBindingDelegate mutexForProperty:propertyName];
}

-(void)releasePropertyFromMutex:(NSString *)propertyName {
    [self.formBindingDelegate releasePropertyFromMutex:propertyName];
}

-(NSString *)bindingKeyWithIndexPathFromKey:(NSString *)key andIndexPath:(NSIndexPath *)indexPath {
    return [self.formBindingDelegate bindingKeyWithIndexPathFromKey:key andIndexPath:indexPath];
}

-(NSString *)bindingKeyFromBindingKeyWithIndexPath:(NSString *)key {
    return [self.formBindingDelegate bindingKeyFromBindingKeyWithIndexPath:key];
}

-(NSIndexPath *)indexPathFromBindingKeyWithIndexPath:(NSString *)key {
    return [self.formBindingDelegate indexPathFromBindingKeyWithIndexPath:key];
}

-(void)unregisterAllComponents {
    [self.formBindingDelegate unregisterAllComponents];
}

-(NSString *)generateSetterFromProperty:(NSString *)propertyName {
    return [self.formBindingDelegate generateSetterFromProperty:propertyName];
}

-(void)initComponent:(id<MFUIComponentProtocol>)component atIndexPath:(NSIndexPath *)indexPath {
    [self.formBindingDelegate initComponent:component atIndexPath:indexPath];
}

-(void)performSelector:(SEL)selector onComponent:(id<MFUIComponentProtocol>)component withObject:(id)object {
    [self.formBindingDelegate performSelector:selector onComponent:component withObject:object];
}

-(id)applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id)value isFormToViewModel:(BOOL)formToViewModel {
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel];
}

-(id) applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel
{
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel withViewModel:viewModel];
}

-(id<MFUIBaseViewModelProtocol>)getViewModel {
    return self.viewModel;
}



#pragma mark - Scrolling methods



-(void)setActiveField:(UIControl *)field {
    ((MFBaseBindingForm *)self.formBindingDelegate).activeField = field;
}



#pragma mark - Observers selectors

-(void)displayBackButton:(NSNotification *)notification  {
    self.navigationItem.leftBarButtonItem.enabled = !self.navigationItem.leftBarButtonItem.enabled;
    self.isPickerDisplayed = !self.navigationItem.hidesBackButton;
}


- (void)reloadDataWithAnimationFromRight:(BOOL)fromRight
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        CATransition *animation = [CATransition animation];
//        [animation setType:kCATransitionPush];
//        if (fromRight) {
//            [animation setSubtype:kCATransitionFromRight];
//        }
//        else {
//            [animation setSubtype:kCATransitionFromLeft];
//        }
//        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [animation setFillMode:kCAFillModeBoth];
//        [animation setDuration:.3];
//        [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
//    });
    
    
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

-(void)dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath {
    //TODO QLA : Tenter de factoriser du code commun ici
}

-(void)dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath valid:(BOOL)valid {
    //TODO QLA : Tenter de factoriser du code commun ici
}

-(void)dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)keyPath sender:(MFUIBaseViewModel *)sender {
    //TODO QLA : Tenter de factoriser du code commun ici
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

-(NSDictionary*) getFiltersFromViewModelToForm {
    MFCoreLogVerbose(@"MFFormBaseViewController getFiltersFromViewModelToForm does nothing return empty dictionary");
    return @{};
}


-(NSDictionary*) getFiltersFromFormToViewModel {
    MFCoreLogVerbose(@"MFFormBaseViewController getFiltersFromFormToViewModel does nothing return empty dictionary");
    return @{};
}

#pragma mark - Custom methods

-(NSString *) cellIdentifierAtIndexPath:(NSIndexPath *)indexPath withGroupDescriptor:(MFGroupDescriptor *)groupDescriptor {
    return groupDescriptor.uitype;
}
@end

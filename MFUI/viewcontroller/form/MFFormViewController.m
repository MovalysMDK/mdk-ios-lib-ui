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


//Imports MFCore
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreFormConfig.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreAction.h>

//Main interface
#import "MFFormViewController.h"

//MFCore imports
#import <MFCore/MFCoreFormDescriptor.h>

//Delegate & Protocol
#import "MFAppDelegate.h"
#import "MFFormValidationDelegate.h"
#import "MFTypeValueProcessingProtocol.h"

//Cells
#import "MFFormCellProtocol.h"
#import "MFCellAbstract.h"

//ViewControllers
#import "MFFormDetailViewController.h"
#import "MFMapViewController.h"
#import "MFPhotoDetailViewController.h"

//Utils
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import "MFUIApplication.h"
#import "MFConstants.h"

//Binding and form

#import "MFUIBaseViewModel.h"

// Allowed values : (DiscardChangesAlert,SaveChangesAlert, AutomaticSave)
NSString *const MFPROP_FORM_ONUNSAVEDCHANGES = @"FormOnUnsavedChanges";

@interface MFFormViewController () <CLLocationManagerDelegate,UIAlertViewDelegate>

@property(nonatomic, strong) MFApplication *applicationContext;

@property(nonatomic) CGFloat keyboardVisibleHeight;

@property (nonatomic, strong) NSIndexPath *screenIndexPath;

@end

@implementation MFFormViewController

@synthesize formDescriptor = _formDescriptor;
@synthesize viewModel = _viewModel;
@synthesize loadingOptions = _loadingOptions;
@synthesize ids = _ids;


/**
 Initialise le controlleur :
 - allocation de l'extension du formulaire
 */
-(void) initialize {
    [super initialize];
    self.keyboardVisibleHeight = CGFLOAT_MAX ;
    
    //Initializing FormValidation
    if([self usePartialViewModel]) {
        self.formValidation = [[MFFormViewControllerPartialValidationDelegate alloc] initWithFormController:self];
    }
    else {
        self.formValidation = [[MFFormViewControllerValidationDelegate alloc] initWithFormController:self];
    }
    
    //Initilizing fake "creen" indexpath. This corresponds to a fake indexpath associated ro
    self.screenIndexPath = [NSIndexPath indexPathForRow:SCREEN_INDEXPATH_ROW_IDENTIFIER inSection:SCREEN_INDEXPATH_SECTION_IDENTIFIER];
}


#pragma mark - Cycle de vie du controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.mf.formDescriptorName) {

        MFAppDelegate *mfDelegate = nil;
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        if([appDelegate isKindOfClass:[MFAppDelegate class]]){
            mfDelegate = (MFAppDelegate *) appDelegate;
        }
        
        //Load the form descriptor that describes this FormViewController
        [self loadFormDescriptor];
        
        //For analysis allows to know the formType
        [self analyzeForm];
        
        //Adapt controller to the formType
        [self processControllerChanges];
        
        //Setup bar items (back, save...)
        [self setupBarItems];
    }
    else {
        MFUILogError(@"mf.formDescriptorName is missing");
        @throw [NSException exceptionWithName:@"MissingFormDescriptorName" reason:@"The form descriptor name is missing" userInfo:nil];
    }
    
    // fix separator display at the bottom of the tableview
    UIView *f = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    f.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setTableFooterView:f];
}

-(void) analyzeForm {
    if(self.formDescriptor.sections.count == 0) {
        self.formType = MFFormTypeSimple;
    }
    else if(self.formDescriptor.noTableSections.count == 0) {
        self.formType = MFFormTypeForm;
    }
    else {
        self.formType = MFFormTypeMixte;
    }
}

-(void) processControllerChanges {
    switch (self.formType) {
        case MFFormTypeForm:
            //Nothinng to do
            break;
        case MFFormTypeSimple:
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            [self registerScreenComponentsFromSectionDescriptor:self.formDescriptor.noTableSections];
            break;
        case MFFormTypeMixte:
            [self registerScreenComponentsFromSectionDescriptor:self.formDescriptor.noTableSections];
            break;
        default:
            break;
    }
    
    for(MFUIBaseComponent *component in [self.binding componentsArrayAtIndexPath:self.screenIndexPath]) {
        [self initComponent:component atIndexPath:self.screenIndexPath];
    }
}

-(void) registerScreenComponentsFromSectionDescriptor:(NSArray *)screenSectionDescriptors {
    for(MFSectionDescriptor *screenSectionDescriptor in screenSectionDescriptors) {
        for(MFGroupDescriptor *groupDescriptor in screenSectionDescriptor.orderedGroups) {
            for(MFFieldDescriptor *fieldDescriptor in groupDescriptor.fields) {
                MFUIBaseComponent *component = (MFUIBaseComponent *)[self valueForKey:fieldDescriptor.cellPropertyBinding];
                component.form = self;
                component.groupDescriptor = groupDescriptor;
                [component setComponentInCellAtIndexPath:self.screenIndexPath];
                component.selfDescriptor = fieldDescriptor;
                component.transitionDelegate = self;
                [component setCellContainer:nil];
                [self.binding registerComponents:@[[self valueForKey:fieldDescriptor.cellPropertyBinding]] atIndexPath:self.screenIndexPath withBindingKey:fieldDescriptor.bindingKey];
            }
        }
    }
}

-(void) loadFormDescriptor {
    //Récupération des formDescriptor mise en cache
    MFConfigurationHandler *registry = [_applicationContext getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    MFFormDescriptor *localFormDescriptor = [registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:self.mf.formDescriptorName]];
    self.formDescriptor = localFormDescriptor;
}


- (void) setupBarItems {
    // Add back button on the left bar
    
    UIViewController *topController = [self.navigationController.viewControllers objectAtIndex:0];
    
    //Si le contrôleur courant est au sommet de la pile de navigation, on masque le bouton de retour car il n'y aucune
    //vue sur laquelle retourner.
    if (![self isEqual:topController]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:MFLocalizedStringFromKey(@"form_back") style: UIBarButtonItemStyleBordered
                                                 target:self action:@selector(dismissMyView)];
        
    }
    
    // Add save button on right bar
    if([self showSaveButton]) {
        // Add save button on right bar
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"form_save")
                                                                       style:UIBarButtonItemStylePlain target:self action:@selector(doOnKeepModification:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    //    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //    if ( [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft
    //        || [[UIDevice currentDevice]orientation] == ƒ ){
    //        self.keyboardVisibleHeight = keyboardSize.width ;
    //    }else{
    //        self.keyboardVisibleHeight = keyboardSize.height ;
    //    }
    //    self.tableView.frame = CGRectMake( self.tableView.frame.origin.x , self.tableView.frame.origin.y,   self.tableView.frame.size.width, self.tableView.frame.size.height - self.keyboardVisibleHeight );
    //
    //    if (self.activeFieldIndexPath ) {
    //        MFCoreLogVerbose(@"keyboardWasShown indexPathForSelectedRow row section %d %d", self.activeFieldIndexPath.row ,  self.activeFieldIndexPath.section );
    //        [self.tableView scrollToRowAtIndexPath:self.activeFieldIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //    }
}

// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //MFCoreLogVerbose(@"keyboardWillBeHidden before self.tableView.frame  %f %f (keyboard height %f) " , self.tableView.frame.size.width , self.tableView.frame.size.height , self.keyboardVisibleHeight);
    if ( self.keyboardVisibleHeight != CGFLOAT_MAX )
    {
        self.tableView.frame = CGRectMake( self.tableView.frame.origin.x , self.tableView.frame.origin.y,   self.tableView.frame.size.width, self.tableView.frame.size.height + self.keyboardVisibleHeight);
    }
    //MFCoreLogVerbose(@"keyboardWillBeHidden self.tableView.contentSize %f %f" ,self.tableView.contentSize.width , self.tableView.contentSize.height);
    
    self.keyboardVisibleHeight = CGFLOAT_MAX ;
}

/*
 -(void)viewDidAppear:(BOOL)animated {
 
 //Pas d'appel au super : le doFillAction ne doit pas être systématiquement appelé
 //[super viewDidAppear:animated];
 
 //Doit être appelé en premier
 BOOL bDoFillAction =  ![ [MFUIApplication getInstance].lastAppearViewController conformsToProtocol:@protocol(MFDetailViewControllerProtocol) ];
 
 //On appelle un viewDidAppear spécifique qui ne comprend pas le doFillAction, celui-ci n'étant pas tout le temps appelé
 //(par exemple si on revient d'une vue de détails d'un item de liste).
 //Dans ce viewDidAppear spécifique, le "lastAppearViewController" sera modifié et ne contiendra plus le contrôleur depuis lequel on vient. Par conséquent, on vérifie avant si "lastAppearViewController" est conforme à une vue de détail, ce qui permet de ne pas lancer le doFillAction dans ce cas précis.
 [self mFViewControllerViewDidAppear:animated];
 
 //Pas de rechargement depuis un contrôleur affichant une vue dite de détail (détails d'un item de liste,
 //détails d'une photo, etc)
 if (bDoFillAction) {
 [self doFillAction];
 }
 }*/

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.formDescriptor) {
        [self loadFormDescriptor];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    self.formDescriptor = nil;
    self.mf = nil;
    self.formValidation = nil;
}

-(void)doFillAction {
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (doFillAction)" userInfo:nil]);
}

-(NSString *) nameOfDataLoader{
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (nameOfDataLoader)" userInfo:nil]);}

-(id<MFUIBaseViewModelProtocol>) createViewModel{
    @throw([NSException exceptionWithName:@"Not Implemented" reason:@"This method should be implemented in child classes (createViewModel)" userInfo:nil]);
}


#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.formDescriptor.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    MFSectionDescriptor *sectionDescriptor = self.formDescriptor.sections[section];
    NSUInteger length = sectionDescriptor.orderedGroups.count;
    return length;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Récupération de la cellule créée par le BaseFormViewController
    id<MFFormCellProtocol> formCell = (id<MFFormCellProtocol>)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return (UITableViewCell *)formCell;
    
}


#pragma mark  - Binding Form/ViewModel : évènements de binding


-(void) dispatchEventOnComponentValueChangedWithKey:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath {
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre pour ce composant
        MFValueChangedFilter applyFilter = [[self filtersFromFormToViewModel] objectForKey:bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter)
            continueDispatch = applyFilter(bindingKey, self.viewModel, self.binding);
        
        NSString *fullBindingKey  = [self bindingKeyWithIndexPathFromKey:bindingKey andIndexPath:indexPath];
        //Si la mise a jour n'est pas bloquée par le filtre
        NSMutableArray *componentList = [[self.binding componentsAtIndexPath:indexPath withBindingKey:bindingKey] mutableCopy];
        if(continueDispatch && componentList) {
            for(id<MFUIComponentProtocol> component in componentList) {
                
                id newValue = [component getData];
                if ( [self.formValidation validateNewValue:newValue onComponent:component withFullBindingKey:fullBindingKey]) {
                    newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:YES];
                    [self.viewModel setValue:newValue forKeyPath:bindingKey];
                }
            }
        }
        [self releasePropertyFromMutex:bindingKey];
    }
    else {
        [self releasePropertyFromMutex:bindingKey];
    }
    
    
}


-(void) dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)bindingKey sender:(MFUIBaseViewModel *)viewModelSender {
    
    //Reconstruction du keyPath si c'est le cas
    
    
    NSMutableArray *componentList = [[self.binding componentsWithBindingKey:bindingKey] mutableCopy];
    if(!componentList) {
        if (viewModelSender.parentViewModelPrefix && viewModelSender.parentViewModel) {
            bindingKey = [[viewModelSender.parentViewModelPrefix stringByAppendingString:@"."] stringByAppendingString:bindingKey];
        }
    }
    componentList = [[self.binding componentsWithBindingKey:bindingKey] mutableCopy];
    
    //Si la ressource n'est pas déja tenue par un autre évènement
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        //Récupération et application du filtre ppour ce composant
        MFValueChangedFilter applyFilter = [[self filtersFromViewModelToForm] objectForKey:bindingKey];
        BOOL continueDispatch = YES;
        if(applyFilter)
            continueDispatch = applyFilter(bindingKey, self.viewModel, self.binding);
        
        
        //Si la mise a jour n'est pas bloquée par le filtre
        if(continueDispatch) {
            if(componentList) {
                for(id<MFUIComponentProtocol> component in componentList) {
                    id oldValue = [component getData];
                    id newValue =[self.viewModel valueForKeyPath:bindingKey];
                    newValue = [self applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:newValue isFormToViewModel:NO];
                    MFNonEqual(oldValue, newValue, ^{
                        [self.applicationContext execSyncInMainQueue:^{
                            [component setData:newValue];
                        }];
                    });
                    
                }
            }
            else {
                [self performSelectorForPropertyBinding:bindingKey];
            }
        }
        // On lâche la ressource à la fin du traitement
        [self releasePropertyFromMutex:bindingKey];
    }
    else {
        // Si on passe ici, c'est que le champ vient d'être modifié dans le viewModel suite à une modif du formulaire.
        // On peut donc maintenant appliquer la modification la méthode custom appelée quand le champ est modifié dans le modèle
        [self releasePropertyFromMutex:bindingKey];
    }
    [self applyCustomValueChangedMethodForComponents:componentList];
    
    
}


-(BOOL) addError:(id)error onComponent:(NSString *)bindingKey atIndexPath:(NSIndexPath *)indexPath {
    
    BOOL errorAdded = NO;
    
    NSMutableArray *componentList = [[self.binding componentsWithBindingKey:bindingKey] mutableCopy];
    
    if([self.formBindingDelegate mutexForProperty:bindingKey]) {
        
        if(componentList) {
            for(id<MFUIComponentProtocol> component in componentList) {
                [component addErrors:error];
                errorAdded = YES ;
            }
        }
        
        [self releasePropertyFromMutex:bindingKey];
    }
    else {
        
        [self releasePropertyFromMutex:bindingKey];
    }
    return errorAdded ;
}


/**
 * @brief Cette méthode applique un traitement particulier lorsque la valeur du champ correspondant dans le ViewModel
 * à la liste des composants passée en paramètres est modifiée.
 * @param componentList Une liste de composants (définis dans les formulaires PLIST) dont on souhaite écouter les modifications
 * de valeur dans le ViewModel
 */
-(void) applyCustomValueChangedMethodForComponents:(NSArray *)componentList {
    //Application des méthodes spécifiés pour le changement de cette valeur, s'il y en a dans le PLIST
    if(componentList) {
        for(id<MFUIComponentProtocol> component in componentList) {
            NSString *customValuechangedMethod = ((MFFieldDescriptor *)[component selfDescriptor]).vmValueChangedMethodName;
            
            //Si une custom method est définie
            if(customValuechangedMethod) {
                //et qu'elle est implémentée, on l'exécute, sinon on informe l'utilisateur
                if([self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", customValuechangedMethod])]){
                    
                    // Par défaut le compilateur affiche un warning indiquant que performSelector avec un NSSelectorFromString
                    // peut causer des fuites mémoire car il ne sait pas vérifier que le sélecteur existe réellement.
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", customValuechangedMethod]) withObject:component.lastUpdateSender];
                    component.lastUpdateSender = nil;
                }
                else {
                    @throw([NSException exceptionWithName:@"Not Implemented" reason:[NSString stringWithFormat:@"You should implement the custom value changed method %@ defined in PLIST file on %@", customValuechangedMethod, self.class] userInfo:nil]);
                }
                
            }
        }
    }
}



/**
 * @brief Cette méthode réalise les actions demandées d'après le changement de valeur d'une propriété
 * du ViewModel. D'après le nom de la propriété qui a changé, la méthode va vérifier dans son dictionnaire
 * de propriétés bindées, les composant et leur champs à modifier.
 * @param propertyBindingKey Le nom de la propriété qui a changéi */
-(void) performSelectorForPropertyBinding:(NSString *) propertyBindingKey {
    
    NSDictionary * listeners = [self.propertiesBinding objectForKey:propertyBindingKey];
    
    //S'il y a des champs qui écoutent le changement de la propriété propertyBindingKey
    if(listeners) {
        for(NSString * componentName in [listeners allKeys]) {
            //Récupération du nom du champ qui écoute la propriété et de la propriété du champ à modifier
            NSString *listenerName = componentName;
            
            MFBindingComponentDescriptor * bindingDescriptor = [listeners objectForKey:componentName];
            MFFieldDescriptor * componentDescriptor = bindingDescriptor.componentDescriptor;
            
            NSString *property = bindingDescriptor.bindableProperty;
            // Si on a toutes les informations, on modifie la propriété récupérée sur le champs récupéré
            // avec la nouvelle valeur
            if(listenerName && property) {
                NSMutableArray *componentList = [[self.binding componentsWithBindingKey:componentDescriptor.bindingKey] mutableCopy];
                for(id<MFUIComponentProtocol> listener in componentList) {
                    NSString * selectorName = [self generateSetterFromProperty:property];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [listener performSelector:NSSelectorFromString(selectorName) withObject:[self.viewModel valueForKeyPath:propertyBindingKey]];
                    });
                }
            }
        }
    }
}





#pragma mark - Initialisation des composants graphiques

-(void) initComponent:(id<MFUIComponentProtocol>)component atIndexPath:(NSIndexPath *)indexPath{
    
    [(MFUIBaseComponent *)component setInInitMode:YES];
    
    //Initialize Data
    MFFieldDescriptor * componentDescriptor = (MFFieldDescriptor *) component.selfDescriptor;
    
    NSString *fullBindingKey  = [self bindingKeyWithIndexPathFromKey:componentDescriptor.bindingKey andIndexPath:indexPath];
    
    id valueForKeyPath ;
    // first check if values present in invalid values
    if ([self.formValidation hasInvalidValueForFullBindingKey:fullBindingKey] ) {
        valueForKeyPath = [self.formValidation getInvalidValueForFullBindingKey:fullBindingKey];
        [component addErrors: [self.formValidation getErrorsForFullBindingKey:fullBindingKey]];
    }
    else {
        // if not found, read value from viewmodel (return MFKeyNotFound if binding key not found)
        valueForKeyPath = [self.viewModel valueForKeyPath:componentDescriptor.bindingKey];
        [component clearErrors];
    }
    
    if( valueForKeyPath != [MFKeyNotFound keyNotFound]) {
        valueForKeyPath = [self applyConverterOnComponent:component forValue:valueForKeyPath isFormToViewModel:NO];
        [self performSelector:@selector(setData:) onComponent:component withObject:valueForKeyPath];
    }
    else {
        //MFCoreLogInfo(@"Binding Key \"%@\" was not found on %@",componentDescriptor.bindingKey, [self.viewModel class]);
        // In case of error, component must be reinitialized (because views are reused and may contain an old value)
        [self performSelector:@selector(setData:) onComponent:component withObject:nil];
    }
    
    
    
    
    // Show deferred errors on component (= errors from previous validation and component was not visible).
    [self.formValidation addDeferredErrorsOnComponent:component withFullBindingKey:fullBindingKey];
    
    // Initializing other bindable properties of component (ex: mandatory, i18nKey, converter, visible, backgroundColor, textColor)
    for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
        
        // get value type
        NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
        
        // get class to process value
        NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
        id<MFTypeValueProcessingProtocol> valueProcessor = [[NSClassFromString(processingClass) alloc] init];
        
        // compute value using processor
        id object = [valueProcessor processTreatmentOnComponent:component withViewModel:self.viewModel forProperty:bindablePropertyName fromBindableProperties:self.bindableProperties];
        
        // Get setter for property
        NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
        
        if(object != nil && object != [MFKeyNotFound keyNotFound]) {
            [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
        }
    }
    
    [(MFUIBaseComponent *)component setInInitMode:NO];
}

-(MFGroupDescriptor *) getGroupDescriptor:(NSIndexPath *)indexPath {
    return ((MFSectionDescriptor *)self.formDescriptor.sections[indexPath.section]).orderedGroups[indexPath.row];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // alert for discard changes
    if (alertView.tag == kDiscardChangesAlert && buttonIndex == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    // alert for save changes
    if (alertView.tag == kSaveChangesAlert ){
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self doOnKeepModification: self];
        }
    }
}

- (void)dismissMyView {
    
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    NSString *actionType = [registry getStringProperty:MFPROP_FORM_ONUNSAVEDCHANGES];
    bool doShowAlert = NO;
    bool doSave = NO;
    if (actionType && [actionType isEqualToString:@"DiscardChangesAlert"]) {
        doShowAlert = YES;
    }
    if (actionType && [actionType isEqualToString:@"SaveChangesAlert"]) {
        doShowAlert = YES;
        doSave = YES ;
    }
    if (actionType && [actionType isEqualToString:@"AutomaticSave"]) {
        doSave = YES ;
    }
    
    if (!actionType || ![[self getFormValidation] onCloseFormDoAlert:doShowAlert andSave:doSave] ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) doOnKeepModification:(id)sender {
    MFUILogVerbose(@"doOnKeepModification");
}

-(MFFormViewControllerValidationDelegate *)getFormValidation {
    return (MFFormViewControllerValidationDelegate *)self.formValidation;
}


#pragma mark - Unimplemented

-(void)completeFiltersFromFormToViewModel:(NSDictionary *)filters {
    //Should be implemented in child classes if necessary
}

-(void)completeFiltersFromViewModelToForm:(NSDictionary *)filters {
    //Should be implemented in child classes if necessary
}

-(NSDictionary *)getFiltersFromFormToViewModel {
    //Should be implemented in child classes if necessary
    return [NSDictionary dictionary];
}

-(NSDictionary *)getFiltersFromViewModelToForm {
    //Should be implemented in child classes if necessary
    return [NSDictionary dictionary];
}

-(NSString *)nameOfViewModel {
    //Should be implemented in child classes if necessary
    return nil;
}

-(BOOL) usePartialViewModel {
    return NO;
}

-(NSArray *) partialViewModelKeys {
    return  @[];
}

-(void)removeFromParentViewController {
    [super removeFromParentViewController];
    
}

-(BOOL) showSaveButton {
    for(MFSectionDescriptor *sectionDescriptor in [self.formDescriptor.sections arrayByAddingObjectsFromArray:self.formDescriptor.noTableSections]) {
        for(MFGroupDescriptor *groupDescriptor in sectionDescriptor.groups.allValues) {
            for(MFFieldDescriptor *fieldDescriptor in groupDescriptor.fields) {
                if(fieldDescriptor.editable && [fieldDescriptor.editable boolValue]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


@end

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
#import  <MFCore/MFCoreError.h>


//Main intrface
#import "MFPickerControllerDelegate.h"

//Cell import
#import "MFCellAbstract.h"

//Protocol imports
#import "MFUIBaseViewModelProtocol.h"
#import "MFTypeValueProcessingProtocol.h"

#import "MFFormConstants.h"
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
 * @brief The Form descriptor corresponding to the static view
 */
@property (nonatomic, strong) MFFormDescriptor *selectedViewFormDescriptor;

/**
 * @brief The Form descriptor corresponding to the static view
 */
@property (nonatomic, strong) MFFormDescriptor *itemViewFormDescriptor;

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


@synthesize reusableBindingViews = _reusableBindingViews;
@synthesize formDescriptor = _formDescriptor;
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
    self.formBindingDelegate = [[MFBaseBindingForm alloc] initWithParent:self];
    [self reinitBinding];
    self.filteredViewModels = [self initializeFilteredViewModels];
    self.shouldSetCellHeight = YES;
}

-(void) reinitBinding {
    [((MFBaseBindingForm *)self.formBindingDelegate) reinit];
}

-(void)setContent {
    
    //Récupération des données
    self.viewModel = [self.picker getData];
    
    self.viewModel.form = self;
    
    [self initDescriptors];
    //Récupération des descripteurs des vues à créer
    MFSectionDescriptor *currentSection = self.selectedViewFormDescriptor.sections[0];
    MFGroupDescriptor *currentGd = nil;
    currentGd = currentSection.orderedGroups[0];
    self.staticViewNibName = currentGd.uitype;
    
    
    //Création de la vue statique
    [self.picker didFinishLoadDescriptor];

    MFBindingViewAbstract * view = nil;
    if(self.staticViewNibName) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:self.staticViewNibName owner:self options:nil];
        if(topLevelObjects && topLevelObjects.count >0) {
            view = [topLevelObjects objectAtIndex:0];
        }
        for(UIView * subview in view.subviews) {
            if([subview isKindOfClass:[MFUIBaseComponent class]]) {
                MFUIBaseComponent *subcomponent = (MFUIBaseComponent *)subview;
                subcomponent.applySelfStyle = NO;
            }
        }
    }
    else {
        [MFException throwExceptionWithName:@"Missing property" andReason:[NSString stringWithFormat:@"The property typeName must be filled on %@%@.plist (group)",CONST_FORM_RESOURCE_PREFIX, [self.picker selectedViewFormDescriptorName]] andUserInfo:nil];
    }
    
    [self.picker.staticView  configureByGroupDescriptor:currentGd andFormDescriptor:self.selectedViewFormDescriptor];
    
    if(!self.picker.emptyViewNibName) {
        self.picker.staticView = view;
    }
    
    
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

-(void) initDescriptors {
    if(![self.registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:[self.picker lstItemViewFormDescriptorName]]]) {
        [self.registry loadFormWithName:[self.picker lstItemViewFormDescriptorName]];
    }
    self.itemViewFormDescriptor = [self.registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:[self.picker lstItemViewFormDescriptorName]]];
    
    //Récupération du descripteur du formulaire de la vue statique
    if(![self.registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:[self.picker selectedViewFormDescriptorName]]]) {
        [self.registry loadFormWithName:[self.picker selectedViewFormDescriptorName]];
    }
    self.selectedViewFormDescriptor = [self.registry getFormDescriptorProperty:[CONST_FORM_RESOURCE_PREFIX stringByAppendingString:[self.picker selectedViewFormDescriptorName]]];
    
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
    MFGroupDescriptor *currentGd = nil;
    
    //Récupération du NIB à utiliser pour dessiner la vue
    if(!self.itemViewFormDescriptor) {
        [self initDescriptors];
    }
    MFSectionDescriptor *currentSection = self.itemViewFormDescriptor.sections[0];
    //        if([[self viewModel] isKindOfClass:[MFUIBaseViewModel class]]) {
    currentGd = currentSection.orderedGroups[0];
    //        }
    self.itemViewNibName = currentGd.uitype;
    
    
    MFBindingViewAbstract *pickerItemView = (MFBindingViewAbstract *)view;
    
    //Création de la vue
    if(pickerItemView == nil) {
        pickerItemView = [self itemView];
    }
    
    if([pickerItemView conformsToProtocol:@protocol(MFBindingViewProtocol)]) {
        
        MFBindingViewAbstract *formView = (MFBindingViewAbstract *) pickerItemView;
        //        [((MFBindingViewAbstract *)formView) refreshComponents];
        
        //Enregistrement et désenregistrement des vues déja créées.
        if(![self.reusableBindingViews containsObject:formView]) {
            [self.reusableBindingViews addObject:formView];
        }
        else {
            [formView unregisterComponents:self];
        }
        [self.binding unregisterComponentsAtIndexPath:virtualIndexPath withBindingKey:nil];
        
        //Réinitialisation de la vue
        ((MFCellAbstract *)formView).formController = self;
        [formView setCellIndexPath:virtualIndexPath];
        
        //Style de la cellule
        [formView configureByGroupDescriptor:currentGd andFormDescriptor:self.itemViewFormDescriptor];
        
        //Enregistrement des composants graphiques de la vue
        NSDictionary *newRegisteredComponents = [self registerComponentsFromCell:formView];
        for(NSString *key in [newRegisteredComponents allKeys]) {
            //Récupération de la liste des composants associé à ce keyPath
            
            NSMutableArray *componentList = [[self.binding componentsAtIndexPath:virtualIndexPath withBindingKey:key] mutableCopy];
            if(componentList) {
                for(MFUIBaseComponent *component in componentList) {
                    //Initialisation des composants
                    [self initComponent:component atIndexPath:virtualIndexPath];
                }
            }
        }
        [self setDataOnView:formView withOptionalViewModel:nil];
    }
    else {
        MFUILogWarn(@"The picker view item is not a MFBindingViewProtocol");
    }
    [pickerItemView viewIsConfigured];
    return pickerItemView;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filteredViewModels.count;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    //Récupération de la taille dans la configuration
    NSIndexPath *virtualIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MFGroupDescriptor *group = [self getGroupDescriptorAtIndexPath:virtualIndexPath];
    CGFloat value = [group.height floatValue];
    return value;
}

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

#pragma mark - Gestion des données des cellules
/**
 * @brief Cette méthode permet d'initialiser  (graphiquement) le composant passé en paramètre
 * à partir des données du PLIST du formulaire
 * @param component Le composant à initialiser
 */
-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath{
    
    
    //Initialize Data
    MFFieldDescriptor * componentDescriptor = (MFFieldDescriptor *) component.selfDescriptor;
    
    [[self.filteredViewModels objectAtIndex:indexPath.row] valueForKeyPath:componentDescriptor.bindingKey];
    
    [component clearErrors];
    
    //Initializing each bindableProperty if defined
    for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
        NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
        NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
        
        id object = [((id<MFTypeValueProcessingProtocol>)[[NSClassFromString(processingClass) alloc] init]) processTreatmentOnComponent:component withViewModel:[self.filteredViewModels objectAtIndex:indexPath.row] forProperty:bindablePropertyName fromBindableProperties:self.bindableProperties];
        
        NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
        
        if(object) {
            [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
        }
    }
}

/**
 * @brief Cette méthode enregistre dans le mapping les composants principaux de
 * la cellule
 * @param cell La cellule dont on souhaite enregisrer les composants
 */
-(NSDictionary *)registerComponentsFromCell:(id<MFFormCellProtocol>) cell {
    return [cell registerComponent:self];
}

-(void)unregisterComponents:(id<MFBindingFormDelegate>)formController {
    [self.picker.staticView unregisterComponents:self];
    [self.picker.cellContainer unregisterComponents:formController];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
/**
 * @brief Cette méthode met à jour les données de la cellule selon son indexPath
 * @param cell La cellule
 */
-(void) setDataOnView:(id<MFFormCellProtocol>)cell withOptionalViewModel:(MFUIBaseViewModel *)viewModel{
    
    NSMutableArray *cellComponents = [NSMutableArray array];
    NSIndexPath *indexPath = cell.cellIndexPath;
    
    cellComponents = [[self.binding componentsArrayAtIndexPath:indexPath] mutableCopy];
    for(id<MFUIComponentProtocol> component in cellComponents) {
        MFFieldDescriptor *componentDescriptor = (MFFieldDescriptor *)component.selfDescriptor;
        
        
        if(!viewModel) {
            //Si la liste est plein, on récupère un object directement via sa clé, qui est sa position dans la liste
            if(self.filteredViewModels.count == [self pickerListViewModel].viewModels.count) {
                viewModel = [self.filteredViewModels objectAtIndex:indexPath.row];
            }
            //Sinon on parcourt la liste des résultats (le dictionnaire filteredViewModels n'étant pas ordonné).
            else {
                viewModel = [self.filteredViewModels objectAtIndex:indexPath.row];
            }
        }
        
        id componentData = [viewModel valueForKeyPath:componentDescriptor.bindingKey];
        
        
        if(componentData) {
            componentData = [self applyConverterOnComponent:component forValue:componentData isFormToViewModel:NO];
            //            dispatch_async(dispatch_get_main_queue(),  ^{
            [self performSelector:@selector(setData:) onComponent:component withObject:componentData];
            //            });
        }
        else {
            MFUILogInfo(@"Binding Key \"%@\" was not found on %@",componentDescriptor.bindingKey, [self.viewModel class]);
        }
        
        //Set parameters for this component if exist
        if(componentDescriptor.parameters) {
            for(NSString *key in componentDescriptor.parameters.allKeys) {
                if([component respondsToSelector:NSSelectorFromString([self generateSetterFromProperty:key])]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [component performSelector:NSSelectorFromString([self generateSetterFromProperty:key]) withObject:[componentDescriptor.parameters objectForKey:key]];
                    });
                }
            }
            
        }
    }
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

#pragma  mark - MFViewModelChangedListenerProtocol methods

-(void)dispatchEventOnViewModelPropertyValueChangedWithKey:(NSString *)keyPath sender:(MFUIBaseViewModel *)sender {
    [self fillSelectedViewWithViewModel:[self getSelectedViewModel]];
    
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
    
    //Récupération de la configuration de la vue
    MFSectionDescriptor *currentSection = self.selectedViewFormDescriptor.sections[UNIQUE_PICKER_LIST_SECTION_INDEX];
    MFGroupDescriptor *currentGd = nil;
    if([viewModel isKindOfClass:[MFUIBaseViewModel class]]) {
        currentGd = currentSection.orderedGroups[UNIQUE_PICKER_LIST_SECTION_INDEX];
    }
    
    
    //Réinitialisation de la vue
    id<MFFormCellProtocol> formView = (id<MFFormCellProtocol>)self.picker.staticView;
    ((MFBindingViewAbstract *)formView).formController = self;
    //Style de la cellule
    [formView configureByGroupDescriptor:currentGd andFormDescriptor:self.selectedViewFormDescriptor];
    //    [((MFBindingViewAbstract *)formView) refreshComponents];
    
    //Traitement des champs de la vue statique
    for( NSString *fieldName in self.picker.staticView.groupDescriptor.fieldNames) {
        MFUIBaseComponent *component = [self.picker.staticView valueForKey:fieldName];
        
        id componentData =[(MFUIBaseViewModel *)viewModel valueForKey:((MFFieldDescriptor *)component.selfDescriptor).bindingKey];
        componentData = [self applyConverterOnComponent:component forValue:componentData isFormToViewModel:NO];
        
        [component performSelector:@selector(setData:) withObject:componentData];
        
        //Traitement de chaque bindableProperties
        for(NSString *bindablePropertyName in [self.bindableProperties allKeys]) {
            NSString *valueType = [[self.bindableProperties objectForKey:bindablePropertyName] objectForKey:@"type"];
            NSString *processingClass = [NSString stringWithFormat:@"MF%@ValueProcessing", [valueType capitalizedString]];
            
            id object = [((id<MFTypeValueProcessingProtocol>)[[NSClassFromString(processingClass) alloc] init]) processTreatmentOnComponent:component withViewModel:viewModel forProperty:bindablePropertyName fromBindableProperties:self.bindableProperties];
            
            NSString *selector = [self generateSetterFromProperty:bindablePropertyName];
            
            if(object) {
                [self performSelector:NSSelectorFromString(selector) onComponent:component withObject:object];
            }
        }
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

-(MFGroupDescriptor *) getGroupDescriptorAtIndexPath:(NSIndexPath *)indexPath {
    return ((MFSectionDescriptor *)self.itemViewFormDescriptor.sections[indexPath.section]).orderedGroups[indexPath.row];
}



#pragma mark - Forwarding methods of Binding Form protocol
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

-(void)setViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    self.formBindingDelegate.viewModel = viewModel;
}

-(id<MFUIBaseViewModelProtocol>)viewModel {
    return self.formBindingDelegate.viewModel;
}

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
    return [self.formBindingDelegate unregisterAllComponents];
}

-(NSString *)generateSetterFromProperty:(NSString *)propertyName {
    return [self.formBindingDelegate generateSetterFromProperty:propertyName];
}

-(void)performSelector:(SEL)selector onComponent:(MFUIBaseComponent *)component withObject:(id)object {
    [self.formBindingDelegate performSelector:selector onComponent:component withObject:object];
}

-(id)applyConverterOnComponent:()component forValue:(id)value isFormToViewModel:(BOOL)formToViewModel {
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel];
}

-(id)applyConverterOnComponent:()component forValue:(id)value isFormToViewModel:(BOOL)formToViewModel withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    return [self.formBindingDelegate applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel withViewModel:viewModel];
}

-(NSDictionary *)getFiltersFromViewModelToForm {
    return [NSDictionary dictionary];
}

-(NSDictionary *)getFiltersFromFormToViewModel {
    return [NSDictionary dictionary];
}

-(MFUIBaseListViewModel *) pickerListViewModel {
    return (MFUIBaseListViewModel *)[self.picker getValues];
}

@end

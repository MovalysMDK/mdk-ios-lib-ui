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

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreFormConfig.h>

#import "MFBaseBindingForm.h"
#import "MFFormCellProtocol.h"
#import "MFUIComponentProtocol.h"
#import "MFConverterProtocol.h"
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import "MFUIComponentProtocol.h"
#import "MFCellAbstract.h"
#import "MFFormViewController.h"

NSString *const MF_BINDABLE_PROPERTIES = @"BindableProperties";

@interface MFBaseBindingForm()

/**
 * @brief The registry used to create beans
 */
@property (nonatomic, weak) MFConfigurationHandler *registry;

/**
 * @brief An array containing the sizes of the cell for this form
 */
@property (nonatomic, strong) NSMutableDictionary *cellSizes;

@end


@implementation MFBaseBindingForm


@synthesize activeField = _activeField;
@synthesize binding = _binding;
@synthesize bindableProperties = _bindableProperties;
@synthesize propertiesBinding;
@synthesize parent;
@synthesize filtersFromFormToViewModel;
@synthesize filtersFromViewModelToForm;
@synthesize mutexPropertiesName;
@synthesize reusableBindingViews = _reusableBindingViews;
@synthesize viewModel = _viewModel;
@synthesize formDescriptor = _formDescriptor;
@synthesize formValidation = _formValidation;


#pragma mark - Initializing
-(id)initWithParent:(id<MFBindingFormDelegate>) parentForm {
    self = [super init];
    if(self) {
        self.parent = parentForm;
        [self initialize];
    }
    return self;
}


-(void) initialize {
    self.registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    
    self.binding = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_BINDING];

    if([self.parent isKindOfClass:[MFFormViewController class]]) {
        //MF%FormViewController
        self.binding.bindingMode = MFBindingModeForm;
    }
    else {
        //MFFormListViewController, MFForm2DListViewController, MFForm3DListViewController, MFCellComponentFixedList, MFCellComponentPickerList
        self.binding.bindingMode = MFBindingModeList;
    }
    
    self.filtersFromViewModelToForm = [NSDictionary dictionary];
    self.filtersFromFormToViewModel = [NSDictionary dictionary];
    self.propertiesBinding = [NSMutableDictionary dictionary];
    self.bindableProperties = [[self.registry getDictionaryProperty:MF_BINDABLE_PROPERTIES] mutableCopy];
    self.mutexPropertiesName = [NSMutableArray array];
    
    //Récupération des filtres de mises à jour des données du formulaire.
    [self completeFiltersFromViewModelToForm:[self getFiltersFromViewModelToForm]];
    [self completeFiltersFromFormToViewModel:[self getFiltersFromFormToViewModel]];
    
}



#pragma mark - BINDING : utils
-(NSString *)bindingKeyWithIndexPathFromKey:(NSString *)key andIndexPath:(NSIndexPath *)indexPath {
    return [key stringByAppendingFormat:@"_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
}

-(NSString *)bindingKeyFromBindingKeyWithIndexPath:(NSString *)key {
    if([key rangeOfString:@"_"].location != NSNotFound) {
        NSMutableArray *components = [[key componentsSeparatedByString:@"_"] mutableCopy];
        if(components.count > 2) {
            // Remove 2 last objects
            [components removeLastObject];
            [components removeLastObject];
            key = [components componentsJoinedByString:@"_"];
        }
        return key;
    }
    else {
        return key;
    }
}

-(NSIndexPath *)indexPathFromBindingKeyWithIndexPath:(NSString *)key {
    NSArray *bindingKeyWithIndexPathComponents = [key componentsSeparatedByString:@"_"];
    int section = 0;
    int row= 0;
    if(bindingKeyWithIndexPathComponents.count >1) {
        section = [[bindingKeyWithIndexPathComponents objectAtIndex:1] intValue];
        row = [[bindingKeyWithIndexPathComponents objectAtIndex:2] intValue];
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(NSString *) generateSetterFromProperty:(NSString *)propertyName {
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
    return propertyName;
}



#pragma mark - BINDING : exclusion mutuelle

-(BOOL)mutexForProperty:(NSString *)propertyName {
    NSMutableArray *tempArray = [NSMutableArray array];
    if(self.mutexPropertiesName != nil) {
        if([self.mutexPropertiesName containsObject:propertyName]) {
            return NO;
        }
        else {
            tempArray = [self.mutexPropertiesName mutableCopy];
            [tempArray addObject:propertyName];
            self.mutexPropertiesName = tempArray;
            return YES;
        }
    }
    else {
        [tempArray addObject:propertyName];
        self.mutexPropertiesName = tempArray;
        return YES;
    }
}


-(void)releasePropertyFromMutex:(NSString *)propertyName {
    if(self.mutexPropertiesName) {
        NSMutableArray *tempArray = [self.mutexPropertiesName mutableCopy];
        [tempArray removeObject:propertyName];
        self.mutexPropertiesName = tempArray;
    }
}






#pragma mark - BINDING : Filtres de mise à jour du formulaire


-(NSDictionary *)getFiltersFromViewModelToForm {
    return [((MFFormBaseViewController *)parent) getFiltersFromViewModelToForm];
}

-(NSDictionary *)getFiltersFromFormToViewModel {
    return [((MFFormBaseViewController *)parent) getFiltersFromFormToViewModel];
}

-(void)completeFiltersFromFormToViewModel:(NSDictionary *)filters {
    NSMutableDictionary *tempFilters = [self.filtersFromFormToViewModel mutableCopy];
    [tempFilters addEntriesFromDictionary:filters];
    self.filtersFromFormToViewModel = tempFilters;
}

-(void)completeFiltersFromViewModelToForm:(NSDictionary *)filters {
    NSMutableDictionary *tempFilters = [self.filtersFromViewModelToForm mutableCopy];
    [tempFilters addEntriesFromDictionary:filters];
    self.filtersFromViewModelToForm = tempFilters;
}


#pragma mark - Actions sur les composants graphiques.

/**
 * @brief Cette méthode désenregistre tous les composants dans le mapping
 */
-(void)unregisterAllComponents {
    for(id<MFFormCellProtocol> bindingView in self.reusableBindingViews) {
        [bindingView unregisterComponents:self.parent];
    }
    
    [self.binding clear];
    
    [self.propertiesBinding removeAllObjects];
    [self.reusableBindingViews removeAllObjects];
    [self.bindableProperties removeAllObjects];
    self.reusableBindingViews = nil;
    self.binding = nil;
    self.propertiesBinding = nil;
    self.bindableProperties = nil;
    
}

-(void) dealloc {
    self.parent = nil;
    self.reusableBindingViews = nil;
    
    self.binding = nil;
    
    self.propertiesBinding = nil;
    self.filtersFromFormToViewModel = nil;
    self.filtersFromViewModelToForm = nil;
    self.bindableProperties = nil;
}


-(void) reinit {
    if(self.binding) {
        [self.binding clear];
    }
    else {
        self.binding = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_BINDING];
    }
    
    if([self.parent isKindOfClass:[MFFormViewController class]]) {
        //MF%FormViewController
        self.binding.bindingMode = MFBindingModeForm;
    }
    else {
        //MFFormListViewController, MFForm2DListViewController, MFForm3DListViewController, MFCellComponentFixedList, MFCellComponentPickerList
        self.binding.bindingMode = MFBindingModeList;
    }
    
    self.propertiesBinding = [NSMutableDictionary dictionary];
    self.reusableBindingViews = [NSMutableArray array];
}

-(void) initComponent:(id<MFUIComponentProtocol>) component atIndexPath:(NSIndexPath *)indexPath{
    @throw([NSException exceptionWithName:@"Should not be implemented" reason:@"This method initComponent:atIndexPath: should be only implemented in child classes" userInfo:nil]);
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void)performSelector:(SEL)selector onComponent:(id<MFUIComponentProtocol>)component withObject:(id)object {
    
    if([component respondsToSelector:selector]) {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        [component performSelector:selector withObject:([object isKindOfClass:[MFKeyNotFound class]] ? nil : object)];

        //        });
    }
    
}
#pragma clang diagnostic pop



#pragma mark - Conversions de types

-(id) applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel {
    return [self applyConverterOnComponent:component forValue:value isFormToViewModel:formToViewModel withViewModel:[self getViewModel]];
}

-(id) applyConverterOnComponent:(id<MFUIComponentProtocol>)component forValue:(id) value isFormToViewModel:(BOOL)formToViewModel withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    id returnValue = value;
    
    //Récupération du convertisseur
    id converterName = nil;
    converterName = ((MFFieldDescriptor *)component.selfDescriptor).converter;
    
    //Si le convertisseur n'est pas nul, alors on applique le convertisseur spécifié
    
    
    NSString *sourceDataType = nil;
    NSString *targetDataType = nil;
    
    if (formToViewModel) {
        sourceDataType = [[component class] getDataType];
        targetDataType = [MFHelperType getClassOfObjectWithKey:((MFFieldDescriptor *)component.selfDescriptor).bindingKey inClass:[viewModel class]];
    } else {
        //      sourceDataType = [MFHelperType getClassOfObjectWithKey:((MFFieldDescriptor *)component.selfDescriptor).bindingKey inClass:[viewModel class]];
        sourceDataType = NSStringFromClass([value class]);
        targetDataType = [[component class] getDataType];
    }
    
    sourceDataType = [MFHelperType primaryType:sourceDataType];
    targetDataType = [MFHelperType primaryType:targetDataType];
    
    
    if(converterName) {
        // Le convertisseur spécifié peut-être par défaut ( et la variable converter est donc un NSString contenant
        // le type de la conversion (float, date, string ...) soit personnalisé et la variable converter est donc un
        // dictionnaire contenant le type de la conversion, ainsi que les paramètres personnalisés de la conversion
        // (exemple : type 'float' avec le paramètre personnalisé 'numberOfDigits' = 5).
        if([converterName isKindOfClass:[NSString class]]) {
            if([[[[self.bindableProperties objectForKey:@"converter"] objectForKey:@"authorizedValue"] componentsSeparatedByString:@";"] containsObject:converterName]) {
                //Le converter est bien connu du framework
                NSString *classConverter = converterName;
                classConverter = [self converterNameFromType:classConverter];
                returnValue = [self callConverterWithName:classConverter withTargetDataType:targetDataType withValue:value withParameters:nil andIsCustom:NO];
            }
            else {
                //Sinon on informe que le convertisseur n'est pas connu.
                @throw([NSException exceptionWithName:@"Invalid parameter" reason:[NSString stringWithFormat:@"The parameter %@ has an invalid value (%@) in PLIST for the component %@", @"converter", converterName, component.selfDescriptor.name] userInfo:nil]);
            }
        }
        else{
            
            // si c'est un dictionnaire, on appelle le convertisseur personnalisé avec les paramètres spécifiés
            NSMutableDictionary *converterParameters = [converterName mutableCopy];
            NSString *classConverter = [converterName objectForKey:@"type"];
            classConverter = [self converterNameFromType:classConverter];
            [converterParameters removeObjectForKey:@"type"];
            returnValue = [self callConverterWithName:classConverter withTargetDataType:targetDataType withValue:value withParameters:converterParameters andIsCustom:YES];
        }
    } else {
        if ((sourceDataType != nil) && (targetDataType != nil)) {
            NSString *classConverter = [self converterNameFromType:sourceDataType];
            returnValue = [self callConverterWithName:classConverter withTargetDataType:targetDataType withValue:value withParameters:nil andIsCustom:NO];
        }
    }
    return returnValue;
}



/**
 * @brief Builds the converter name from a type
 * @param type NSString* The type of the property to convert
 * @return the converter name to apply
 */
-(NSString *)converterNameFromType:(NSString *)type {
    type = [NSString stringWithFormat:@"MF%@Converter", [type capitalizedString]];
    return type;
}


/**
 * @brief Cette méthode appelle un convertisseur et vérifie qu'il existe. Si c'est le cas, la conversion est exécutée
 * @param converterName Le nom du convertisseur à appeler.
 * @param targetDataType Le type cible de la conversion
 * @param value La valeur source de la conversion
 * @param parameters Les paramètres de la conversion
 * @param isCustom Indique s'il s'agit d'un convertisseur par défaut
 * @return La valeur convertie (ou non).
 */
-(id) callConverterWithName:(NSString *)converterName withTargetDataType:(NSString *)targetDataType withValue:(id)value withParameters:(NSDictionary *)parameters andIsCustom:(BOOL)isCustom{
    id returnValue = value;
    Class converter = NSClassFromString(converterName);
    
    if (converter) {
        NSString *targetDataTypeSelector = nil;
        if(!isCustom) {
            targetDataTypeSelector = [NSString stringWithFormat:@"to%@:", targetDataType];
        }
        else {
            targetDataTypeSelector = [NSString stringWithFormat:@"to%@:withParameters:", targetDataType];
        }
        
        SEL convertSelector = NSSelectorFromString(targetDataTypeSelector);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([converter respondsToSelector:convertSelector]) {
            if(!isCustom) {
                returnValue = [converter performSelector:convertSelector withObject:value];
            }
            else {
                returnValue = [converter performSelector:convertSelector withObject:value withObject:parameters];
            }
        }
#pragma clang diagnostic pop
    }

    return returnValue;
}


#pragma mark - Divers


-(id<MFUIBaseViewModelProtocol>)getViewModel {
    return [self.parent getViewModel];
}

-(void)setActiveField:(UIControl *)activeField {
    _activeField = activeField;
}


@end




#pragma mark - MFBindingComponentDescriptor Implemnetation

/**
 * @brief Cette classe est un descripteur pour le binding des propriétés/composants.
 */
@implementation MFBindingComponentDescriptor : NSObject


@end


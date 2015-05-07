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


#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreFormDescriptor.h>
#import <MFCore/MFCoreBean.h>


//Main interface
#import "MFBindingViewAbstract.h"


//Tils
#import "MFUILogging.h"

@protocol MFUIComponentProtocol;


@implementation MFBindingViewAbstract

@synthesize transitionDelegate = _transitionDelegate;
@synthesize formDescriptor = _formDescriptor;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize formController = _formController;
@synthesize hasChanged = _hasChanged;


#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}


-(void) initialize {
    //    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    for(UIView *subView in self.subviews) {
        if([subView conformsToProtocol:@protocol(MFUIComponentProtocol)]) {
            UIView<MFUIComponentProtocol> *baseComponent = (UIView<MFUIComponentProtocol> *)subView;
            [baseComponent setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
    }
    
}

#pragma mark - BindingView Protocol
-(void) refreshComponents {
    for( NSString *fieldName in self.groupDescriptor.fieldNames ) {
        id<MFUIComponentProtocol> component = [self valueForKey:fieldName];
        [component setData:nil];
    }
}



#pragma mark - Custom methods
-(void)setParentEditable:(NSNumber *)parentEditable {
    _parentEditable = parentEditable;
    //On propage la valeur editable du parent sur les composant movalys fils de cette vue.
    for(UIView *subview in self.subviews) {
        if([subview conformsToProtocol:@protocol(MFUIComponentProtocol)]) {
            id<MFUIComponentProtocol> subComponent = (id<MFUIComponentProtocol>)subview;
//            subComponent.parentEditable = parentEditable;
        }
    }
}

#pragma mark - Not implemented


/**
 * Don't implement this function here.
 * Create a new class which inherites this class and implements this function.
 */
-(void)configureByGroupDescriptor:(MFGroupDescriptor*) groupDescriptor
                andFormDescriptor:(MFFormDescriptor *) formDescriptor

{
    
    self.hasChanged = YES;

    
    for( MFFieldDescriptor *fieldDesc in groupDescriptor.fields) {
        id<MFUIComponentProtocol> field = [self valueForKey:fieldDesc.cellPropertyBinding];
        field.localizedFieldDisplayName = groupDescriptor.getFieldDescriptorLabel.getLabel;
        field.selfDescriptor = fieldDesc;
        //        field.formDescriptor = formDescriptor;
        field.groupDescriptor = groupDescriptor;
    }
    
    self.formDescriptor = formDescriptor;
    self.groupDescriptor = groupDescriptor;
    
    
}

-(NSMutableDictionary *)registerComponent:(id<MFBindingFormDelegate>)formController {
    
    //Enregistrement si le composant n'existe pas déja
    if(self.hasChanged) {
        self.hasChanged = NO;
    }
    else {
        return nil;
    }
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    
    for( NSString *fieldName in self.groupDescriptor.fieldNames) {
        id<MFUIComponentProtocol> uiComponent = [self valueForKey:fieldName];
        MFUILogInfo(@"Enregistrement du composant : %@", uiComponent.selfDescriptor.name);
        [returnDictionary addEntriesFromDictionary:[self addComponent:uiComponent toBindingOnForm:formController]];
        [self registerBindablePropertiesFromComponent:uiComponent toPropertiesBindingOnForm:formController];
    }
    return returnDictionary;
}

-(NSMutableDictionary *) addComponent:(id<MFUIComponentProtocol>) component
                      toBindingOnForm:(id<MFBindingFormDelegate>) formController {
    
    if([component conformsToProtocol:@protocol(MFUIComponentProtocol)]) {
        [(id<MFUIComponentProtocol> )component setCellContainer:self];
    }
    
    //Récupération de la bindingKey et paramétrage du composant
    NSString *bindingKey = ((MFFieldDescriptor *) component.selfDescriptor).bindingKey;
    [component setForm:(id<MFComponentChangedListenerProtocol>)formController];
    [component setComponentInCellAtIndexPath:self.cellIndexPath];
    
    //Enregistrement du composant dans le binding
    NSArray *newRegisteredComponents = [formController.binding registerComponents:@[component] atIndexPath:self.cellIndexPath withBindingKey:bindingKey];
    
    //On retourne le résultat
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
    if(newRegisteredComponents) {
        resultDictionary = [[NSDictionary dictionaryWithObject:newRegisteredComponents forKey:bindingKey] mutableCopy];
    }
    return resultDictionary;
}



-(void) registerBindablePropertiesFromComponent:(id<MFUIComponentProtocol>) component
                      toPropertiesBindingOnForm:(id<MFBindingFormDelegate>) formController {
    
    MFFieldDescriptor *componentDescriptor = ((MFFieldDescriptor *) component.selfDescriptor);
    // On parcourt la liste des propriétés candidates au propertyBinding.
    // Cette liste de propriétés bindables est définie dans le Framework.plist
    for(NSString *bindableProperty in [formController.bindableProperties allKeys]) {
        
        NSString *bindablePropertyValue = [componentDescriptor valueForKey:bindableProperty];
        if(bindablePropertyValue) {
            
            //Si la valeur de la propriété bindable est correcte
            if([self isBindablePropertyValueCorrect:bindablePropertyValue forProperty:bindableProperty fromFormController:formController]) {
                
                // Récupération des champs actuellement bindés à cette propriété
                NSMutableDictionary * registeredComponentsForThisProperty = [formController.propertiesBinding objectForKey:bindablePropertyValue];
                
                //S'il n'y en a pas on crée un nouveau dictionnaire
                if(!registeredComponentsForThisProperty) {
                    registeredComponentsForThisProperty = [NSMutableDictionary dictionary];
                }
                
                if(bindableProperty && componentDescriptor) {
                    MFBindingComponentDescriptor * bindingDescriptor = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_BINDING_COMPONENT_DESCRIPTOR];
                    bindingDescriptor.bindableProperty = bindableProperty;
                    bindingDescriptor.componentDescriptor = componentDescriptor;
                    
                    [registeredComponentsForThisProperty setObject:bindingDescriptor forKey:componentDescriptor.name];
                }
                
                [formController.propertiesBinding setObject:registeredComponentsForThisProperty forKey:bindablePropertyValue];
            }
        }
    }
}



-(BOOL) isBindablePropertyValueCorrect:(NSString *) valueOfBindableProperty forProperty:(NSString *) property fromFormController:(id<MFBindingFormDelegate>) formController{
    BOOL result = YES;
    
    NSArray * listOfAuthorizedValue = [[[formController.bindableProperties objectForKey:property]  objectForKey:MFATTR_RECOGNIZED_VALUES ] componentsSeparatedByString:@";"];
    
    if([listOfAuthorizedValue containsObject:valueOfBindableProperty])
        result = NO;
    
    return result;
}

-(void)unregisterComponents:(id<MFBindingFormDelegate>)formController {
    for( MFFieldDescriptor *fieldDesc in self.groupDescriptor.fields) {
        [formController.binding unregisterComponentsAtIndexPath:self.cellIndexPath withBindingKey:fieldDesc.bindingKey];
    }
}


#pragma mark - MFUITransitionDelegate implementation

-(void) setTransitionDelegate:(id<MFUITransitionDelegate>)transitionDelegate
{
    //A voir ce qu'il faut mettre ici
}

-(id<MFUITransitionDelegate>) transitionDelegate
{
    //A voir ce qu'il faut mettre ici
    return nil;
}

-(void)viewIsConfigured {
    //Nothing to do here
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end





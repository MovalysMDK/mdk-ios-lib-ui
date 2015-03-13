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
//  MFCellAbstract.m
//  MFUI
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFApplication.h>

#import "MFCellAbstract.h"
#import "MFApplication.h"
#import "MFUIBaseComponent.h"
#import "MFException.h"
#import "MFVersionManager.h"

@interface MFCellAbstract()


@end

@implementation MFCellAbstract

// Synthesizing protocols properties (Auto synthesizing will not work for protocol properties)
@synthesize transitionDelegate = _transitionDelegate;
@synthesize formDescriptor = _formDescriptor;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize formController = _formController;
@synthesize hasChanged = _hasChanged;
@synthesize defaultConstraints = _defaultConstraints;


#pragma mark - Initializing
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reportConstraintsOnCellContentView];
}


-(void)reportConstraintsOnCellContentView {
    NSMutableArray *allConstraints = [NSMutableArray array];
    // For each constraint applied to this cell from the Storyboard, we remove it and apply it to the
    // the contentView of the cell.
    for (NSLayoutConstraint *cellConstraint in self.constraints)
    {
        [self removeConstraint:cellConstraint];
        
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        
        NSLayoutConstraint* contentViewConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                                 attribute:cellConstraint.firstAttribute
                                                                                 relatedBy:cellConstraint.relation
                                                                                    toItem:seccondItem
                                                                                 attribute:cellConstraint.secondAttribute
                                                                                multiplier:cellConstraint.multiplier
                                                                                  constant:cellConstraint.constant];
        
        [allConstraints addObject:contentViewConstraint];
    }

    [self.contentView addConstraints:allConstraints];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Construction et initialisation
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}


-(void) initialize {
    self.hasChanged = NO;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.mf = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_FORM_EXTEND];
//    self.contentView.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    for( NSString *fieldName in self.groupDescriptor.fieldNames) {
        MFUIBaseComponent *component = [self valueForKey:fieldName];
        [component setSelected:selected];
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
    
    //Comparaison du groupDescriptor actuel avec celui passé en paramètre.
    if(![self.groupDescriptor.name isEqual:groupDescriptor.name])
    {
        self.hasChanged = YES;
    }
    
    self.hasChanged = YES;
    // Cell
    self.groupDescriptor = groupDescriptor;
    
    for( MFFieldDescriptor *fieldDesc in self.groupDescriptor.fields) {
        id<MFUIComponentProtocol> field =  [self valueForKey:fieldDesc.cellPropertyBinding];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [((MFUIBaseComponent *)field) setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
        field.localizedFieldDisplayName = groupDescriptor.getFieldDescriptorLabel.getLabel;
        // Descriptor
        field.selfDescriptor = fieldDesc;
        //        field.formDescriptor = formDescriptor;
        field.groupDescriptor = groupDescriptor;
        
    }
    self.formDescriptor = formDescriptor;
    
}

-(void) cellIsConfigured {
    //Nothing to do here/
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
        id<MFUIComponentProtocol> field = [self valueForKey:fieldName];
        if ( field != nil) {
            [returnDictionary addEntriesFromDictionary:[self addComponent:field
                                                          toBindingOnForm:formController]];
            [self registerBindablePropertiesFromComponent:field
                                toPropertiesBindingOnForm:formController];
        }
    }
    
    return returnDictionary;
}

-(NSDictionary *) addComponent:(id<MFUIComponentProtocol>) component
               toBindingOnForm:(id<MFBindingFormDelegate>) formController {
    NSDictionary *result = [NSDictionary dictionary];
    if(component) {
        if([component isKindOfClass:[MFUIBaseComponent class]]) {
            [(MFUIBaseComponent *)component setCellContainer:self];
        }
        
        //Récupération de la bindingKey et paramétrage du composant
        NSString *bindingKey = ((MFFieldDescriptor *) component.selfDescriptor).bindingKey;
        [component setForm:(id<MFComponentChangedListenerProtocol>)formController];
        [component setComponentInCellAtIndexPath:self.cellIndexPath];
        
        //Enregistrement du composant dans le binding
        NSArray *newRegisteredComponents = [formController.binding registerComponents:@[component] atIndexPath:self.cellIndexPath withBindingKey:bindingKey];
        
        //On retourne le résultat
        if(newRegisteredComponents) {
            result = [NSDictionary dictionaryWithObject:newRegisteredComponents forKey:bindingKey];
        }
    }
    return result;
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

-(void) refreshComponents {
    for( NSString *fieldName in self.groupDescriptor.fieldNames) {
        MFUIBaseComponent * component = [self valueForKey:fieldName];
        [component setData:nil];
    }
}



@end


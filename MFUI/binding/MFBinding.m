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
//  MFBinding.m
//  MFUI
//


//Main interface
#import "MFBinding.h"

//Helpers
#import "MFHelperIndexPath.h"

//Components
#import "MFUIBaseComponent.h"
#import  <MFCore/MFCoreError.h>
#import "MFUILogging.h"

@interface MFBinding()

/**
 * @brief The dictionnary used to bind ViewModels and components.
 * The binding is a 2 levels dictionary
 *
 * A dictionary that uses as key/value pair
 * "key" : the indexpath of the cell we want to binds components
 * "value' : a dictionary.
 *
 * That second dictionary uses as key/value pair :
 * "key" : the bindingKey of a component
 * "value" : the component
 */
@property (nonatomic, strong) NSMutableDictionary *binding;

@end

@implementation MFBinding


#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self) {
        self.binding = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Manage binding

-(void)clear {
    [self.binding removeAllObjects];
}

-(NSDictionary *) componentsDictionaryAtIndexPath:(NSIndexPath *)indexPath {
    indexPath = [self indexPathForCurrentBindingModeFromIndexPath:indexPath];
    NSDictionary *componentsDictionary = [self.binding objectForKey:[MFHelperIndexPath toString:indexPath]];
    return componentsDictionary;
}

-(NSArray *) componentsArrayAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *componentsList = [NSMutableArray array];
    NSDictionary *componentsDictionary = [self componentsDictionaryAtIndexPath:indexPath];
    for(NSString *key in componentsDictionary.allKeys) {
        NSArray *componentsListForKey = (NSArray *)[componentsDictionary objectForKey:key];
        if(componentsListForKey) {
            componentsList = [[componentsList arrayByAddingObjectsFromArray:componentsListForKey] mutableCopy];
        }
    }
    return componentsList;
}

-(NSArray *) componentsAtIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey {
    indexPath = [self indexPathForCurrentBindingModeFromIndexPath:indexPath];
    NSDictionary *indexPathComponents = [self componentsDictionaryAtIndexPath:indexPath];
    NSArray *componentsForBindingKey= nil;
    if(indexPathComponents) {
        componentsForBindingKey = [indexPathComponents objectForKey:bindingKey];
    }
    return componentsForBindingKey;
}

-(NSArray *) componentsWithBindingKey:(NSString *)bindingKey {
    NSArray *registeredComponents = nil;
    if(self.bindingMode == MFBindingModeForm) {
        registeredComponents = [self componentsAtIndexPath:nil withBindingKey:bindingKey];
    }
    else {
        registeredComponents = nil;
        [MFException throwExceptionWithName:@"Binding mode error" andReason:@"The method \"(NSArray *) componentsWithBindingKey:(NSString *)bindingKey\" must not be called in MFBindingModeList mode" andUserInfo:nil];
    }
    return registeredComponents;
}

-(NSArray *) registerComponents:(NSArray *)componentList atIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey {
    //Récupération des composants déja enregistrés pour ce binding
    if ([bindingKey isEqualToString:@"AgencyPanel-agencypanel-notation-label"]) {
        MFUILogInfo(@"bindingKey: %@", bindingKey);
    }
    indexPath = [self indexPathForCurrentBindingModeFromIndexPath:indexPath];
    NSMutableArray *registeredComponents = [[self componentsAtIndexPath:indexPath withBindingKey:bindingKey] mutableCopy];
    NSMutableArray *componentsToRegister = [componentList mutableCopy];
    if(!componentsToRegister) {
        return @[];
    }
    
    //S'il y a déja des composant enregistrés pour ce binding
    if(registeredComponents) {
        //On élimine les doublons à enregistrer
        for(MFUIBaseComponent *component in componentList) {
            if([registeredComponents containsObject:component]) {
                [componentsToRegister removeObject:component];
            }
        }
        //On ajoute les nouveaux composants à enregistrer dans ce binding
        registeredComponents = [[registeredComponents arrayByAddingObjectsFromArray:componentsToRegister] mutableCopy];
    }
    else {
        registeredComponents = componentsToRegister;
    }
    
    //Avant d'ajouter les composants au binding, on vérifie si des composants on déja été ajoutés pour cet indexPath
    NSMutableDictionary *registeredComponentAtIndexPath = [[self componentsDictionaryAtIndexPath:indexPath] mutableCopy];
    if(!registeredComponentAtIndexPath) {
        //S'il n'y avait pas de composants enregistrés pour cet indexPath on crée un nouveau dictionnaire pour cet indexPath
        registeredComponentAtIndexPath = [NSMutableDictionary dictionary];
    }
    //On ajoute au dictionnaire les nouveaux composants à enregistrer
    [registeredComponentAtIndexPath setObject:registeredComponents forKey:bindingKey];
    
    //On ajoute au binding les nouveaux composants à enregistrer avec l'indexPath et la bindingKey spécifiés.
    [self.binding setObject:registeredComponentAtIndexPath forKey:[MFHelperIndexPath toString:indexPath]];
    
    return componentsToRegister;
}

-(void) unregisterComponentsAtIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey {
    if(self.bindingMode == MFBindingModeForm) {
        if(bindingKey) {
            [self unregisterComponentsWithBindingKey:bindingKey];
        }
    }
    else {
        if(indexPath) {
            [self.binding removeObjectForKey:[MFHelperIndexPath toString:indexPath]];
        }
    }
}




#pragma mark - Private methods

/**
 * @brief Returns an indexPath following the current bindingMode,
 * @param indexPath The original indexPath
 * @return An indexPath that depends on the current BindingMode
 */
-(NSIndexPath *) indexPathForCurrentBindingModeFromIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *bindingModeIndexPath = indexPath;
    //Si on est dans un formulaire, on enregistre tout les composants sous le même indexPath
    if(!bindingModeIndexPath || self.bindingMode == MFBindingModeForm) {
        bindingModeIndexPath = [NSIndexPath indexPathForItem:NSIntegerMax inSection:NSIntegerMax];
    }
    return bindingModeIndexPath;
}


-(void) unregisterComponentsWithBindingKey:(NSString *)bindingKey {
    if(self.bindingMode == MFBindingModeForm) {
        NSMutableDictionary *allRegisteredComponents = [[self componentsDictionaryAtIndexPath:[self indexPathForCurrentBindingModeFromIndexPath:nil]] mutableCopy];
        [allRegisteredComponents removeObjectForKey:bindingKey];
        [self.binding setObject:allRegisteredComponents forKey:[MFHelperIndexPath toString:[self indexPathForCurrentBindingModeFromIndexPath:nil]]];
    }
    else {
        [MFException throwExceptionWithName:@"Binding mode error" andReason:@"The method \"(void) unregisterComponentsWithBindingKey:(NSString *)bindingKey\" must not be called in MFBindingModeList mode" andUserInfo:nil];
    }
}


@end

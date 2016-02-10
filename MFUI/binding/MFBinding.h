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
//  MFBinding.h
//  MFUI
//
//



/**
 * @brief This structure defines the mode of the binding
 * MFBindingModeForm : The binding will register all components in with a fake indexPath [0;0]
 * MFBindingModeList : The binding will register all components with thier given binding and indexPath
 */
typedef enum {
    MFBindingModeForm = 0,
    MFBindingModeList =1
} MFBindingMode;



@interface MFBinding : NSObject

#pragma mark - Properties

/**
 * Defines the current binding mode.
 * The values must be : 
 * MFBindingModeForm : The binding binds components of a simple form. All the binding will be in a dictionary pointed with a fake indexpath.
 * MFBindingModeList : The binding is classic (A dictionary for the indexPath, another one for the bindingKeys).
 */
@property (nonatomic) MFBindingMode bindingMode;


#pragma mark - Methods

/**
 * @brief Returns a dictionary of binded components for a given indexPath
 * @param indexPath The indexPath of the binded cell or view we want to retrieve components
 * @return A dictionary of binded components for the given indexPath or nil if no components have already been registered
 * for this indexPath
 */
-(NSDictionary *) componentsDictionaryAtIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief Returns an array of binded components for a given indexPath
 * @param indexPath The indexPath of the binded cell or view we want to retrieve components
 * @return An array of binded components for the given indexPath or nil if no components have already been registered
 * for this indexPath
 */
-(NSArray *) componentsArrayAtIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief Returns  an array of binded components given by their cellContainer indexPath and  binding key
 * @param indexPath The indexPath of the binded cell or view we want to retrieve components
 * @param bindingKey The binding key of the components to retrieve
 * @return Binded components for the given indexPath and bindingKey, or nil if no components have already been registered
 * for this bindingKey or indexPath
 */
-(NSArray *) componentsAtIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey;

/**
 * @brief Returns  an array of binded components given by thier binding key. This method must be used in MFBindingModeForm ONLY.
 * @param bindingKey The binding key of the components to retrieve
 * @return Binded components for the given bindingKey, or nil if no components have already been registered
 * for this bindingKey
 */
-(NSArray *) componentsWithBindingKey:(NSString *)bindingKey;

/**
 * @brief Registers a an array of components with given indexPath and bindingKeys
 * @param componentList The list of components to register in the binding
 * @param indexPath The indexPath used to register the components in the binding
 * @param bindingKey The bindingKey to use to register the components in the binding
 * @return The list of the new registered components. This list could be different of the given "componentList" if some of
 * components were alreadey registered in the binding.
 */
-(NSArray *) registerComponents:(NSArray *)componentList atIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey;


/**
 * @brief Removes all registered components from the binding for a specified indexPath or bindingKey
 * @param indexPath The indexPath we will remove components
 * @param bindingKey The bindingKey we will remove components
 */
-(void) unregisterComponentsAtIndexPath:(NSIndexPath *)indexPath withBindingKey:(NSString *)bindingKey;

/**
 * @brief Remove all objects in the binding
 */
-(void) clear;


@end

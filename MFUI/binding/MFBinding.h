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

#import <Foundation/Foundation.h>
#import "MFBindingDictionary.h"

@class MFOneWayBindingValue;
@class MFBindingValue;
@class MFAbstractComponentWrapper;


/*!
 * @class MFBinding
 * @brief This class is the main structure of binding. It is used each time a controller, a component
 * or another object need binding.
 * @discussion It registers binding pairs called MFBindingValue in 3 different dictionaries : 
 * The first one sort binding values on ViewModel properties name, the second on components hash
 * and the third on cell string-format binding keys.
 * @discussion This structure is necessary to get binding values faster following the object
 * that needs it to do the binding.
 * @see MFBindingValue
 */
@interface MFBinding : NSObject

#pragma mark - Properties
/*!
 * @brief The dictionary that sort binding values of the binding on ViewModel properties names.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *bindingByViewModelKeys;

/*!
 * @brief the dictionary that sort binding values on components hash
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *bindingByComponents;

/*!
 * @brief The binding dictionary that sort binding values on cell string-format binding keys
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *bindingByBindingKeys;

#pragma mark - Methods

/*!
 * @brief Register a new binding value
 * @discussion The binding value is registered in the 2 first dictionaries 
 * (by ViewModel properties names and by component hash)
 * @param bindingValue the new Binding value to register
 */
-(void) registerBindingValue:(MFBindingValue *)bindingValue;

/*!
 * @brief Register a new binding value
 * @discussion The binding value is registered in the 3 dictionaries
 * @param bindingValue the new Binding value to register
 * @param bindingKey The cell string-format binding key to use to register the given binding value
 */
-(void) registerBindingValue:(MFBindingValue *)bindingValue forBindingKey:(NSString *)bindingKey;

/*!
* @brief Clears a binding value following the given cell string-format binding key
* @discussion The binding value is removed from all dictionarires
* @param bindingKey A cell string-format binding key
*/
-(void) clearBindingValuesForBindingKey:(NSString *)bindingKey;

/*!
 * @brief Clears a binding value following the given component has
 * @discussion The binding value is removed from all dictionarires
 * @param bindingKey An existing component hash
 */
-(void) clearBindingValuesForComponentHash:(NSNumber *)componentHash;

@end





/*!
 * @class MFBindingValue
 * @brief An object that represents a binding value
 */
@interface MFBindingValue : NSObject

#pragma mark - Properties
/*!
 * @brief The indexPath to the component to bind.
 * @brief A component has not direclty an indexPath property, but it is considered that a component
 * has the same indexPath that the cell that declare it. If the component is not in a cell (like in 
 * NoTableView forms), MDK iOS generates a fake indexPath for this component.
 */
@property (nonatomic, strong) NSIndexPath *bindingIndexPath;

/*!
 * @brief The property name of the component to bind
 */
@property (nonatomic, strong) NSString *componentBindedPropertyName;

/*!
 * @brief The wrapper of the component to bind
 */
@property (nonatomic, strong) MFAbstractComponentWrapper *wrapper;

/*!
 * @brief The binding mode for this binding value
 */
@property (nonatomic) MFBindingValueMode bindingMode;

/*!
 * @brief The View Model property name to bind
 */
@property (nonatomic, strong) NSString *abstractBindedPropertyName;

/*!
 * @brief The component outlet name to bind
 */
@property (nonatomic, strong) NSString *componentOutletName;

/*!
 * @brief The source of binding
 */
@property (nonatomic) MFBindingSource bindingSource;

#pragma mark - Methods

/*!
 * @brief Initializes a new binding filled with the given parameters and returns it to the caller
 * @param componentWrapper The wrapper of the component to bind
 * @param bindingMode The binding mode that is used for this binding value
 * @param vmBindedPropertyName the View Model property name to bind to a component
 * @param componentOutletName The Outlet name of the component to bien
 * @return The new MFOneWayBindingValue built instance
 */
-(instancetype) initWithWrapper:(MFAbstractComponentWrapper *)componentWrapper withBindingMode:(MFBindingValueMode)bindingMode withVmBindedPropertyName:(NSString *)vmBindedPropertyName withComponentOutletName:(NSString *)componentOutletName fromSource:(MFBindingSource)bindingSource;

/*!
 * @brief Initializes a new binding filled with the given parameters and returns it to the caller
 * @param componentWrapper The wrapper of the component to bind
 * @param bindingMode The binding mode that is used for this binding value
 * @param vmBindedPropertyName the View Model property name to bind to a component
 * @param componentBindedPropertyName The property name of the component to bind
 * @param componentOutletName The Outlet name of the component to bien
 * @return The new MFOneWayBindingValue built instance
 */
-(instancetype) initWithWrapper:(MFAbstractComponentWrapper *)componentWrapper withBindingMode:(MFBindingValueMode)bindingMode withVmBindedPropertyName:(NSString *)vmBindedPropertyName withComponentBindedPropertyName:(NSString *)componentBindedPropertyName withComponentOutletName:(NSString *)componentOutletName fromSource:(MFBindingSource)bindingSource;

@end
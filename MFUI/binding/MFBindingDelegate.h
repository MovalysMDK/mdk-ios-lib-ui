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
#import "MFBinding.h"

@protocol MFObjectWithBindingProtocol;


/*!
 * @class MFBindingDelegate
 * @brief The delegate of binding. This object manages all the binding for the object that uses it.
 * @discussion Each object that needs a binding must use this object.
 */
@interface MFBindingDelegate : NSObject

#pragma mark - Properties
/*!
 * @brief A dictionary that represents the structure of the object that needs binding. 
 * @discussion It used to convert the form components into a binding structure.
 */
@property (strong, nonatomic) NSMutableDictionary *structure;

#pragma mark - Initialization

/*!
 * @brief Initializes a new binding delegate and returns it to the caller
 * @param object The object that needs binding and that must conform to the MFObjectWithBindingProtocol protocol
 * @return The new MFBindingDelegate built instance
 * @see MFObjectWithBindingProtocol
 */
-(instancetype) initWithObject:(id<MFObjectWithBindingProtocol>)object;


#pragma mark - Register for Form
/*!
 * @brief Registers a new binding value filled with the given parameters in the binding structure 
 * and returns it to the caller
 * @param componentBindingProperty The property name of the component to bind
 * @param viewModelProperty The ViewModel property name to bind
 * @param component The component to bind
 * @param outletName The  outlet name of the component to bind
 * @param bindingMode The binding mode of the new binding value to create
 * @return The new created binding value filled with the given parameters
 */
-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode fromBindingSource:(MFBindingSource)bindingSource;

/*!
 * @brief Registers a new binding value filled with the given parameters in the binding structure
 * and returns it to the caller
 * @param componentBindingProperty The property name of the component to bind
 * @param viewModelProperty The ViewModel property name to bind
 * @param component The component to bind
 * @param outletName The  outlet name of the component to bind
 * @param bindingMode The binding mode of the new binding value to create
 * @param bindingKey The cell string-format binding key of the component to bind
 * @return The new created binding value filled with the given parameters
 */
-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode withBindingKey:(NSString *)bindingKey fromBindingSource:(MFBindingSource)bindingSource;


#pragma mark - Register for FormList

//For List
/*!
 * @brief Registers a new binding value filled with the given parameters in the binding structure
 * and returns it to the caller
 * @param componentBindingProperty The property name of the component to bind
 * @param viewModelProperty The ViewModel property name to bind
 * @param component The component to bind
 * @param outletName The  outlet name of the component to bind
 * @param bindingMode The binding mode of the new binding value to create
 * @param bindingKey The cell string-format binding key of the component to bind
 * @param indexPath The fictive indexPath to the component to bind
 * @return The new created binding value filled with the given parameters
 */
-(MFBindingValue *) registerComponentBindingProperty:(NSString *)componentBindingProperty withViewModelProperty:(NSString *) viewModelProperty forComponent:(UIView *)component withOutletName:(NSString *)outletName withMode:(MFBindingValueMode)bindingMode withBindingKey:(NSString *)bindingKey withIndexPath:(NSIndexPath *)indexPath fromBindingSource:(MFBindingSource)bindingSource;


#pragma mark - Binding accessors

/*!
 * @brief Returns the complete structure of binding
 * @return The complete structure of binding
 */
-(MFBinding *) binding;

/*!
 * @brief Returns an array containing the binding values associated to the given cell 
 * string-format bindingKey
 * @param cellBindingKey A cell string-format unique bindingKey
 * @return An array containing all the binding values for the given bindingKey
 */
-(NSArray *) bindingValuesForCellBindingKey:(NSString *)cellBindingKey;

/*!
 * @brief Returns all the binding values registered in the binding structure
 * @return An array containing all the binding values registered in the binding structure
 */
-(NSArray *) allBindingValues;

@end

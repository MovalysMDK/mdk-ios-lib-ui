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
@class MFBindingDictionary;

FOUNDATION_EXPORT NSString *BINDING_ONE_WAY_LEFT_RIGHT_SYMBOL;
FOUNDATION_EXPORT NSString *BINDING_ONE_WAY_RIGHT_LEFT_SYMBOL;
FOUNDATION_EXPORT NSString *BINDING_TWO_WAYS_SYMBOL;

FOUNDATION_EXPORT NSString *BINDING_VIEWMODEL_PROPERTY_PREFIX;
FOUNDATION_EXPORT NSString *BINDING_COMPONENT_PROPERTY_PREFIX;
FOUNDATION_EXPORT NSString *BINDING_OUTLET_PREFIX;

/*!
 * @typedef MFBindingValueMode
 * @brief Describes the binding mode : one-way or two-ways
 * @constant MFBindingValueModeOneWay Value that describes One-Way binding mode (ViewModel --> Form)
 * @constant MFBindingValueModeTwoWays  Value that describes Two-Ways binding mode (ViewModel <--> Form)
 */
typedef NS_ENUM(NSInteger, MFBindingValueMode) {
    MFBindingValueModeOneWay,
    MFBindingValueModeTwoWays
};


/*!
 * @typedef MFBindingSource
 * @brief Describes the binding source : viewModel or Strings files
 * @constant MFBindingSourceViewModel The value comes from ViewModel
 * @constant MFBindingSourceStrings  The value comes from Strings localized files
 */
typedef NS_ENUM(NSInteger, MFBindingSource) {
    MFBindingSourceViewModel,
    MFBindingSourceStrings
};




/************************************************************/
/* MFBindingConsistencyProtocol                             */
/************************************************************/

#pragma mark - MFBindingConsistencyProtocol
/*!
 * @protocol MFBindingCellDescriptor
 * @brief A protocol that declares some methods allowing to check the binding object consistency
 */
@protocol MFBindingConsistencyProtocol

/**
 * @brief Required method that checks and return the consistency of the implemented object
 * @return YES is the object is consistent, NO otherwhise.
 */
-(BOOL) isConsistent;

@end




/************************************************************/
/* MFBindingDescriptor                                      */
/************************************************************/

#pragma mark - MFBindingDescriptor

/*!
 * @class MFBindingDescriptor
 * @brief A descriptor used to describe a binding pair key/value object
 * @discussion The descriptor own a property that represents the view model property to bind to another property,
 * that representents a bindable component property (as backgroundColor, value ...), and a value that indicates
 * the binding mode
 */
@interface MFBindingDescriptor : NSObject <MFBindingConsistencyProtocol>

#pragma mark Initialization
/*!
 * @brief Initializes a binding descriptor with a binding format, and return the built instance to the caller.
 * @param format A specific MFK iOS binding format that indicates a component property, a ViewModel property, and the binding mode between those properties.
 * @return The built instance of MFBindingDescriptor
 */
+(instancetype) bindingDescriptorWithFormat:(NSString *)format;

#pragma mark Properties

/*!
 * @brief A component property name (like "text", or "value" ...)
 */
@property (nonatomic, strong) NSString *componentProperty;

/*!
 * @brief A view model property name (like "firstname", "birthdate" ...)
 */
@property (nonatomic, strong) NSString *viewModelProperty;

/*!
 * @brief A view model property name (like "firstname", "birthdate" ...)
 */
@property (nonatomic, strong) NSString *i18nKey;

/*!
 * @brief A MFBindingValueMode value that indicates the binding mode.
 * @see MFBindingValueMode
 */
@property (nonatomic) MFBindingValueMode bindingMode;

#pragma mark Methods

/*!
 * @brief Returns the binded property
 * @discussion This could be a property from a ViewModel, a Strings file...
 * @return The binded property
 */
-(NSString *)abstractBindedProperty;

/*!
 * @brief Returns the source of binding
 * @return The source of binding
 */
-(MFBindingSource)bindingSource;

@end



/************************************************************/
/* MFOutletBindingKey                                       */
/************************************************************/


#pragma mark - MFOutletBindingKey

/**
 * @class MFOutletBindingKey
 * @brief A key object for MFBindingDictionary that represents an existing outlet name
 */
@interface MFOutletBindingKey : NSObject <MFBindingConsistencyProtocol, NSCopying>


#pragma mark Initialization
/*!
 * @brief Initializes an outlet binding-key with the specified name and return the built object to the caller
 * @param outletName The name of the outlet used as binding-key object
 * @return A new instance of MFOutletBindingKey
 */
+(instancetype) bindingKeyForOutletName:(NSString *)outletName ;

#pragma mark Properties
/*!
 * @brief An outlet name that describes this object
 */
@property (nonatomic, strong) NSString *outletName;

@end



/************************************************************/
/* MFBindingDictionary                                      */
/************************************************************/


#pragma mark - MFBindingDictionary
/*!
 * @class MFBindingDictionary
 * @brief This class describes a binding at the dictionary format.
 * @discussion This class is not an instance of NSdictionary but works like a standard dictionary.
 * @discussion It is used by an object to describe the MDK iOS binding between a component property
 * and a ViewModel Property.
 * @discussion This specific dictionary takes a MFOutletBindingKey as key and a MFBindingDescriptor 
 * object as the value.
 * @see MFOutletBindingKey, MFBindingDescriptor
 */
@interface MFBindingDictionary : NSObject

#pragma mark Initializing
/*!
 * @brief Initializes an empty binding dictionary and returns it to the caller
 * @return The built instance of binding dictionary
 */
+(instancetype) bindingDictionary;

/*!
 * @brief Initializes an empty binding dictionary filled following the given format
 * @discussion The format is described in MDK iOS documentation.
 * @param bindingFormat,... A variadic paramter that represents a list of formatted-string. You should terminate
 * the declaration with nil to indicated the end of the declaration.
 * @return The built instance of a filled binding dictionary
 */
+(instancetype) bindingDictionaryFromFormat:(NSString *)bindingFormat, ... NS_REQUIRES_NIL_TERMINATION;


#pragma mark Manage Binding Structure
/*!
 * @brief Add a MFBindingDescriptor value object for the MFOutletBindingKey key object to the binding dictionary
 * @param bindingDescriptor The binding descriptor to add in the binding dictionary
 * @param outletBindingKey The key used to add the binding descriptor
 */
-(void) addBindingDescriptor:(MFBindingDescriptor *)bindingDescriptor forOutletBindingKey:(MFOutletBindingKey *)outletBindingKey;

#pragma mark Subscripting
/*!
 * @brief Method used to simplify the dictionary values access with the notation []
 * @discussion You should never call this method directly
 * @param key The key used to retrieve a value like in a NSDictionary
 * @return An object corresponding to the given key
 */
- (id)objectForKeyedSubscript:(id)key;

/*!
 * @brief Method used to simplify the dictionary values access with the notation []
 * @discussion You should never call this method directly
 * @param obj The objectto set for the given key like in a NSDictionary
 * @param key The key used to retrieve a value like in a NSDictionary
 */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

#pragma mark Dictionary
/*!
 * @brief Returns all the keys of the binding dictionary
 * @return An array containing all the keys as MFOutletBindingKey objects of the binding dictionary
 * @see MFOutletBindingKey
 */
-(NSArray *) allKeys;

/*!
 * @brief Returns all the values of the binding dictionary
 * @return An array containing all the keys as MFBindingDescriptor objects of the binding dictionary
 * @see MFBindingDescriptor
 */
-(NSArray *) allValues;

@end





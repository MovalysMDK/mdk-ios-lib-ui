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

FOUNDATION_EXPORT NSString *BINDING_FORMAT_ATTRIBUTE_CAST_STRING;
FOUNDATION_EXPORT NSString *BINDING_FORMAT_ATTRIBUTE_CAST_INTEGER;
FOUNDATION_EXPORT NSString *BINDING_FORMAT_ATTRIBUTE_CAST_FLOAT;
FOUNDATION_EXPORT NSString *BINDING_FORMAT_ATTRIBUTE_CAST_BOOL;

FOUNDATION_EXPORT NSString *BINDING_FORMAT_TYPE_BINDING;
FOUNDATION_EXPORT NSString *BINDING_FORMAT_TYPE_ATTRIBUTES;
FOUNDATION_EXPORT NSString *BINDING_FORMAT_TYPE_ASSOCIATED_LABEL;

/*!
 * @class MFBindingFormatParser
 * @brief This parser is used to parse binding formats
 */
@interface MFBindingFormatParser : NSObject

/*!
 * @brief Builds and returns a control attributes dictionary from a variadic list of binding formats
 * @param controlAttributes The dictionary to fill
 * @param valist The list of binding format to parse
 * @param firstArg The first binding format to parse
 * @return A dictionary that contains control attributes
 */
+(NSDictionary *)buildControlsAttributesDictionary:(NSDictionary *)controlAttributes fromVaList:(va_list)valist withFirstArg:(NSString *)firstArg;

/*!
 * @brief Builds and returns a bindingDictionary dictionary from a variadic list of binding formats
 * @param valist The list of binding format to parse
 * @param firstArg The first binding format to parse
 * @return A new binding dictionary
 * @see MFBindingDictionary
 */
+(MFBindingDictionary *) bindingDictionaryFromVaList:(va_list)args withFirstArg:(NSString *) firstArg;

/*!
 * @brief Builds and returns a associated labels dictionary from a variadic list of binding formats
 * @param controlAttributes The dictionary to fill
 * @param valist The list of binding format to parse
 * @param firstArg The first binding format to parse
 * @return A dictionary that contains associations labels/controls
 */
+(NSDictionary *)buildAssociatedLabelsDictionary:(NSDictionary *)associatedLabels fromVaList:(va_list)args withFirstArg:(NSString *)firstArg;
@end

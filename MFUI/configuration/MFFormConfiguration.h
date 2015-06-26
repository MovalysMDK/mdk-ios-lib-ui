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
#import "MFBindingViewDescriptor.h"

@protocol MFObjectWithBindingProtocol;

/*!
 * @class MFFormConfiguration
 * @brief This class allows to create a configuration for MDK NoTableView-form
 * @discussion You should always use a MFFormConfiguration to configure your MDK ViewController
 * that does not present a UITableView
 */
@interface MFFormConfiguration : NSObject

#pragma mark - Initialization
/*!
 * @brief Initializes a form configuration instance with the specified object with binding and 
 * returns it to the caller.
 * @param objectWithBinding An object with binding that conforms the MFObjectWithBindingProtocol protocol
 * @return The MFFormConfiguration built instance
 * @see MFObjectWithBindingProtocol
 */
+(instancetype) createFormConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>) objectWithBinding;

#pragma mark - Configuration
/*!
 * @brief Fill the configuration with the specified vies descriptor
 * @param viewDescriptor A view descriptor that describes the form configured by this object
 * @see MFBindingDictionary
 */
-(void)createFormConfigurationWithViewDescriptor:(MFBindingViewDescriptor *)viewDescriptor;

@end

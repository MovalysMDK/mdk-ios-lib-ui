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

/*!
 * @protocol MFComponentBindingProtocol
 * @brief This protocol defines the necessary methods and properties for a MDK component
 * to be binded by the framework (to a View Model property). For example, a Text Field 
 * component will generally be binded to a NSString property on a View Model.
 * @discussion
 */
@protocol MFComponentBindingProtocol <NSObject>

#pragma mark - Properties
/*!
 * @brief The data that is managed by the component.
 */
@property (nonatomic, strong) id privateData;

#pragma mark - Methods
/*!
 * @brief Set the data to the component
 * @param data The data to set to the component
 */
-(void)setData:(id)data;

/*!
 * @brief Get the data of the component
 * @return The data of the component
 * @discussion Be careful : depending on the component behaviour, the result
 * is not necessarily the visible data of the component. For example, an 
 * overloaded instance of a Text Field component could display "trois", but 
 * the result of this method could be "3".
 */
-(id)getData;


/*!
 * @brief Returns the data-type managed by the component
 * @return A string of the data-type managed by the component
 */
+ (NSString *) getDataType;



@end

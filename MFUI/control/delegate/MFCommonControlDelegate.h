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

@protocol MFUIComponentProtocol;
@protocol MFDescriptorCommonProtocol;

/*!
 * @class MFCommonControlDelegate
 * @brief The delegate that do some common treatments to all MDK controls
 */
@interface MFCommonControlDelegate : NSObject

#pragma mark - Methods

/*!
 * @brief Creates and returns a new instance of this class initialized with a component
 * @param control The control that will use this delegate
 * @return A news instance of this delegate class
 */
-(instancetype)initWithComponent:(UIView<MFUIComponentProtocol> *)component;

/*!
 * @brief Clears all the errros on the component
 */
-(void) clearErrors;

/*!
 * @brief Returns an array of the errors own that hold the component
 * @return An Array containing all the errors of the component
 */
-(NSMutableArray *) getErrors;

/*!
 * @brief Adds errors to the component
 * @param errors an array of errors to add on the component
 */
-(void)addErrors:(NSArray *)errors;

/*!
 * @brief Sets the validation state of the component
 * @param isValid The validation state of the component
 */
-(void)setIsValid:(BOOL)isValid;

/*!
 * @brief Does an action when the error button is clicked
 * @param sender The sender of the action
 */
-(void)onErrorButtonClick:(id)sender;

/*!
 * @brief Sets the visibility state of the component
 * @param visible The new visibility state og the component : @1 for visible, @0 for invisible
 */
-(void)setVisible:(NSNumber *)visible;

/*!
 * @brief Adds a control attribute for a given key to the component
 * @param controlAttribute The control attribute to add
 * @param key The key that identify the controlAttribute
 */
-(void)addControlAttribute:(id)controlAttribute forKey:(NSString *)key;

/*!
 * @brief Returns the validation states of the component
 * @return 0 if the component is valid, the number of errors on the component otherwhise.
 */
-(NSInteger)validate;
@end

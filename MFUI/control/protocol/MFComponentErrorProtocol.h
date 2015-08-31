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
#import "JDFTooltipView.h"

//FIXME: Doc
@protocol MFComponentErrorProtocol <NSObject>

#pragma mark - Properties

/*!
 * @brief The array of the errors of the component.
 */
@property (nonatomic, strong) NSMutableArray *errors;


/*!
 * @brief The tooltip displayed when the user taps on the buttonError of the errorView
 */
@property (nonatomic, strong) JDFTooltipView *tooltipView;

#pragma mark - Methods

/*!
 * @brief Clean all component errors
 */
-(void) clearErrors;

/*!
 * @brief Returns a array containing the error(s) of the component
 * @return  An array containing the error(s) of the component 
 */
-(NSArray *) getErrors;

/*!
 * @brief Adds an array of errors to the component
 * @param errors An array of errors 
 */
-(void) addErrors:(NSArray *) errors;

/*!
 * @brief Shows or hides the error view of the component
 * @param showError BOOL that is YES to show the error view, or NO to hide it.
 */
-(void) showError:(BOOL)showError;

@end

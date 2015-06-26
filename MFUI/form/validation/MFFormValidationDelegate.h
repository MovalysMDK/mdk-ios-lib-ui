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




FOUNDATION_EXPORT const int kDiscardChangesAlert;
FOUNDATION_EXPORT const int kSaveChangesAlert;

@class MFFormViewController;

@protocol MFUIComponentProtocol;
@protocol MFUIBaseViewModelProtocol;
@protocol MFCommonFormProtocol;

@interface MFFormValidationDelegate : NSObject

/*!
 * @brief The formViewController associated to this delegate
 */
@property (nonatomic, weak) id<MFCommonFormProtocol> formController ;

/*!
 * @brief A dictionary containing the list of invalid inputs
 */
@property (nonatomic, strong) NSMutableDictionary *invalidInputs ;

/*!
 * @brief A dictionary containing the errors for the invalid inputs
 */
@property (nonatomic, strong) NSMutableDictionary *errorForInvalidInputs ;

// validation error not reported on components because they are not yet instancied. 
@property (nonatomic, strong) NSMutableDictionary *deferredErrors ;


-(id) initWithFormController:(id<MFCommonFormProtocol>)formController ;



/*!
 * @brief validate viewmodel
 * @param vm viewmodel
 * @return true if viewmodel is valid
 */
-(BOOL) validateViewModel:(id<MFUIBaseViewModelProtocol>)vm ;


/*!
 * @brief Indicates if the current form validation delegate has invalid values
 * @return YES if the validation form delegate has invalid value(s), NO otherwhise.
 */
-(BOOL) hasInvalidValues;

/*!
 * @brief Reset all dictionaries used to validate
 */
-(void) resetValidation ;

@end

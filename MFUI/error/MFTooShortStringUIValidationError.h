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


/*!
 * Report a too short user data keyboarding.
 * An instance of this error type must be associated with a field name.
 **/

#import "MFUIValidationError.h"

@interface MFTooShortStringUIValidationError : MFUIValidationError

/*
 Specific error code.
 */
extern NSInteger const TOO_SHORT_STRING_UI_VALIDATION_ERROR_CODE;

/*
 Specific localized description key.
 */
extern NSString *const TOO_SHORT_STRING_UI_VALIDATION_ERROR_LOCALIZED_DESCRIPTION_KEY;

/*!
 * Init new instance.
 *
 * @param fieldName - Associated field name.
 * @return new instance of MFTooShortStringUIValidationError
 */
-(id)initWithLocalizedFieldName:(NSString *)fieldName technicalFieldName:(NSString *) technicalFieldName;

@end

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
//
//  MFBrowseUrlTextField.h
//  MFUI
//
//

#import "MFUIError.h"

#import "MFRegularExpressionTextField.h"

/*
 Use the platform browser to navigate to url.
 URL used is control's value.
 Prior to browse, this control checks control's value is a well formed URL.
 */
@interface MFBrowseUrlTextField : MFRegularExpressionTextField

/*
 Default phone number pattern used to validate user keyboarding data.
 */
extern NSString *const MFBUTF_DEFAULT_URL_PATTERN;

/*
 Default url used to call a phone number.
 */
extern NSString *const MFBUTF_DEFAULT_URL_TO_BROWSE_URL;

#pragma mark - Properties
/**
 * @brief The textfield background color
 */
@property (nonatomic, strong) UIColor *textFieldBackgroundColor;

@end

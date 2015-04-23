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
//  MFSendEmailTextField.h
//  MFUI
//
//

#import "MFUIError.h"

#import "MFRegularExpressionTextField.h"

/*
 Open a dialog to allow user to write an email.
 Destination adress email is this control's value.
 Before opening the new email dialog, this control checks control's value is a well formed email.
 */
@interface MFSendEmailTextField : MFRegularExpressionTextField

/*
 Default email pattern used to validate user keyboarding data.
 */
extern NSString *const MFSETF_DEFAULT_EMAIL_PATTERN;

/*
 Default url used to send an email.
 */
extern NSString *const MFSETF_DEFAULT_URL_TO_SEND_EMAIL;

@end

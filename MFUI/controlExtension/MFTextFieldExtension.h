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


#import "MFBaseTextExtensionProtocol.h"

FOUNDATION_EXPORT const NSString *PARAMETER_TEXTFIELD_MAXLENGTH_KEY;
FOUNDATION_EXPORT const NSString *PARAMETER_TEXTFIELD_MINLENGTH_KEY;

/*!
 * @class MFTextFieldExtension
 * @brief This class represents the parameters the framework can manage on a MFUITextField
 */
@interface MFTextFieldExtension : NSObject<MFBaseTextExtensionProtocol>

@end

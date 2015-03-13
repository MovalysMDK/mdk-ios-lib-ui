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

#import "MFRegularExpressionTextFieldExtension.h"


const NSString *PARAMETER_REGULAREXPRESSIONTEXTFIELD_PATTERN_KEY = @"pattern";


@implementation MFRegularExpressionTextFieldExtension
@synthesize pattern = _regularExpression;


#pragma mark - Methods

- (NSString *) description
{
    return [NSString stringWithFormat:@"MFExtensionKeyboardingUIControlWithRegExp<maxLength: %@, minLength: %@, regularExpression: %@>", self.maxLength, self.minLength, self.pattern];
}

@end

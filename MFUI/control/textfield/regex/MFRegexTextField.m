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

#import "MFRegexTextField.h"

@implementation MFRegexTextField
@synthesize customStyleClass;

-(void)initializeComponent {
    [super initializeComponent];
        [self.styleClass performSelector:@selector(addButtonOnTextField:) withObject:self];
}

-(void)textDidChange:(id)sender {
    [self setIsValid:[self NSStringIsValidEmail:self.text]];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    NSString *emailRegex = [self regex];
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(NSString *) regex {
//    @throw [[NSException alloc] initWithName:@"Missing Regex" reason:@"You should implement the regex for this component" userInfo:nil];
    return nil;
}

@end

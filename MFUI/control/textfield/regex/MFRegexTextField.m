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
#import "MFException.h"
#import "MFNoMatchingValueUIValidationError.h"

@implementation MFRegexTextField
@synthesize customStyleClass;

-(void)initializeComponent {
    [super initializeComponent];
    [self.styleClass performSelector:@selector(addButtonOnTextField:) withObject:self];
}

-(BOOL) matchPattern:(NSString *)checkString
{
    NSString *regex = [self regex];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:checkString];
}

-(NSString *) regex {
    return nil;
}

-(void) doAction {
    [MFException throwNotImplementedExceptionOfMethodName:@"doAction" inClass:[self class] andUserInfo:nil];
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if(![self matchPattern:[self getData]] && !([[self getData] length] == 0)) {
        NSError *error = [[MFNoMatchingValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    return nbOfErrors;
}


@end

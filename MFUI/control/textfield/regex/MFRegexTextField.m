//
//  MFEmailTextField.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

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

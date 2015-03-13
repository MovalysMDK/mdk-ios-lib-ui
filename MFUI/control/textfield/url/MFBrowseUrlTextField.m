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
//  MFBrowseUrlTextField.m
//  MFUI
//
//

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreApplication.h>

#import "MFBrowseUrlTextField.h"
#import "MFWebViewController.h"


@implementation MFBrowseUrlTextField

NSString *const MFBUTF_DEFAULT_URL_PATTERN = @"\\b(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";

NSString *const MFBUTF_DEFAULT_URL_TO_BROWSE_URL = @"%@";

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.applicationContext = [MFApplication getInstance];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

-(void) initialize
{
    [super initialize];
    
    self.applicationContext = [MFApplication getInstance];
    self.urlSpecificField = MFBUTF_DEFAULT_URL_TO_BROWSE_URL;
    self.pattern = MFBUTF_DEFAULT_URL_PATTERN;
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError *(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFInvalidUrlValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    [self setKeyboardType:UIKeyboardTypeURL];
    [self.regularExpressionTextField.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    self.regularExpressionTextField.backgroundColor = self.textFieldBackgroundColor;
}

-(void) doAction{
    [super doAction];
    NSString *newUrl = [self getValue];
    
    if(newUrl && !([newUrl length] == 0) &&
       [newUrl rangeOfString:@"://"].location == NSNotFound)
    {
        newUrl = [@"http://"stringByAppendingString:newUrl];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newUrl]];
}

-(void)setMandatory:(NSNumber *)mandatory {
    [self.regularExpressionTextField setMandatory:mandatory];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.regularExpressionTextField setEditable:editable];
}
-(void)selfCustomization {
    [self setButtonImage:@"planet.png"];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.regularExpressionTextField.textField.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFTEXTFIELD_TEXTFIELD
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD) {
        [self.regularExpressionTextField.textField setTag:TAG_MFBROWSEURLTEXTFIELD_TEXTFIELD];
    }
    if (self.actionButton.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON) {
        [self.actionButton setTag:TAG_MFBROWSEURLTEXTFIELD_ACTIONBUTTON];
    }
}


@end

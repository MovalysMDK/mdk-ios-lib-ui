//
//  MFPhoneTextField.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 20/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFPhoneTextField.h"

@implementation MFPhoneTextField

-(NSString *)regex {
    return @"[235689][0-9]{6}([0-9]{3})?";
}

@end

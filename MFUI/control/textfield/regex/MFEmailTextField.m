//
//  MFEmailTextField.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 20/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFEmailTextField.h"

@implementation MFEmailTextField

-(NSString *)regex {
    return @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
}

@end

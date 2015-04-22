//
//  MFUrlTextField.m
//  ComponentInherited
//
//  Created by Lagarde Quentin on 20/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFUrlTextField.h"

@implementation MFUrlTextField

-(NSString *)regex {
   return @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
}

@end

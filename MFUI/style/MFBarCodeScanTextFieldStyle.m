//
//  MFBarCodeTextFieldStyle.m
//  MFUI
//
//  Created by Quentin Lagarde on 27/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFBarCodeScanTextFieldStyle.h"
//#import "MFRegexTextFieldStyle+Button.h"



@implementation MFBarCodeScanTextFieldStyle

-(NSString *)accessoryButtonImageName {
    return @"qrcode_icon";
}

-(BOOL)hasAccessoryButton {
    return YES;
}


@end

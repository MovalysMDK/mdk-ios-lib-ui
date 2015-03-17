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
//  MFColorValueProcessing.m
//  MFUI
//
//

#import <MFCore/MFCoreConfig.h>

#import "MFColorValueProcessing.h"
#import "MFUILogging.h"

@implementation MFColorValueProcessing

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

/**
 * @see MFTypeValueProcessingProtocol.h
 */
-(id)processTreatmentOnComponent:(id<MFUIComponentProtocol>)component withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel forProperty:(NSString *)property fromBindableProperties:(NSDictionary *)bindableProperties {
    
    NSString *colorValue = [((MFFieldDescriptor *)component.selfDescriptor) valueForKey:property];
    if([[[[bindableProperties objectForKey:property] objectForKey:MFATTR_RECOGNIZED_VALUES] componentsSeparatedByString:@";"] containsObject:colorValue]) {
        colorValue = [colorValue stringByAppendingString:@"Color"];
        return   (UIColor *)[[UIColor class] performSelector:NSSelectorFromString(colorValue)];
    }
    else {
        id returnValue  = nil;
        if(colorValue) {
            returnValue = [(id)viewModel valueForKey:colorValue];
        }
        if(!returnValue && colorValue) {
            MFUILogInfo(@"Bindable property %@ was not found on %@", colorValue, [viewModel class]);
        }
        return returnValue;
    }
}


+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

+(UIColor *)processColorFromString:(NSString *)stringColor {
    if([[UIColor class]  respondsToSelector:NSSelectorFromString(stringColor)]) {
        return   (UIColor *)[[UIColor class] performSelector:NSSelectorFromString(stringColor)];
    }
    else if ( stringColor && ([stringColor hasPrefix:@"#"] && [stringColor length] == 12 ) ){
        // 12 = 1"#" + 6 + of color without alpha ( AABBCC ) + 5 from "Color"
        // delete added Color suffixe used in UIColor
        stringColor = [stringColor substringToIndex:[stringColor length]-5];
        return [MFColorValueProcessing processColorFromHexaString:stringColor];
    } else {
       return nil;
    }
}

+(UIColor *)processColorFromHexaStringWithAlpha:(NSString *)stringHexaColor withAlpha:(CGFloat) alpha{
    // Convert hex string to an integer
    unsigned int hexInteger = [MFColorValueProcessing intFromHexString:stringHexaColor];
    
    // Create color object, specifying alpha as well
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexInteger & 0xFF0000) >> 16))/255
                                     green:((CGFloat) ((hexInteger & 0xFF00) >> 8))/255
                                      blue:((CGFloat) ((hexInteger & 0xFF) >> 0))/255
                                     alpha:alpha];
    return color;
}

+(UIColor *)processColorFromHexaString:(NSString *)stringHexaColor {
    if ( [stringHexaColor length] != 9 && [stringHexaColor hasPrefix:@"#"] ) {
        stringHexaColor = [stringHexaColor stringByReplacingOccurrencesOfString:@"#" withString:@"#FF"];
    }
    return [MFColorValueProcessing processColorFromHexaStringWithAlpha:stringHexaColor withAlpha:1.0f];
}
#pragma clang diagnostic pop


@end

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
//  MFPickerListSelectionIndicator.m
//  MFUI
//
//

#import "MFPickerListSelectionIndicator.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>


@interface MFPickerListSelectionIndicator()

@property(nonatomic, strong) UIColor *mainColor;

@property (nonatomic) CGColorRef lightColor;
@property (nonatomic) CGColorRef darkColor;
@property (nonatomic) CGRect rect;


@end


@implementation MFPickerListSelectionIndicator

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)mainColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mainColor = mainColor;
    }
    return self;
}


-(void) drawGlossAndGradientWithContext:(CGContextRef)context {

    [self drawLinearGradientWithContext:context];

    self.lightColor = [UIColor colorWithRed:1.0 green:1.0
                                              blue:1.0 alpha:0.35].CGColor;
    self.darkColor = [UIColor colorWithRed:1.0 green:1.0
                                              blue:1.0 alpha:0.1].CGColor;
    
    [self drawLinearGradientWithContext:context];
    
}

-(void) drawLinearGradientWithContext:(CGContextRef)context {
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(self.lightColor);
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)self.lightColor, (id)self.darkColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.rect), CGRectGetMinY(self.rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.rect), CGRectGetMaxY(self.rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, self.rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.rect = rect;
    
    CGFloat hue, saturation, brightness, alpha;
    self.lightColor = [UIColor colorWithHue:0.1 saturation:0.1 brightness:0.8 alpha:0.25].CGColor;
    self.darkColor = [UIColor colorWithHue:0.1 saturation:0.1 brightness:0.2 alpha:0.25].CGColor;
    
    if(self.mainColor && [self.mainColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        self.lightColor = [UIColor colorWithHue:hue saturation:saturation brightness:0.8 alpha:0.25].CGColor;
        self.darkColor = [UIColor colorWithHue:hue saturation:saturation brightness:0.2 alpha:0.25].CGColor;
    }
    [self drawGlossAndGradientWithContext:context];
    
}


@end

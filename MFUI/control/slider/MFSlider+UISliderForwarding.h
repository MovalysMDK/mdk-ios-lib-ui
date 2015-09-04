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


#import "MFSlider.h"

@interface MFSlider (UISliderForwarding)

// forwarded properties to inner UISlider
@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic, getter=isContinuous) BOOL continuous;
@property(nonatomic, retain) UIImage *minimumValueImage;
@property(nonatomic, retain) UIImage *maximumValueImage;
@property(nonatomic, retain) UIColor *minimumTrackTintColor;
@property(nonatomic, retain) UIColor *maximumTrackTintColor;
@property(nonatomic, readonly) UIImage *currentMinimumTrackImage;
@property(nonatomic, readonly) UIImage *currentMaximumTrackImage;
@property(nonatomic, retain) UIColor *thumbTintColor;
@property(nonatomic, readonly) UIImage *currentThumbImage;

// forwarded methods to inner UISlider
- (UIImage *)minimumTrackImageForState:(UIControlState)state;
- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)maximumTrackImageForState:(UIControlState)state;
- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)thumbImageForState:(UIControlState)state;
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;
- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds;
- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds;
- (CGRect)trackRectForBounds:(CGRect)bounds;
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;



@end

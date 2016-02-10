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
//  MFSlider.h
//  MFUI
//
//


#import "MFUIConversion.h"

#import "MFUIBaseComponent.h"
#import "MFLabel.h"

IB_DESIGNABLE

@interface MFSlider : MFUIBaseComponent



#pragma mark - Properties
/**
 * @brief The inner UISlider component
 */
@property (nonatomic, strong) UISlider *innerSlider;

/**
 * @brief The inner MFLabel component that displays the value of the slider.
 */
@property (nonatomic, strong) MFLabel *innerSliderValueLabel;

/**
 * @brief The setp of the slider
 */
@property (nonatomic) float step;


#pragma mark - Inspectable properties

/**
 * @brief The unbinded slider current value to display on IB.
 * @discussion This property is used on IB only.
 */
@property (nonatomic) IBInspectable NSRange IB_labelProportion;

/**
 * @brief The unbinded slider minimum value to display on IB.
 * @discussion This property is used on IB only.
 */
@property (nonatomic) IBInspectable NSInteger IB_uMinValue;

/**
 * @brief The unbinded slider maximum value to display on IB.
 * @discussion This property is used on IB only.
 */
@property (nonatomic) IBInspectable NSInteger IB_uMaxValue;

/**
 * @brief The unbinded slider current value to display on IB.
 * @discussion This property is used on IB only.
 */
@property (nonatomic) IBInspectable NSInteger IB_uValue;

/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic, strong) IBInspectable UIColor *IB_textColor;

/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable NSInteger IB_textAlignment;

/**
 * @brief The text size of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable NSInteger IB_textSize;


#pragma mark - Methods
/** 
 * @brief Set a value to the slider
 * @param value The value to set
 */
- (void) setValue:(float)value;

/**
 * @brief Set a value to the slider specifying animation or not
 * @param value The value to set
 * @param animated A BOOL that indicates if setting the value should be animated or not
 */
- (void)setValue:(float)value animated:(BOOL)animated;

/**
 * @brief Gets the current value of the slider
 * @return The float value of the slider
 */
- (float) getValue;
@end

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

#import "MFSlider+UISliderForwarding.h"

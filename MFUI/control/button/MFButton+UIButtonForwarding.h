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

#import "MFButton.h"

@interface MFButton (UIButtonForwarding)

// forwarded properties to inner UIButton
@property(nonatomic,readonly)           UIButtonType                    *buttonType;
@property(nonatomic, readonly, retain)  NSAttributedString              *currentAttributedTitle                 NS_AVAILABLE_IOS(6_0);
@property(nonatomic, readonly, copy)    UIImage                         *currentImage;
@property(nonatomic, readonly, retain)  UIImage                         *currentBackgroundImage;
@property(nonatomic, readonly, retain)  UIImageView                     *imageView;
@property(nonatomic, retain)            UIColor                         *tintColor;
@property(nonatomic, readonly, retain)  UIColor                         *currentTitleColor;
@property(nonatomic, readonly, retain)  UIColor                         *currentTitleShadowColor;
@property(nonatomic, readonly, retain)  UILabel                         *titleLabel;
@property(nonatomic)                    BOOL                            adjustsImageWhenDisabled;
@property(nonatomic)                    BOOL                            adjustsImageWhenHighlighted;
@property(nonatomic)                    BOOL                            reversesTitleShadowWhenHighlighted;
@property(nonatomic)                    BOOL                            showsTouchWhenHighlighted;
@property(nonatomic)                    BOOL                            hidden;
@property(nonatomic)                    UIEdgeInsets                    titleEdgeInsets;
@property(nonatomic)                    UIEdgeInsets                    contentEdgeInsets;
@property(nonatomic)                    UIEdgeInsets                    imageEdgeInsets;

+ (id)buttonWithType:(UIButtonType)buttonType;

// you can set the image, title color, title shadow color, and background image to use for each state. you can specify data
// for a combined state by using the flags added together. in general, you should specify a value for the normal state to be used
// by other states which don't have a custom value set

- (void)setTitle:(NSString *)title forState:(UIControlState)state;                     // default is nil. title is assumed to be single line
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default if nil. use opaque white
- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default is nil. use 50% black
- (void)setImage:(UIImage *)image forState:(UIControlState)state;                      // default is nil. should be same size if different for different states
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default is nil
- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state NS_AVAILABLE_IOS(6_0); // default is nil. title is assumed to be single line

- (NSString *)titleForState:(UIControlState)state;          // these getters only take a single state value
- (UIColor *)titleColorForState:(UIControlState)state;
- (UIColor *)titleShadowColorForState:(UIControlState)state;
- (UIImage *)imageForState:(UIControlState)state;
- (UIImage *)backgroundImageForState:(UIControlState)state;
- (NSAttributedString *)attributedTitleForState:(UIControlState)state NS_AVAILABLE_IOS(6_0);

// these are the values that will be used for the current state. you can also use these for overrides. a heuristic will be used to
// determine what image to choose based on the explict states set. For example, the 'normal' state value will be used for all states
// that don't have their own image defined.

@property(nonatomic,readonly,retain) NSString *currentTitle;             // normal/highlighted/selected/disabled. can return nil

// these return the rectangle for the background (assumes bounds), the content (image + title) and for the image and title separately. the content rect is calculated based
// on the title and image size and padding and then adjusted based on the control content alignment. there are no draw methods since the contents
// are rendered in separate subviews (UIImageView, UILabel)

- (CGRect)backgroundRectForBounds:(CGRect)bounds;
- (CGRect)contentRectForBounds:(CGRect)bounds;
- (CGRect)titleRectForContentRect:(CGRect)contentRect;
- (CGRect)imageRectForContentRect:(CGRect)contentRect;




@end

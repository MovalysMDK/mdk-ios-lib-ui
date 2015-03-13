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
//  MFTextView.h
//  MFUI
//
//



#import <MFCore/MFCoreI18n.h>

#import "MFUIUtils.h"
#import "MFUIControlExtension.h"
#import "MFUIMotion.h"
#import "MFUIBinding.h"

#import "MFUIBaseComponent.h"



/**
 * TextView component permit the input of a multiline text
 */

@interface MFTextView : MFUIBaseComponent<UITextViewDelegate, MFOrientationChangedProtocol>

#pragma mark - Properties

/*
 Extended properties of text field.
 */
@property(nonatomic, strong) NSObject<MFBaseTextExtensionProtocol> *mf;

/**
 Underlying component.
 */

@property (nonatomic, strong) UITextView *textView;

/**
 * @brief the delegate that manages orientation changes
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;


#pragma mark - Specific TextField method implementation

/**
 * @brief Set the type keyboard which will be displayed.
 * @param type The type of the keyboard
 */
-(void) setKeyboardType:(UIKeyboardType) type;

/**
 * @brief Set the main value for this component
 * @param value The value to set
 */
-(void) setValue:(NSString *) value;

/**
 * @brief Returns the main value of this component
 * @return The value of the component
 */
-(NSString *) getValue;

@end

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer

#import "MFTextView + UITextViewForwarding.h"

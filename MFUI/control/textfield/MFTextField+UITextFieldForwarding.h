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
//  MFTextField+UITextFieldForwarding.h
//  MFUI
//
//

#import "MFTextField.h"

/**
 little trick from ObjC to declare current properties of UITextField. This is used to make the compiler happy when using a property of UITextField for an MFTextField object.
 
 MFTextField implements KVC magic forwarding of this properties.
 
 */
@interface MFTextField (UITextFieldForwarding)

// forwarded properties to inner UITextField
@property(nonatomic,copy)   NSString               *text;
@property(nonatomic,copy)   NSAttributedString     *attributedText NS_AVAILABLE_IOS(6_0);
@property(nonatomic,retain) UIColor                *textColor;
@property(nonatomic,retain) UIFont                 *font;
@property(nonatomic)        NSTextAlignment         textAlignment;
@property(nonatomic)        UITextBorderStyle       borderStyle;
@property(nonatomic,copy)   NSString               *placeholder;
@property(nonatomic,copy)   NSAttributedString     *attributedPlaceholder NS_AVAILABLE_IOS(6_0);
@property(nonatomic)        BOOL                    clearsOnBeginEditing;
@property(nonatomic)        BOOL                    adjustsFontSizeToFitWidth;
@property(nonatomic)        CGFloat                 minimumFontSize;
@property(nonatomic,assign) IBOutlet id<UITextFieldDelegate> delegate;
@property(nonatomic,retain) UIImage                *background;
@property(nonatomic,retain) UIImage                *disabledBackground;
@property(nonatomic,readonly,getter=isEditing)      BOOL editing;
@property(nonatomic) BOOL allowsEditingTextAttributes NS_AVAILABLE_IOS(6_0);
@property(nonatomic,copy) NSDictionary *typingAttributes NS_AVAILABLE_IOS(6_0);
@property(nonatomic)        UITextFieldViewMode  clearButtonMode;
@property(nonatomic,retain) UIView              *leftView;
@property(nonatomic)        UITextFieldViewMode  leftViewMode;
@property(nonatomic,retain) UIView              *rightView;
@property(nonatomic)        UITextFieldViewMode  rightViewMode;
@property(nonatomic,retain) UIView              *inputView;

@end

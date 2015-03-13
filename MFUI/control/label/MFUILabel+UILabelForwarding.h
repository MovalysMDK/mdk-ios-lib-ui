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
//  MFUILabel+UILabelForwarding.h
//  MFUI
//
//

#import "MFUILabel.h"

@interface MFUILabel (UILabelForwarding)

// forwarded properties to inner UITextField
@property(nonatomic,copy)   NSString                                            *text;
@property(nonatomic,copy)   NSAttributedString                                  *attributedText                                     NS_AVAILABLE_IOS(6_0);
@property(nonatomic,retain) UIColor                                             *textColor;
@property(nonatomic,retain) UIColor                                             *backgroundColor;
@property(nonatomic,retain) UIFont                                              *font;
@property(nonatomic,copy)   NSString                                            *placeholder;
@property(nonatomic,copy)   NSAttributedString                                  *attributedPlaceholder                              NS_AVAILABLE_IOS(6_0);
@property(nonatomic,retain) UIImage                                             *background;
@property(nonatomic,retain) UIImage                                             *disabledBackground;
@property(nonatomic,retain) UIView                                              *leftView;
@property(nonatomic,retain) UIView                                              *rightView;
@property(nonatomic,retain) UIColor                                             *shadowColor;
@property(nonatomic,copy)   NSDictionary                                        *typingAttributes                                   NS_AVAILABLE_IOS(6_0);

@property(nonatomic)        BOOL                                                clearsOnBeginEditing;
@property(nonatomic)        BOOL                                                adjustsFontSizeToFitWidth;
@property(nonatomic)        BOOL                                                allowsEditingTextAttributes                         NS_AVAILABLE_IOS(6_0);
@property(nonatomic)        NSTextAlignment                                     textAlignment;
@property(nonatomic)        UITextBorderStyle                                   borderStyle;
@property(nonatomic)        CGFloat                                             minimumFontSize;
@property(nonatomic,assign) IBOutlet id<UITextFieldDelegate>                    delegate;
@property(nonatomic)        NSInteger                                           numberOfLines;
@property(nonatomic)        UILineBreakMode                                     lineBreakMode;
@property(nonatomic)        CGSize                                              shadowOffset;
@property(nonatomic,readonly,getter=isEditing) BOOL                             editing;

@end

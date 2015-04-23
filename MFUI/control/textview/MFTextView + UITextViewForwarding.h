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
//  MFTextView + UITextViewForwarding.h
//  MFUI
//
//

#import "MFTextView.h"


@interface MFTextView (UITextViewForwarding)

// forwarded properties to inner UITextView
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSAttributedString *attributedText;
@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic) BOOL allowsEditingTextAttributes;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic, copy) NSDictionary *typingAttributes;
@property(nonatomic, copy) NSDictionary *linkTextAttributes;
@property(nonatomic, assign) UIEdgeInsets textContainerInset;
@property(nonatomic) NSRange selectedRange;
@property(nonatomic) BOOL clearsOnInsertion;
@property(nonatomic, getter=isSelectable) BOOL selectable;
@property(nonatomic, assign) id<UITextViewDelegate> delegate;
@property(readwrite, retain) UIView *inputView;
@property(readwrite, retain) UIView *inputAccessoryView;
@property(nonatomic, readonly) NSLayoutManager *layoutManager;
@property(nonatomic, readonly) NSTextContainer *textContainer;
@property(nonatomic, readonly, retain) NSTextStorage *textStorage;

// forwarded methods to inner UITextView
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
- (void)scrollRangeToVisible:(NSRange)range;


@end

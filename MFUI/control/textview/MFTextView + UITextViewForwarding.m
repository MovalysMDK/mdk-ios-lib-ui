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
//  MFTextView + UITextViewForwarding.m
//  MFUI
//
//

#import "MFTextView + UITextViewForwarding.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation MFTextView (UITextViewForwarding)

#pragma clang diagnostic pop

@dynamic text;
@dynamic attributedText;
@dynamic font;
@dynamic textColor;
@dynamic allowsEditingTextAttributes;
@dynamic dataDetectorTypes;
@dynamic textAlignment;
@dynamic typingAttributes;
@dynamic linkTextAttributes;
@dynamic textContainerInset;
@dynamic selectedRange;
@dynamic clearsOnInsertion;
@dynamic selectable;
@dynamic delegate;
@dynamic inputView;
@dynamic inputAccessoryView;
@dynamic layoutManager;
@dynamic textContainer;
@dynamic textStorage;

@end

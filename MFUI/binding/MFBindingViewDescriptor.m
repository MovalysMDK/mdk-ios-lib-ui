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

#import "MFBindingViewDescriptor.h"
#import "MFBindingFormatParser.h"

@implementation MFBindingViewDescriptor

#pragma mark Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewBinding = [MFBindingDictionary new];
        self.controlsAttributes = [NSDictionary new];
        self.associatedLabels = [NSDictionary new];
    }
    return self;
}

+(instancetype)viewDescriptorWithIdentifier:(NSString *)viewIdentifier withViewHeight:(NSNumber *)viewHeight withViewBindingFormat:(NSString *)format, ...  NS_REQUIRES_NIL_TERMINATION {
    MFBindingViewDescriptor *viewDescriptor = [MFBindingViewDescriptor new];
    viewDescriptor.viewIdentifier = viewIdentifier;
    viewDescriptor.viewHeight = viewHeight;
    va_list args;
    va_start(args, format);
    viewDescriptor.controlsAttributes = [MFBindingFormatParser buildControlsAttributesDictionary:viewDescriptor.controlsAttributes fromVaList:args withFirstArg:format];
    va_end(args);
    
    va_start(args, format);
    viewDescriptor.associatedLabels = [MFBindingFormatParser buildAssociatedLabelsDictionary:viewDescriptor.associatedLabels fromVaList:args withFirstArg:format];
    va_end(args);
    
    va_start(args, format);
    viewDescriptor.viewBinding = [MFBindingFormatParser bindingDictionaryFromVaList:args withFirstArg:format];
    va_end(args);
    return viewDescriptor;
}


#pragma mark - Consistency protocol
-(BOOL)isConsistent {
    return YES;
}


#pragma mark - Custom methods
-(NSString *)generatedBindingKey {
    return [NSString stringWithFormat:@"%@_%@_%@", self.viewIdentifier, @(self.viewIndexPath.section), @(self.viewIndexPath.row)];
}

@end

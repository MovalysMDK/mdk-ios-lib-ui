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


#import "MFBindingCellDescriptor.h"
#import <objc/runtime.h>
#import "NSString+Utils.h"
#import "MFBindingFormatParser.h"

#define MF_DEFAULT_CELL_HEIGHT 44

/************************************************************/
/* MFBindingCellDescriptor                                  */
/************************************************************/


#pragma mark - MFBindingCellDescriptor
@implementation MFBindingCellDescriptor

#pragma mark Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellIdentifier = nil;
        self.cellHeight = @(MF_DEFAULT_CELL_HEIGHT);
        self.cellBinding = [MFBindingDictionary new];
        self.controlsAttributes = [NSDictionary new];
        self.associatedLabels = [NSDictionary new];
    }
    return self;
}


#pragma mark Initialization
+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor new];
    cellDescriptor.cellIdentifier = identifier;
    return cellDescriptor;
}

+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellBinding:(MFBindingDictionary *)cellBinding {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:identifier];
    cellDescriptor.cellBinding = cellBinding;
    return cellDescriptor;
}

+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellBindingFormat:(NSString *)format,... NS_REQUIRES_NIL_TERMINATION {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:identifier];
    va_list args;
    va_start(args, format);
    cellDescriptor.cellBinding = [MFBindingFormatParser bindingDictionaryFromVaList:args withFirstArg:format];
    va_end(args);
    return cellDescriptor;
}

+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:identifier];
    cellDescriptor.cellHeight = cellHeight;
    return cellDescriptor;
}

+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight withCellBinding:(MFBindingDictionary *)cellBinding {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:identifier withCellBinding:cellBinding];
    cellDescriptor.cellHeight = cellHeight;
    return cellDescriptor;
}

+(instancetype) cellDescriptorWithIdentifier:(NSString *)identifier withCellHeight:(NSNumber *)cellHeight withCellBindingFormat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION {
    MFBindingCellDescriptor *cellDescriptor = [MFBindingCellDescriptor cellDescriptorWithIdentifier:identifier withCellHeight:cellHeight];
    va_list args;
    va_start(args, format);
    cellDescriptor.controlsAttributes = [MFBindingFormatParser buildControlsAttributesDictionary:cellDescriptor.controlsAttributes fromVaList:args withFirstArg:format];
    cellDescriptor.associatedLabels = [MFBindingFormatParser buildAssociatedLabelsDictionary:cellDescriptor.associatedLabels fromVaList:args withFirstArg:format];
    cellDescriptor.cellBinding = [MFBindingFormatParser bindingDictionaryFromVaList:args withFirstArg:format];
    va_end(args);
    return cellDescriptor;
}


#pragma mark Consistency
-(BOOL)isConsistent {
    return (self.cellIdentifier != nil);
}

#pragma mark Unique Binding Key
-(NSString *)generatedBindingKey {
    return [NSString stringWithFormat:@"%@_%@_%@", self.cellIdentifier, @(self.cellIndexPath.section), @(self.cellIndexPath.row)];
}

#pragma mark - Description

-(NSString *)description {
    return [NSString stringWithFormat:@"IndexPath=[%d,%d], identifier=%@, height=%@\rBindingDictionary=%@", self.cellIndexPath.section, self.cellIndexPath.row, self.cellIdentifier, self.cellHeight, self.cellBinding];
}
@end
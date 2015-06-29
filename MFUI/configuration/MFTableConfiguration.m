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


#import "MFTableConfiguration.h"
#import "MFObjectWithBindingProtocol.h"


const NSString *SECTION_ORDER_KEY = @"sectionOrder";
const NSString *CURRENT_SECTION_KEY = @"currentSection";
const NSString *CELL_1D_DESCRIPTOR = @"CELL_1D_DESCRIPTOR";
const NSString *SECTION_HEADER_VIEW_2D_DESCRIPTOR = @"SECTION_HEADER_VIEW_2D_DESCRIPTOR";

@interface MFTableConfiguration ()

@property (nonatomic, weak) id<MFObjectWithBindingProtocol> objectWithBinding;

@property (nonatomic, strong) NSMutableArray *sectionOrder;
@property (nonatomic, strong) NSMutableArray *currentOrder;
@property (nonatomic, strong) NSMutableArray *currentSection;

@property (nonatomic, strong) NSString *currentSectionIdentifier;

@property (nonatomic) NSUInteger currentSectionIndex;
@property (nonatomic) NSUInteger currentRowIndex;

@end

@implementation MFTableConfiguration

#pragma mark - Initialization


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sectionOrder = [NSMutableArray array];
        self.currentOrder = [NSMutableArray array];
        self.currentSection = [NSMutableArray array];
        
        self.currentSectionIndex = -1;
        self.currentRowIndex = 0;
    }
    return self;
}

+(instancetype) createTableConfigurationForObjectWithBinding:(id<MFObjectWithBindingProtocol>) objectWithBinding {
    MFTableConfiguration *tableConfiguration = [MFTableConfiguration new];
    tableConfiguration.objectWithBinding = objectWithBinding;
    [tableConfiguration initializeStructure];
    return tableConfiguration;
}

-(void) initializeStructure {
    if(!self.objectWithBinding.bindingDelegate.structure) {
        self.objectWithBinding.bindingDelegate.structure = [NSMutableDictionary new];
    }
    [self.objectWithBinding.bindingDelegate.structure setObject:self.sectionOrder forKey:SECTION_ORDER_KEY];
}


#pragma mark - Create Configuraion
-(void) createTableSectionWithName:(NSString *)tableSectionName {
    [[self currentStructure] setObject:[NSMutableArray array] forKey:tableSectionName];
    [[self currentStructure] setObject:tableSectionName forKey:CURRENT_SECTION_KEY];
    self.currentOrder = [self currentStructure][SECTION_ORDER_KEY];
    if(!self.currentOrder) {
        self.currentOrder = [NSMutableArray array];
    }
    [self.currentOrder addObject:tableSectionName];
    [[self currentStructure] setObject:self.currentOrder forKey:SECTION_ORDER_KEY];
    self.currentSectionIndex++;
    self.currentSectionIdentifier = tableSectionName;
}

-(void) createTableCellWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor {
    self.currentSectionIdentifier = [self currentStructure][CURRENT_SECTION_KEY];
    self.currentSection = [self currentStructure][self.currentSectionIdentifier];
    [self.currentSection addObject:cellDescriptor];
    [[self currentStructure] setObject:self.currentSection forKey:self.currentSectionIdentifier];
    self.currentRowIndex++;
}

-(void)create1DTableCellWithDescriptor:(MFBindingCellDescriptor *)cellDescriptor {
    [[self currentStructure] setObject:cellDescriptor forKey:CELL_1D_DESCRIPTOR];
}

-(void)create2DTableHeaderViewWithDescriptor:(MFBindingViewDescriptor *)viewDescriptor {
    [[self currentStructure] setObject:viewDescriptor forKey:SECTION_HEADER_VIEW_2D_DESCRIPTOR];
}

#pragma mark - Utils

-(NSMutableDictionary *) currentStructure {
    return self.objectWithBinding.bindingDelegate.structure;
}



@end

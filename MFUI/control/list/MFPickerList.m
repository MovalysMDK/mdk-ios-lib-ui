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

#import "MFPickerList.h"

//Extension
#import "MFPickerListExtension.h"

//Delegates
#import "MFPickerListItemBindingDelegate.h"
#import "MFPickerSelectedItemBindingDelegate.h"

@interface MFPickerList ()

/**
 * @brief The extension for PickerList
 */
@property (nonatomic, strong) MFPickerListExtension *mf;

@end

@implementation MFPickerList
@synthesize controlAttributes = _controlAttributes;

-(void)initialize {
    [super initialize];
    self.mf = [MFPickerListExtension new];
}

-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    _controlAttributes = controlAttributes;
    NSString *selectedItemBindingDelegate = controlAttributes[@"selectedItemBindingDelegate"];
    if(selectedItemBindingDelegate && !self.mf.selectedItemBindingDelegate) {
        self.mf.selectedItemBindingDelegate = [[NSClassFromString(selectedItemBindingDelegate) alloc] initWithPickerList:self];
    }
    else {
        self.mf.selectedItemBindingDelegate.picker = self;
    }
    
    NSString *listItemBindingDelegate = controlAttributes[@"listItemBindingDelegate"];
    if(listItemBindingDelegate && !self.mf.listItemBindingDelegate) {
        self.mf.listItemBindingDelegate = [[NSClassFromString(listItemBindingDelegate) alloc] initWithPickerList:self];
    }
    else {
        self.mf.listItemBindingDelegate.picker = self;
    }
    
    
    NSString *pickerValuesKey = controlAttributes[@"pickerValuesKey"];
    if(pickerValuesKey && !self.mf.pickerValuesKey) {
        self.mf.pickerValuesKey = pickerValuesKey;
    }
    
    NSNumber *hasSearch = controlAttributes[@"search"];
    if(hasSearch) {
        self.mf.hasSearch = [hasSearch boolValue];
    }
}

@end

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

#import "MFSwitch.h"
#import "MFSwitchWrapper.h"
#import "MFObjectWithBindingProtocol.h"

@implementation MFSwitchWrapper

-(instancetype)initWithComponent:(UIControl *)component {
    self = [super initWithComponent:component];
    if(self) {
        [[self typeComponent] addTarget:self action:@selector(componentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

-(MFSwitch *)typeComponent {
    return (MFSwitch *)self.component;
}

-(void)componentValueChanged:(MFSwitch *)cSwitch
{
    [[self.objectWithBinding.bindingDelegate  binding] dispatchValue:@(cSwitch.on) fromComponent:self.component onObject:self.objectWithBinding.viewModel atIndexPath:self.wrapperIndexPath];
    
}

-(NSDictionary *) nilValueBySelector {
    NSMutableDictionary *superDict = [[super nilValueBySelector] mutableCopy];
    [superDict setObject:@0 forKey:@"setOn:"];
    return superDict;
}


@end

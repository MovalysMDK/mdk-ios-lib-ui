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

@import MDKControl.ControlFixedList;


#import "MDKFixedListWrapper.h"
#import "MFObjectWithBindingProtocol.h"
#import "NSIndexPath+Utils.h"
#import "MFUIBaseListViewModel.h"

@implementation MDKFixedListWrapper
@synthesize objectWithBinding = _objectWithBinding;
@synthesize wrapperIndexPath = _wrapperIndexPath;

-(instancetype)initWithComponent:(UIControl *)component {
    self = [super initWithComponent:component];
    if(self) {
        [[self typeComponent].internalView addTarget:self action:@selector(componentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

-(MDKUIFixedList *)typeComponent {
    return (MDKUIFixedList *)self.component;
}

-(void)componentValueChanged:(MDKUIFixedList *)fixedList
{
    [[self.objectWithBinding.bindingDelegate  binding] dispatchValue:[fixedList getData] fromComponent:self.component onObject:self.objectWithBinding.viewModel atIndexPath:self.wrapperIndexPath];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)setWrapperIndexPath:(NSIndexPath *)wrapperIndexPath {
    _wrapperIndexPath = wrapperIndexPath;
    
    //FIXME: Expliquer pourquoi on fait ça
    [[NSNotificationCenter defaultCenter] removeObserver:self.objectWithBinding name:[NSString stringWithFormat:@"MDK_ComponentSize_%@_%@", self.objectWithBinding, [self.wrapperIndexPath stringIndexPath]] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.objectWithBinding selector:@selector(cellSizeChanges:) name:[NSString stringWithFormat:@"MDK_ComponentSize_%@_%@", self.objectWithBinding, [self.wrapperIndexPath stringIndexPath]] object:nil];

}
#pragma clang diagnostic pop


-(id)fixComponentValue:(id)value forKeyPath:(NSString *)keyPath onObject:(id)object {
    id result = value;
    if([object isKindOfClass:NSClassFromString(@"MFUIBaseListViewModel")]) {
        NSMutableArray *viewModels = [object viewModels];
        viewModels = [self.component valueForKeyPath:keyPath];
        [object setViewModels:viewModels];
        result = object;
    }
    return result;
}


@end

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

#import "MFViewModelConfiguration.h"
#import "MFUIBaseViewModel.h"
#import "MFListenerDescriptorManager.h"

@interface MFViewModelConfiguration ()

@property (nonatomic, weak) MFUIBaseViewModel *viewModel;

@end

@implementation MFViewModelConfiguration


#pragma mark - Initialization

+(instancetype)configurationForViewModel:(MFUIBaseViewModel *)viewModel {
    MFViewModelConfiguration *config = [MFViewModelConfiguration new];
    if(config) {
        config.viewModel = viewModel;
    }
    return config;
}


#pragma mark - Configuration


-(void) addListenerDescriptor:(MFListenerDescriptor *)listenerDescriptor {
    [listenerDescriptor setTarget:self.viewModel];
    [self.viewModel.listenerDecriptorManager addListenerDescriptor:listenerDescriptor];
}

-(void) addListenerDescriptors:(NSArray *)listenerDescriptors {
    for(MFListenerDescriptor *descriptor in listenerDescriptors) {
        [self addListenerDescriptor:descriptor];
    }
}


@end

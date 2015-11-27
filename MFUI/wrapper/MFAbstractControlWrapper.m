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

@import MDKControl.Control;

#import "MFUIBaseListViewModel.h"

#import "MFAbstractControlWrapper.h"
#import "UIView+Binding.h"
@interface MFAbstractControlWrapper ()

@end

@implementation MFAbstractControlWrapper
@synthesize component = _component;

-(instancetype) initWithComponent:(UIView *)component {
    self = [super init];
    if(self) {
        _component = component;
    }
    return self;
}


-(UIView *)component {
    return _component;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"HASH : %@, ComponentType:%@", @(self.component.hash), self.component.class];
}

-(id)convertValueFromComponentToViewModel:(id)value {
    return value;
}

-(id)convertValueFromViewModelToComponent:(id)value {
    return value;
}

-(NSDictionary *) nilValueBySelector {
return @{};
}

-(void) dispatchDidBinded {
    [self.component didBinded];
}

-(void)setComponentValue:(id)value forKeyPath:(NSString *)keyPath {
    if([[self component] isKindOfClass:NSClassFromString(@"MDKUIFixedList")]) {
        if([keyPath isEqualToString:@"data"] && [value isKindOfClass:[MFUIBaseListViewModel class]]) {
            [((MDKRenderableControl *)self.component).internalView setValue:((MFUIBaseListViewModel *)value).viewModels forKeyPath:keyPath];
        }
    }
    else if([[self component] isKindOfClass:NSClassFromString(@"MDKRenderableControl")]) {
        [((MDKRenderableControl *)self.component).internalView setValue:value forKeyPath:keyPath];
    }
    else {
        [[self component] setValue:value forKeyPath:keyPath];
    }
}

-(id)componentValue:(id)value forKeyPath:(NSString *)keyPath onObject:(id)object{
    NSString *fixedKeyPath = keyPath;
    if([keyPath isEqualToString:@"data"]) {
        fixedKeyPath = @"getData";
    }
    id result = nil;
    if([((MDKRenderableControl *)self.component) isKindOfClass:NSClassFromString(@"MDKUIFixedList")]) {
        if([object isKindOfClass:[MFUIBaseListViewModel class]]) {
            NSMutableArray *viewModels = [object viewModels];
            viewModels = [self.component valueForKeyPath:fixedKeyPath];
            [object setViewModels:viewModels];
            result = object;
        }
    }
    else if([[self component] isKindOfClass:NSClassFromString(@"MDKRenderableControl")]) {
        result = value;
    }
    else {
        result = value;
    }
    return result;
}
@end

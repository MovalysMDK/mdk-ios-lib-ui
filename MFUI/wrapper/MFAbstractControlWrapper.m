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
#import "MFPhotoViewModel.h"

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
        else {
            [[self component] setValue:value forKeyPath:keyPath];
        }
    }
    else if([[self component] isKindOfClass:NSClassFromString(@"MDKUIMedia")]) {
        if([keyPath isEqualToString:@"data"] && [value isKindOfClass:[MFPhotoViewModel class]]) {
            [((MDKRenderableControl *)self.component).internalView setValue:((MFPhotoViewModel *)value).uri forKeyPath:keyPath];
        }
        else {
            [[self component] setValue:value forKeyPath:keyPath];
        }
    }
    else if([[self component] isKindOfClass:NSClassFromString(@"MDKUIWebView")]) {
        if([keyPath isEqualToString:@"data"] && [value isKindOfClass:[NSString class]]) {
            [((MDKRenderableControl *)self.component).internalView setValue:[NSURL URLWithString:value] forKeyPath:keyPath];
        }
        else {
            [[self component] setValue:value forKeyPath:keyPath];
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
    id result =  [self fixComponentValue:value forKeyPath:fixedKeyPath onObject:object];
    return result;
}



-(id)fixComponentValue:(id)value forKeyPath:(NSString *)keyPath onObject:(id)object {
    return value;
}
@end

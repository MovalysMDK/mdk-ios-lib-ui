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


#import "MFAbstractComponentWrapper.h"

@interface MFAbstractComponentWrapper ()



@end

@implementation MFAbstractComponentWrapper
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
@end

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


#import "MFPhotoViewModel.h"
#import "MFPositionVoProtocol.h"



@implementation MFPhotoViewModel

@synthesize identifier = _identifier;
@synthesize titre;
@synthesize descr;
@synthesize uri;
@synthesize date;
@synthesize photoState;
@synthesize position = _position;


#pragma mark - Initialization

-(id)init {
    self = [super init];
    if(self) {
        _position = [[MFPositionViewModel alloc] init];
        _position.parentViewModelPrefix = @"position";
        _position.parentViewModel = self;
        self.photoState = [[MFPhotoState alloc] init];
        self.photoState.state = none;
        self.identifier = [NSNumber numberWithInt:-1];
    }
    return self;
}

#pragma mark - Inherited methods from MFUIBaseViewModel

/**
 * @brief Binding pour la persistance
 */

-(NSArray *)getBindedProperties {
    return @[
             @"titre",
             @"descr",
             @"uri",
             @"date"
             ];
}


-(BOOL) validate {
    return (self.identifier != nil);
}

- (NSArray *)getChildViewModels {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    return result;
}

#pragma mark - Specific methods

- (NSString *) getDateStringFormat:(NSString *)dateFormat {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    return [dateFormatter stringFromDate:self.date];
    
}


+(MFPhotoViewModel *) toViewModel:(id<MFPhotoVoProtocol>)vo parentVm:(id<MFUIBaseViewModelProtocol>)parentVm
               parentPropertyName:(NSString *)parentPropertyName {
    MFPhotoViewModel *vm = [[MFPhotoViewModel alloc] init];
    
    vm.identifier = [vo identifier];
    vm.titre = vo.titre;
    vm.descr = vo.desc;
    vm.uri = vo.uri;
    vm.date = vo.date;
    vm.parentViewModelPrefix = parentPropertyName;
    return vm;
}

+(id<MFPhotoVoProtocol>) convertViewModel:(MFPhotoViewModel *)vm toComponent:(id<MFPhotoVoProtocol>)vo {
    vo.identifier = vm.identifier;
    vo.titre = vm.titre;
    vo.desc = vm.descr;
    vo.uri = vm.uri;
    vo.date = vm.date;
    return vo;
}

-(void)setIdentifier:(NSNumber *)identifier {
    _identifier = identifier;
}

-(BOOL) isEmpty {
    return !self.titre && !self.descr && !self.uri && !self.date;
}

@end

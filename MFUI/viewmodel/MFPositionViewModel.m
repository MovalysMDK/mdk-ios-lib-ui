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


#import "MFPositionViewModel.h"
#import "MFPositionVoProtocol.h"
#import "MFStringConverter.h"
#import "MFNumberConverter.h"


@implementation MFPositionViewModel
@synthesize latitude;
@synthesize longitude;

#pragma mark - Constructeurs
-(id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

#pragma mark - Inherited methods from MFUIBaseViewModel

/**
 * @brief Définir ici les actions à effectuer lorsque l'un des champs synchronizables du ViewModel a été modifié
 * @see NSKeyValueObserving.h
 */
/*-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    MFCoreLogVerbose(@"VIEW_MODEL_OBS_VALUE : Le champ %@ a changé",keyPath);
    
    //si un parent est défini, on récupère le chemin complet de la clé et on appelle la méthode parente.
    if(self.parentViewModel && self.parentViewModelPrefix) {
        
        //ATTENTION : ici on ne recupère pas d'extendedKeyPath car c'est bien le champ parent qui doit être mise à jour
        // dans son ensemble et non l'un des champs latitude ouy longitude.
        
        [self.parentViewModel observeValueForKeyPath:self.parentViewModelPrefix ofObject:object change:change context:context];
    }
}*/

-(NSArray *)getBindedProperties {
    return @[
             @"latitude",
             @"longitude"
             ];
}

+(MFPositionViewModel *) toViewModel:(id<MFPositionVoProtocol>)vo parentVm:(id<MFUIBaseViewModelProtocol>)parentVm parentPropertyName:(NSString *)parentPropertyName {
    
    MFPositionViewModel *vm = [parentVm valueForKeyPath:parentPropertyName];
    if ( vm == nil) {
        vm = [[MFPositionViewModel alloc] init];
    }
    
    if ( vo != nil ) {
        vm.latitude = [MFNumberConverter toString:vo.latitude];
        vm.longitude = [MFNumberConverter toString:vo.longitude];
    }
    vm.parentViewModelPrefix = parentPropertyName;
    
	return vm;
}

+(id<MFPositionVoProtocol>) convertViewModel:(MFPositionViewModel *)vm toComponent:(id<MFPositionVoProtocol>)vo {
    vo.latitude = [MFStringConverter toNumber:vm.latitude];
    vo.longitude = [MFStringConverter toNumber:vm.longitude];
    return vo;
}

-(BOOL) validate {
    return self.latitude != nil &&
    self.longitude != nil &&
    [self.latitude length] > 0 &&
    [self.longitude length] > 0 ;
}

@end

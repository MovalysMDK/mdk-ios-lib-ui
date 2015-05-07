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


#import "MFDictionaryValueProcessing.h"

@implementation MFDictionaryValueProcessing

-(id)processTreatmentOnComponent:(id<MFUIComponentProtocol>)component withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel forProperty:(NSString *)property fromBindableProperties:(NSDictionary *)bindableProperties {
    
    id value = [((MFFieldDescriptor *)component.selfDescriptor) valueForKey:property];;
    
    if(!value) {
        return nil;
    }
    
    NSDictionary *returnValue = nil;
    returnValue = [(id)viewModel valueForKey:value];
    return returnValue;
}
@end

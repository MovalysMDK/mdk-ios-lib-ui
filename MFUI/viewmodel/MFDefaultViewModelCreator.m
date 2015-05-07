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

#import <MFCore/MFCoreApplication.h>
#import "MFDefaultViewModelCreator.h"
#import "MFUIBaseListViewModel.h"
#import "MFUIBaseViewModel.h"


@implementation MFDefaultViewModelCreator


-(id) createVM:(NSString*) p_vmClassName {
    return [[MFApplication getInstance] getBeanWithKey:p_vmClassName];
}

-(id) createVM:(NSString *)vmClassName withData:(NSFetchedResultsController *)data andItemVmClass:(NSString *)itemVmClass {
	MFUIBaseListViewModel *vm = [self createVM:vmClassName];
	[vm clear];
    vm.fetch=data;
	return vm ;
}

-(id) createOrUpdateItemVM:(NSString *)itemClassName withData:(id)data {
	MFUIBaseViewModel *vm = [self createVM:itemClassName];
	[vm updateFromIdentifiable:data];
	return vm ;
}

-(id) createOrUpdateItemVM:(NSString *)itemClassName withData:(id)data withFilterParameters:(NSDictionary *)filterParameters {
	MFUIBaseViewModel *vm = [self createVM:itemClassName];
    if(filterParameters) {
        vm.filterParameters = filterParameters;
    }
	[vm updateFromIdentifiable:data];
	return vm;
}

@end

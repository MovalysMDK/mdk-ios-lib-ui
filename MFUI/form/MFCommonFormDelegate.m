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

#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import "MFFormCellProtocol.h"
#import "MFUIComponentProtocol.h"
#import "MFConverterProtocol.h"
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import "MFUIComponentProtocol.h"
#import "MFCellAbstract.h"
#import "MFFormViewController.h"
#import "MFCommonFormDelegate.h"
#import "MFConfigurationHandler.h"

NSString *const MF_BINDABLE_PROPERTIES = @"BindableProperties";

@interface MFCommonFormDelegate()

/**
 * @brief The registry used to create beans
 */
@property (nonatomic, weak) MFConfigurationHandler *registry;

/**
 * @brief An array containing the sizes of the cell for this form
 */
@property (nonatomic, strong) NSMutableDictionary *cellSizes;

@end


@implementation MFCommonFormDelegate

@synthesize parent;
@synthesize viewModel = _viewModel;
@synthesize formValidation = _formValidation;
@synthesize bindingDelegate = _bindingDelegate;

#pragma mark - Initializing
-(id)initWithParent:(id<MFCommonFormProtocol>) parentForm {
    self = [super init];
    if(self) {
        self.parent = parentForm;
        [self initialize];
    }
    return self;
}


-(void) initialize {
    self.registry = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    
    
}


-(NSString *) generateSetterFromProperty:(NSString *)propertyName {
    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
    propertyName = [NSString stringWithFormat:@"set%@:",propertyName];
    return propertyName;
}


#pragma mark - Actions sur les composants graphiques.

-(void) dealloc {
    self.parent = nil;
}

-(id<MFUIBaseViewModelProtocol>)getViewModel {
    return [self.parent getViewModel];
}


@end




#pragma mark - MFBindingComponentDescriptor Implemnetation

/**
 * @brief Cette classe est un descripteur pour le binding des propriétés/composants.
 */
@implementation MFComponentDescriptor : NSObject


@end


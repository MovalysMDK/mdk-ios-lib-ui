//
//  MFInvalidLocationValueUIValidationError.m
//  MFUI
//
//  Created by Quentin Lagarde on 24/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFInvalidLocationValueUIValidationError.h"

@implementation MFInvalidLocationValueUIValidationError

NSInteger const INVALID_LOCATION_VALUE_UI_VALIDATION_ERROR_CODE = 10004;

NSString *const INVALID_LOCATION_VALUE_UI_VALIDATION_LOCALIZED_DESCRIPTION_KEY = @"MFInvalidLocationValueUIValidationError";


-(id)initWithLocalizedFieldName:(NSString *)fieldName technicalFieldName:(NSString *) technicalFieldName
{
    self = [super initWithCode:INVALID_LOCATION_VALUE_UI_VALIDATION_ERROR_CODE localizedDescriptionKey:INVALID_LOCATION_VALUE_UI_VALIDATION_LOCALIZED_DESCRIPTION_KEY localizedFieldName:fieldName technicalFieldName:technicalFieldName];
    return self;
}

@end

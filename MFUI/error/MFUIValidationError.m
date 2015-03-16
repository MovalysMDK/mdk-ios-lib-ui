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
//
//  MFUIValidationError.m
//  MFCore
//
//

#import "MFUIValidationError.h"
#import <MFCore/MFCoreCoredata.h>
#import <MFCore/MFCoreApplication.h>

@interface MFUIValidationError ()

@property(nonatomic, strong) NSString *localizedFieldName;

@property(nonatomic, strong) NSString *technicalFieldName;

@end

@implementation MFUIValidationError

+ (NSString *) getDomainBase
{
    return [[super getDomainBase] stringByAppendingString:@".uiValidation"];
}

-(NSString *) domainBase
{
    return [MFUIValidationError getDomainBase];
}

/*
 Designated initializer.
 @param code Error unique code.
 @param dict may be nil if no userInfo desired.
 */
- (id)initWithCode:(NSInteger)code userInfo:(NSDictionary *)dict localizedFieldName: (NSString *) fieldName technicalFieldName:(NSString *)technicalFieldName
{
    self = [super initWithCode:code userInfo:dict];
    if(self)
    {
        self.localizedFieldName = fieldName;
        self.technicalFieldName = technicalFieldName;
        MFCoreLogVerbose(@"Error domain : %@ - code : %ld - localizedFieldName : %@ - technicalFieldName : %@", self.domainBase, (long)self.code, self.localizedFieldName, self.technicalFieldName);
    }
    
    return self;
}

/*
 Designated initializer.
 @param code Error unique code.
 @param descriptionKey complete sentence which describes why the operation failed. In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier).
 @param failureReasonKey The string that can be displayed as the "informative" (aka "secondary") message on an alert panel
 */
- (id)initWithCode:(NSInteger)code localizedDescriptionKey:(NSString *)descriptionKey localizedFailureReasonErrorKey: (NSString *) failureReasonKey localizedFieldName: (NSString *) fieldName technicalFieldName:(NSString *)technicalFieldName
{
    self = [super initWithCode:code localizedDescriptionKey:descriptionKey localizedFailureReasonErrorKey:failureReasonKey];
    if(self)
    {
        self.localizedFieldName = fieldName;
        self.technicalFieldName = technicalFieldName;
        MFCoreLogVerbose(@"Error domain : %@ - code : %ld - localizedFieldName : %@ - technicalFieldName : %@", self.domainBase, (long)self.code, self.localizedFieldName, self.technicalFieldName);
    }
    return self;
}

/*
 Designated initializer.
 @param code Error unique code.
 @param descriptionKey complete sentence which describes why the operation failed. In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier).
 */
- (id)initWithCode:(NSInteger)code localizedDescriptionKey:(NSString *)descriptionKey localizedFieldName: (NSString *) fieldName technicalFieldName:(NSString *)technicalFieldName{
    self = [super initWithCode:code localizedDescriptionKey:descriptionKey];
    if(self)
    {
        self.localizedFieldName = fieldName;
        self.technicalFieldName = technicalFieldName;
        MFCoreLogVerbose(@"Error domain : %@ - code : %ld - localizedFieldName : %@ - technicalFieldName : %@", self.domainBase, (long)self.code, self.localizedFieldName, self.technicalFieldName);
    }
    return self;
}


/*
 Designated initializer. dict may be nil if no userInfo desired.
 */
+ (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)dict localizedFieldName: (NSString *) fieldName technicalFieldName:(NSString *)technicalFieldName{
    return [[MFUIValidationError alloc] initWithCode:code userInfo:dict localizedFieldName:fieldName technicalFieldName:technicalFieldName];
}

@end

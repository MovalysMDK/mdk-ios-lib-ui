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

#import "MFBindingFormatParser.h"
#import "NSString+Utils.h"


NSString *BINDING_FORMAT_ATTRIBUTE_CAST_STRING = @"@s_";
NSString *BINDING_FORMAT_ATTRIBUTE_CAST_INTEGER = @"@i_";
NSString *BINDING_FORMAT_ATTRIBUTE_CAST_FLOAT = @"@f_";
NSString *BINDING_FORMAT_ATTRIBUTE_CAST_BOOL = @"@b_";

NSString *BINDING_FORMAT_TYPE_BINDING = @"binding";
NSString *BINDING_FORMAT_TYPE_ATTRIBUTES = @"attributes";
NSString *BINDING_FORMAT_TYPE_ASSOCIATED_LABEL = @"associatedLabel";
NSString *BINDING_FORMAT_TYPE_CONVERTER = @"converter";


@implementation MFBindingFormatParser

+(NSDictionary *)buildControlsAttributesDictionary:(NSDictionary *)controlAttributes fromVaList:(va_list)args withFirstArg:(NSString *)firstArg{
    NSMutableDictionary *cellAttributes = [controlAttributes mutableCopy];
    [MFBindingFormatParser fillObject:cellAttributes fromVaList:args withFirstArg:firstArg forType:BINDING_FORMAT_TYPE_ATTRIBUTES];
    return cellAttributes;
}

+(MFBindingDictionary *) bindingDictionaryFromVaList:(va_list)args withFirstArg:(NSString *)firstArg {
    MFBindingDictionary *dictionary = [MFBindingDictionary new];
    return [MFBindingFormatParser fillObject:dictionary fromVaList:args withFirstArg:firstArg forType:BINDING_FORMAT_TYPE_BINDING];
}

+(NSDictionary *)buildAssociatedLabelsDictionary:(NSDictionary *)associatedLabels fromVaList:(va_list)args withFirstArg:(NSString *)firstArg{
    NSMutableDictionary *mutableDictionary = [associatedLabels mutableCopy];
    return [MFBindingFormatParser fillObject:mutableDictionary fromVaList:args withFirstArg:firstArg forType:BINDING_FORMAT_TYPE_ASSOCIATED_LABEL];
}


+(id) fillObject:(id)objectToFill fromVaList:(va_list)args withFirstArg:(NSString *)firstArg forType:(NSString *)type{
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        
        NSArray *bindingByOutlets = [arg componentsSeparatedByString:@":"];
        NSString *outletName = [bindingByOutlets[0] trim];
        
        NSArray *outletParts = [outletName componentsSeparatedByString:@"."];
        if(outletParts.count < 3) {
            @throw [NSException exceptionWithName:@"Invalid Binding Format" reason:[NSString stringWithFormat:@"Invalid binding format : %@. The first part of format must have at least 3 components : outlet.OUTLET_NAME.TYPE", arg] userInfo:nil];
        }
        else if([type isEqualToString:BINDING_FORMAT_TYPE_ATTRIBUTES] && [[outletParts lastObject] isEqualToString:BINDING_FORMAT_TYPE_ATTRIBUTES]) {
            objectToFill = [MFBindingFormatParser fillCellAttributes:objectToFill forOutletName:outletName fromContent:bindingByOutlets[1]];
        }
        else if([type isEqualToString:BINDING_FORMAT_TYPE_BINDING] && [[outletParts lastObject] isEqualToString:BINDING_FORMAT_TYPE_BINDING]) {
            objectToFill = [MFBindingFormatParser fillBindingDictionary:objectToFill forOutletName:outletName fromContent:bindingByOutlets[1]];
        }
        else if([type isEqualToString:BINDING_FORMAT_TYPE_ASSOCIATED_LABEL] && [[outletParts lastObject] isEqualToString:BINDING_FORMAT_TYPE_ASSOCIATED_LABEL]) {
            objectToFill = [MFBindingFormatParser fillAssociatedLabel:objectToFill forOutletName:outletName fromContent:bindingByOutlets[1]];
        }
        else {
            if(![[MFBindingFormatParser recognizedFormatTypes] containsObject:[outletParts lastObject]]) {
                @throw [NSException exceptionWithName:@"Invalid Binding Format" reason:[NSString stringWithFormat:@"Invalid binding format : %@. The type of format '%@' is unrecognized", arg, [outletParts lastObject]] userInfo:nil];
            }
        }
    }
    return objectToFill;
}

+(NSDictionary *) fillCellAttributes:(NSMutableDictionary *)cellAttributes forOutletName:(NSString *)outletName fromContent:(NSString *)content {
    outletName = [[outletName stringByReplacingOccurrencesOfString:@"outlet." withString:@""] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", BINDING_FORMAT_TYPE_ATTRIBUTES] withString:@""];
    
    NSMutableDictionary *outletAttributes = cellAttributes[outletName];
    if(!outletAttributes) {
        outletAttributes = [NSMutableDictionary dictionary];
    }
    NSArray *attributesList = [content componentsSeparatedByString:@","];
    for(NSString *attributeDeclaration in attributesList) {
        if([[attributeDeclaration trim] isEqualToString:@""]) {
            break;
        }
        NSArray *attributeComponents = [attributeDeclaration componentsSeparatedByString:@"="];
        NSString *attributeName = [attributeComponents[0] trim];
        NSString *attributeValue = [attributeComponents[1] trim];
        if([attributeValue hasPrefix:BINDING_FORMAT_ATTRIBUTE_CAST_STRING]) {
            outletAttributes[attributeName] = [attributeValue stringByReplacingOccurrencesOfString:BINDING_FORMAT_ATTRIBUTE_CAST_STRING withString:@""];
        }
        else if([attributeValue hasPrefix:BINDING_FORMAT_ATTRIBUTE_CAST_BOOL]) {
            outletAttributes[attributeName] = @([[attributeValue stringByReplacingOccurrencesOfString:BINDING_FORMAT_ATTRIBUTE_CAST_BOOL withString:@""] boolValue]);
        }
        else if([attributeValue hasPrefix:BINDING_FORMAT_ATTRIBUTE_CAST_INTEGER]) {
            outletAttributes[attributeName] = @([[attributeValue stringByReplacingOccurrencesOfString:BINDING_FORMAT_ATTRIBUTE_CAST_INTEGER withString:@""] integerValue]);
        }
        else if([attributeValue hasPrefix:BINDING_FORMAT_ATTRIBUTE_CAST_FLOAT]) {
            outletAttributes[attributeName] = @([[attributeValue stringByReplacingOccurrencesOfString:BINDING_FORMAT_ATTRIBUTE_CAST_FLOAT withString:@""] floatValue]);
        }
        else {
            outletAttributes[attributeName] = [MFBindingFormatParser parseAttributeValueFormat:attributeValue];
        }
    }
    cellAttributes[outletName] = outletAttributes;
    return cellAttributes;
}

+(NSDictionary *) fillAssociatedLabel:(NSMutableDictionary *)associatedLabels forOutletName:(NSString *)outletName fromContent:(NSString *)content {
    outletName = [[outletName stringByReplacingOccurrencesOfString:@"outlet." withString:@""] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", BINDING_FORMAT_TYPE_ASSOCIATED_LABEL] withString:@""];
    NSString *associatedLabelOutletName = [[content stringByReplacingOccurrencesOfString:@"outlet." withString:@""] trim];
    associatedLabels[outletName] = associatedLabelOutletName;
    return associatedLabels;
}

+(MFBindingDictionary *)fillBindingDictionary:(MFBindingDictionary *)bindingDictionary forOutletName:(NSString *)outletName fromContent:(NSString *)content {
    NSArray *bindingsPairs = [content componentsSeparatedByString:@","];
    for(NSString *bindingPair in bindingsPairs) {
        [bindingDictionary addBindingDescriptor:[MFBindingDescriptor bindingDescriptorWithFormat:[bindingPair trim]] forOutletBindingKey:[MFOutletBindingKey bindingKeyForOutletName:outletName]];
    }
    return bindingDictionary;
}

+(NSArray *) recognizedFormatTypes {
    return @[BINDING_FORMAT_TYPE_BINDING, BINDING_FORMAT_TYPE_ATTRIBUTES, BINDING_FORMAT_TYPE_ASSOCIATED_LABEL];
}

+(id) parseAttributeValueFormat:(NSString *)attributeValue {
    id result = @"";
    NSScanner *scanner = [NSScanner scannerWithString:attributeValue];
    if([@"YES" isEqualToString:attributeValue] || [@"true" isEqualToString:attributeValue]) {
        result = @1;
    }
    else if([@"NO" isEqualToString:attributeValue] || [@"false" isEqualToString:attributeValue]) {
        result = @0;
    }
    else if([scanner scanInteger:NULL] && [scanner isAtEnd]) {
        result = @([attributeValue integerValue]);
    }
    else if([scanner scanFloat:NULL] && [scanner isAtEnd]) {
        result = @([attributeValue floatValue]);
    }
    else {
        result = attributeValue;
    }
    return result;
}
@end

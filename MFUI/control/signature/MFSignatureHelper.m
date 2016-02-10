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
//  MFSignatureDrawing.h
//
//


#import "MFSignatureHelper.h"
#import "MFSignatureDrawing.h"

@implementation MFSignatureHelper {

}

static CGPoint formerPoint;
static CGPoint currentPoint;
static const float virtualWidth = 1000.;

static inline Line scaleLine(Line line, float ratio) {
    line.from.x *= ratio;
    line.from.y *= ratio;
    line.to.x *= ratio;
    line.to.y *= ratio;
    return line;
}

static inline Line translateLine(Line line, float x0, float y0) {
    line.from.x += x0;
    line.from.y += y0;
    line.to.x += x0;
    line.to.y += y0;
    return line;
}

+ (NSString *) convertFromLinesToString:(NSMutableArray *) lines width:(float) width originX:(float) x0 originY:(float) y0 {
    NSMutableString *data = [[NSMutableString alloc] init];
    
    BOOL isFirstPoint = YES;
    [data appendString:@"{"];
    
    for (NSValue *nsLine in lines) {
        struct Line line;
        [nsLine getValue:&line];
        line = translateLine(line, -x0, -y0);
        line = scaleLine(line, virtualWidth/width);
        if (isFirstPoint || (line.from.x != currentPoint.x && line.from.y != currentPoint.y)) {
            if (isFirstPoint) {
                isFirstPoint = NO;
            } else {
                [data appendFormat:@"(%.0f,%.0f)", currentPoint.x, currentPoint.y];
                [data appendString:@"]"];
            }
            [data appendString:@"["];
        }
        formerPoint = line.from;
        currentPoint = line.to;
        [data appendFormat:@"(%.0f,%.0f)", formerPoint.x, formerPoint.y];
    }
    [data appendFormat:@"(%.0f,%.0f)", currentPoint.x, currentPoint.y];
    [data appendString:@"]"];
    [data appendString:@"}"];
    return data;
}

// Let's describe the string pattern of a signature :
// A point is of 2 coordinates : (x,y)
// A line is of mutiple points : [(x0,y0)(x1,y1)...]
// A signature is of mutiple lines {[(x0,y0)(x1,y1)...][...].....}
// The goal here is to fill in an 
+ (NSMutableArray *) convertFromStringToLines:(NSString *) string width:(float) width originX:(float) x0 originY:(float) y0 {
    NSError *regexError = NULL;
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    if (!string) {
        return NULL;
    }
    NSRegularExpression *lineRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+\\]"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&regexError];
    NSRegularExpression *pointRegex = [NSRegularExpression regularExpressionWithPattern:@"\\(([-0-9]+),([-0-9]+)\\)"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&regexError];
    
    NSArray *matchesLines = [lineRegex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *matchLine in matchesLines) {
        NSRange matchLineRange = [matchLine range];
        NSString *lineString = [string substringWithRange:matchLineRange];
        NSArray *matchesPoints = [pointRegex matchesInString:lineString
                                                     options:0
                                                       range:NSMakeRange(0, [lineString length])];
        BOOL isFirstPoint = YES;
       
        for (NSTextCheckingResult *matchPoint in matchesPoints) {
            NSRange matchPointRange = [matchPoint range];
            NSString *pointString = [lineString substringWithRange:matchPointRange];
            
            const char *cPointString = [pointString cStringUsingEncoding:NSUTF8StringEncoding];
            float x, y;
            sscanf(cPointString, "(%f,%f)", &x, &y);
            formerPoint = currentPoint;
            currentPoint.x = x;
            currentPoint.y = y;
            if (isFirstPoint) {
                isFirstPoint = NO;
            } else {
                Line line;
                line.from = formerPoint;
                line.to = currentPoint;
                line = scaleLine(line, width/virtualWidth);
                line = translateLine(line, x0, y0);
                NSValue *nsLine = [NSValue valueWithBytes:&line objCType:@encode(struct Line)];
                [lines addObject:nsLine];
            }
         }
    }
    return lines;
}


@end

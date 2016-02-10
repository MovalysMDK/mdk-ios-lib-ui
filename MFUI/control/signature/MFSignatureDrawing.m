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


#import "MFSignatureDrawing.h"
#import "MFSignatureHelper.h"
#import <QuartzCore/QuartzCore.h>


@implementation MFSignatureDrawing {
    CGPoint topLeftCorner, bottomRightCorner;
    CGPoint formerPoint;
    CGPoint currentPoint;
}

@synthesize lineWidth;
@synthesize strokeColor;
@synthesize signaturePath;

- (id) init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    signaturePath = [[NSMutableArray alloc] init];
    self.lineWidth = 3.0f;
    self.strokeColor = [UIColor blackColor];
    
    /*
    topLeftCorner.x = super.bounds.size.width;
    topLeftCorner.y = super.bounds.size.height;
    bottomRightCorner.x = 0;
    bottomRightCorner.y = 0;
     */
}

- (void) clear {
    signaturePath = [[NSMutableArray alloc] init];
    [self setNeedsDisplay];
}

// Drawing has to be done here
- (void) drawRect:(CGRect)rect {
    
    // Get graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Configure stroke style
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // Draw lines
    for (NSValue *nsLine in signaturePath) {
        struct Line couple;
        [nsLine getValue:&couple];
        [self drawLineFrom:couple.from to:couple.to context:context];
    }
    
    CGContextStrokePath(context);
}

- (void) drawLineFrom:(CGPoint)from to:(CGPoint)to context:(CGContextRef) context {
    CGContextMoveToPoint(context, from.x, from.y);  // Start at this point
    CGContextAddLineToPoint(context, to.x, to.y);   // Draw to this point
}


/*
- (void) updateRect: (CGPoint) point {
    topLeftCorner.x = (topLeftCorner.x > point.x) ? point.x : topLeftCorner.x;
    topLeftCorner.y = (topLeftCorner.y > point.y) ? point.y : topLeftCorner.y;
    bottomRightCorner.x = (bottomRightCorner.x < point.x) ? point.x : bottomRightCorner.x;
    bottomRightCorner.y = (bottomRightCorner.y < point.y) ? point.y : bottomRightCorner.y;
}
*/

- (void) setCurrentPoint: (CGPoint) point {
    currentPoint.x = point.x < 0 ? 0 : point.x;
    currentPoint.y = point.y < 0 ? 0 : point.y;
    currentPoint.x = point.x >= self.frame.size.width ? self.frame.size.width - 1 : point.x;
    currentPoint.y = point.y >= self.frame.size.height ? self.frame.size.height - 1 : point.y;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    [self setCurrentPoint:[touch locationInView:self]];
    
  //  [self updateRect: currentPoint];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled) {
        [super touchesMoved:touches withEvent:event];
        return;
    }

    formerPoint = currentPoint;
    UITouch *touch = [touches anyObject];
    [self setCurrentPoint:[touch locationInView:self]];
    //  [self updateRect: currentPoint];
    
    struct Line line;
    line.from = formerPoint;
    line.to = currentPoint;
    NSValue *nsLine = [NSValue valueWithBytes:&line objCType:@encode(struct Line)];
    [signaturePath addObject:nsLine];
    [self setNeedsDisplay];
 }

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    formerPoint = currentPoint;
    UITouch *touch = [touches anyObject];
    [self setCurrentPoint:[touch locationInView:self]];
    //  [self updateRect: currentPoint];
    
    struct Line line;
    line.from = formerPoint;
    line.to = currentPoint;
    NSValue *nsLine = [NSValue valueWithBytes:&line objCType:@encode(struct Line)];
    [signaturePath addObject:nsLine];
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled) {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    [self touchesEnded:touches withEvent:event];
}



@end

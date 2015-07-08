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
//  TextFieldCell.m
//  Step1
//
//

#import "MFCell1ComponentHorizontal.h"
#import "MFPosition.h"
#import "MFFormViewControllerProtocol.h"

@implementation MFCell1ComponentHorizontal


-(void)initialize {
    [super initialize];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    
    return self;
}

#pragma mark - MFUITransitionDelegate implementation

-(void) setTransitionDelegate:(id<MFUITransitionDelegate>)transitionDelegate
{
    if(self.componentView && [self.componentView conformsToProtocol:@protocol(MFUIComponentProtocol)])
    {
        id<MFUIComponentProtocol> protocol = (id<MFUIComponentProtocol>) self.componentView;
        protocol.transitionDelegate = transitionDelegate;
    }
}

-(id<MFUITransitionDelegate>) transitionDelegate
{
    if(self.componentView && [self.componentView conformsToProtocol:@protocol(MFUIComponentProtocol)])
    {
        id<MFUIComponentProtocol> protocol = (id<MFUIComponentProtocol>) self.componentView;
        return protocol.transitionDelegate;
    }
    else
    {
        return nil;
    }
}

/**
 * give the index path to the component too
 */
-(void)setCellIndexPath:(NSIndexPath *)cellIndexPath {
    
    [super setCellIndexPath:cellIndexPath];
    if(self.componentView && [self.componentView conformsToProtocol:@protocol(MFUIComponentProtocol)])
    {
        id<MFUIComponentProtocol> component = (id<MFUIComponentProtocol>) self.componentView;
        [component setComponentInCellAtIndexPath:cellIndexPath];
    }
}




@end

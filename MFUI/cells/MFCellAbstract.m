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

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreBean.h>

#import "MFCellAbstract.h"
#import <MFCore/MFCoreApplication.h>
#import "MFVersionManager.h"

@interface MFCellAbstract()


@end

@implementation MFCellAbstract

// Synthesizing protocols properties (Auto synthesizing will not work for protocol properties)
@synthesize transitionDelegate = _transitionDelegate;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize formController = _formController;
@synthesize hasChanged = _hasChanged;
@synthesize defaultConstraints = _defaultConstraints;
@synthesize savedConstraints = _savedConstraints;


#pragma mark - Initializing
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reportConstraintsOnCellContentView];
}


-(void)reportConstraintsOnCellContentView {
    NSMutableArray *allConstraints = [NSMutableArray array];
    // For each constraint applied to this cell from the Storyboard, we remove it and apply it to the
    // the contentView of the cell.
    for (NSLayoutConstraint *cellConstraint in self.constraints)
    {
        [self removeConstraint:cellConstraint];
        
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        
        NSLayoutConstraint* contentViewConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                                 attribute:cellConstraint.firstAttribute
                                                                                 relatedBy:cellConstraint.relation
                                                                                    toItem:seccondItem
                                                                                 attribute:cellConstraint.secondAttribute
                                                                                multiplier:cellConstraint.multiplier
                                                                                  constant:cellConstraint.constant];
        
        [allConstraints addObject:contentViewConstraint];
    }

    [self.contentView addConstraints:allConstraints];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Construction et initialisation
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}


-(void) initialize {
    self.hasChanged = NO;
    self.translatesAutoresizingMaskIntoConstraints = YES;
//    self.contentView.userInteractionEnabled = NO;
}

-(void) cellIsConfigured {
    //Nothing to do here/
}





#pragma mark - MFUITransitionDelegate implementation

-(void) setTransitionDelegate:(id<MFUITransitionDelegate>)transitionDelegate
{
    //A voir ce qu'il faut mettre ici
}

-(id<MFUITransitionDelegate>) transitionDelegate
{
    //A voir ce qu'il faut mettre ici
    return nil;
}




@end


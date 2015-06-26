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
#import <MFCore/MFCoreBean.h>


//Main interface
#import "MFBindingViewAbstract.h"


//Tils
#import "MFUILogging.h"

@protocol MFUIComponentProtocol;


@implementation MFBindingViewAbstract

@synthesize transitionDelegate = _transitionDelegate;
@synthesize cellIndexPath = _cellIndexPath;
@synthesize formController = _formController;
@synthesize hasChanged = _hasChanged;


#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}


-(void) initialize {
    //    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    for(UIView *subView in self.subviews) {
        if([subView conformsToProtocol:@protocol(MFUIComponentProtocol)]) {
            UIView<MFUIComponentProtocol> *baseComponent = (UIView<MFUIComponentProtocol> *)subView;
            [baseComponent setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
    }
    
}


#pragma mark - Custom methods
-(void)setParentEditable:(NSNumber *)parentEditable {
    _parentEditable = parentEditable;
    //On propage la valeur editable du parent sur les composant movalys fils de cette vue.
    for(UIView *subview in self.subviews) {
        if([subview conformsToProtocol:@protocol(MFUIComponentProtocol)]) {
            id<MFUIComponentProtocol> subComponent = (id<MFUIComponentProtocol>)subview;
//            subComponent.parentEditable = parentEditable;
        }
    }
}

#pragma mark - Not implemented





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

-(void)viewIsConfigured {
    //Nothing to do here
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end





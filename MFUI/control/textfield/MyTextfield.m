//
//  MyTextfield.m
//  MyFramework
//
//  Created by Lagarde Quentin on 08/01/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MyTextfield.h"

@interface MyTextfield ()

@property (nonatomic, strong) UITextField *innerTextField;

@end

@implementation MyTextfield

-(instancetype)init {
    self = [super init];
    if(self)
    {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
        [self initialize];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        
        [self initialize];
    }
    return self;
}

-(void) initialize {
    self.innerTextField = [[UITextField alloc] init];
    [self addSubview:self.innerTextField];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.innerTextField setFrame:CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2)];
    [self.innerTextField setBackgroundColor:self.myBackgroundColor];
}


@end

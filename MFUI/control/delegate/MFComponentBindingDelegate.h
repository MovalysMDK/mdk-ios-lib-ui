//
//  MFComponentBindingDelegate.h
//  MFUI
//
//  Created by Quentin Lagarde on 21/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MFUIComponentProtocol;
@protocol MFDescriptorCommonProtocol;


@interface MFComponentBindingDelegate : NSObject

-(instancetype)initWithComponent:(id<MFUIComponentProtocol>)component;

-(void) clearErrors;

-(void)dispatchEventOnValueChanged;
-(NSMutableArray *) getErrors;
-(void)addErrors:(NSArray *)errors;
-(void)setIsValid:(BOOL)isValid;
-(void)setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor;
-(void) onErrorButtonClick:(id)sender;
@end

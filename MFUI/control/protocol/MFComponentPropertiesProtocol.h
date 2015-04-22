//
//  MFComponentPropertiesProtocol.h
//  MFUI
//
//  Created by Quentin Lagarde on 21/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MFComponentPropertiesProtocol <NSObject>


/**
 Indique si le composant est obligatoire
 */
@property (nonatomic, strong) NSNumber *mandatory;

/**
 Indique si le composant est obligatoire
 */
@property (nonatomic) NSNumber *visible;

/**
 Indique si le composant est éditable
 */
@property (nonatomic) NSNumber *editable;

@end

//
//  MFBackgroundViewProtocol.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 17/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @protocol MFBackgroundViewProtocol
 * @brief This protocol declares a backgroundView property
 */
@protocol MFBackgroundViewProtocol <NSObject>

#pragma mark - Properties

/**
 * @brief A view that should be used as background
 */
@property (nonatomic, strong) UIView *backgroundView;

@end

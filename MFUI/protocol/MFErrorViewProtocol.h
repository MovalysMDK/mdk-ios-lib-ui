//
//  ErrorViewProtocol.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 16/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * @protocol MFErrorViewProtocol
 * @brief This protocol declares a errorView property
 */
@protocol MFErrorViewProtocol <NSObject>

#pragma mark - Properties

/**
 * @brief A view that should be used as error indicator/button
 */
@property (nonatomic, strong) UIView *errorView;

@end

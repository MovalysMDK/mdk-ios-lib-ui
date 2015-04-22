//
//  MFStyleProtocol.h
//  ComponentInherited
//
//  Created by Lagarde Quentin on 15/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @protocol MFStyleProtocol
 * @brief This protocol declares standars methods for MDK style classes
 * @discussion This protocol should be used to identy a style class.
 */
@protocol MFStyleProtocol <NSObject>

#pragma mark - Methods

/**
 * @brief This method should be called when the component that uses this
 * style class in an error state
 * @param component The component that is in an error state.
 */
-(void) applyErrorStyleOnComponent:(id)component;

/**
 * @brief This method should be called when the component that uses this
 * style class in an valid state
 * @param component The component that is in an valid state.
 */
-(void) applyValidStyleOnComponent:(id)component;

/**
 * @brief This method should be called when the component that uses this
 * style class in an standard state
 * @param component The component that is in an standard state.
 * @discussion A standard state does not mean valid/invalid state. 
 * This method should be always called before any method that applies a style,
 * even if the component has a valid or an invalid state.
 */
-(void) applyStandardStyleOnComponent:(id)component;

@end

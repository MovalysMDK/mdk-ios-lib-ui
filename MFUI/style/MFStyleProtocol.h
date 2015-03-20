//
//  MFStyleProtocol.h
//  Pods
//
//  Created by Quentin Lagarde on 19/03/2015.
//
//

#import <Foundation/Foundation.h>

@protocol MFStyleProtocol <NSObject>

@required
/**
 * @brief This method apply the base style on the given view
 * @param view The view the base style will be applied
 */
- (void)applyStyleOnView:(UIView *)view;

@required
/**
 * @brief This method apply the error style on the given view
 * @param view The view the error style will be applied
 */
- (void)applyErrorStyleOnView:(UIView *)view;

@required
/**
 * @brief This method apply the valid style on the given view
 * @param view The view the valid style will be applied
 */
- (void)applyValidStyleOnView:(UIView *)view;


@end

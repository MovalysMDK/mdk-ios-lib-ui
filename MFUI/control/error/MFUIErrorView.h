//
//  MFUIError.h
//  MFUI
//
//  Created by Quentin Lagarde on 12/03/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 * @class MFUIError
 * @brief This class represents the view that will display on MDK iOS 
 * components when they are in an invalid state.
 */
@interface MFUIErrorView : UIView

#pragma mark - IBOutlets

/**
 * @brief The error button the user will click to display error description
 */
@property (weak, nonatomic) IBOutlet UIButton *errorButton;


#pragma mark - IBAction

/**
 * @brief The action called when the user clicks the errorButton 
 * @param sender The sender of the action
 */
- (IBAction)onErrorButtonClick:(id)sender;

@end

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
//
//  MFRegularExpressionTextField.h
//  MFUI
//
//

#import "MFUIControlExtension.h"
//#import "MFUIError.h"
#import "MFUIControlButton.h"

#import "MFTextField+UITextFieldForwarding.h"

typedef MFNoMatchingValueUIValidationError* (^MFRegularExpressionTextFieldBuildErrorBlock)(NSString *localizedFieldName, NSString *technicalFieldName);

IB_DESIGNABLE

/**
 * UI control is composed of:
 * 1) Regular expression text field.
 * 2) Action button.
 **/
@interface MFRegularExpressionTextField : MFUIBaseComponent


#pragma mark - Constants
/**
 Default button width.
 */
extern CGFloat const MFRETFWAB_DEFAULT_ACTION_BUTTON_WIDTH;

/**
 Default button left margin.
 */
extern CGFloat const MFRETFWAB_DEFAULT_ACTION_BUTTON_LEFT_MARGIN;


#pragma mark - Properties 

/*
 Block used to build error.
 */
@property(nonatomic, strong) MFRegularExpressionTextFieldBuildErrorBlock errorBuilderBlock;

/**
 Regular expression text field where user keyboards data.
 */
@property(nonatomic, strong) MFUITextField* regularExpressionTextField;

/**
 Button where user taps to launch an action.
 */
@property(nonatomic, strong) MFButton* actionButton;


#pragma mark - IBInspectable properties

@property (nonatomic, strong) IBInspectable UIColor *IB_TextColor;
@property (nonatomic, strong) IBInspectable NSString *IB_uText;
@property (nonatomic) IBInspectable NSInteger IB_TextSize;


#pragma mark - Methods
/**
 Component init.
 */
-(void)initialize;

/**
 Verification run by the button when user touched inside up
 */
-(void)verify;

/**
 Action run when verification suceeded
 */
-(void)doAction;



#pragma mark - Specific regular expression text field properties

/**
 Regular expression used by the component to validate its value.
 */
@property(nonatomic, strong) NSString *pattern;

/**
 See the NSRegularExpressionOptions documentation for more information.
 */
@property(nonatomic) NSRegularExpressionOptions regularExpressionOptions;

/**
 See the NSMatchingOptions documentation for more information.
 */
@property(nonatomic) NSMatchingOptions matchingOptions;

#pragma mark - Specific button functions and properties

/**
 Button width.
 */
@property (nonatomic) CGFloat actionButtonWidth;

/**
 Button left margin.
 */
@property (nonatomic) CGFloat actionButtonLeftMargin;

/*
 URL used to call a phone number.
 */
@property(nonatomic, strong) NSString *urlSpecificField;


/**
 Set an image at button's center for normal ui control state.
 */
-(void) setButtonImage:(NSString *) imageName;

/**
 Set an image in button's bakground for normal ui control state.
 Scale the image if need.
 */
-(void) setButtonBackground:(NSString *) imageName;

#pragma mark - specific MFRegularExpressionTextField functions and properties
/**
 Show error message to user.
 */
-(void) showErrors;

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;


#pragma mark - Specific text field functions and properties

/**
 Set the keyboard type which will be displayed.
 */
-(void) setKeyboardType:(UIKeyboardType) type;

/**
 * @brief Set value of the field
 * @param value the value of the string 
 */
-(void) setValue:(NSString *) value;

/**
 * @brief Returns the value of the field
 * @return the value of the field
 */
-(NSString *) getValue;

/**
 * @brief Show or hide the ActionButton 
 * @param indicated if the action button should be displayed or not
 */
-(void) displayButton:(BOOL)shouldBeDisplayed;

/**
 * @brief Indicates if the component should show an action button
 */
-(BOOL) useActionButton;



@end

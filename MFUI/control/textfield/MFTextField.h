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
//  MFTextField.h
//  MFUI
//
//



#import <MFCore/MFCoreI18n.h>

#import "MFUIControlExtension.h"
#import "MFUIMotion.h"

#import "MFUIBaseComponent.h"



/**
 * This class implement fast forwarding to the inner UITextField.
 */
IB_DESIGNABLE
@interface MFTextField : MFUIBaseComponent<UITextFieldDelegate, MFOrientationChangedProtocol>


#pragma mark - Properties
/*
 Extended properties of text field.
 */
@property(nonatomic, strong) NSObject<MFExtensionKeyboardingUIControlProtocol> *mf;

/**
 Underlying component.
 */
@property(nonatomic, strong) UITextField *textField;

/**
 * @brief the delegate that manages orientation changes
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;


/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic, strong) IBInspectable UIColor *IB_textColor;

/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable int IB_textAlignment;

/**
 * @brief The placeholder of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic, strong) IBInspectable NSString *IB_placeholder;

/**
 * @brief The text size of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable int IB_textSize;

/**
 * @brief The text color of the component that implements this protocol.
 * @discussion This property is only used in InterfaceBuilder
 */
@property (nonatomic, strong) IBInspectable NSString *IB_unbindedText;
/**
 * @brief The border color of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic, strong) IBInspectable UIColor *IB_borderColor;

/**
 * @brief The border style of the component that implements this protocol.
 * @see UITextBorderStyle
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable int IB_borderStyle;

/**
 * @brief The border width of the component that implements this protocol.
 * @discussion This property is used both on InterfaceBuilder and on execution
 */
@property (nonatomic) IBInspectable CGFloat IB_borderWidth;



#pragma mark - Methods
/**
 * Load configuration according to the given name.
 *
 * @param configurationName - Name of the configuration to load.
 * @return Appropriate configuration.
 */
-(MFConfigurationKeyboardingUIComponent *) loadConfiguration:(NSString *) configurationName;



#pragma mark - Specific TextField method implementation

/**
 * @brief Set the type keyboard which will be displayed.
 * @param type The type of the keyboard
 */
-(void) setKeyboardType:(UIKeyboardType) type;

/**
 * @brief Set the main value for this component
 * @param value The value to set 
 */
-(void) setValue:(NSString *) value;

/**
 * @brief Returns the main value of this component
 * @return The value of the component
 */
-(NSString *) getValue;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer
#import "MFTextField+UITextFieldForwarding.h"

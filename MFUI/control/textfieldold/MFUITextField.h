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
#import "MFUIBaseRenderableComponent.h"



/**
 * This class implement fast forwarding to the inner UITextField.
 */
IB_DESIGNABLE
@interface MFUITextField : MFUIBaseRenderableComponent <UITextFieldDelegate, MFOrientationChangedProtocol>

#pragma mark - Properties

/**
 Underlying component.
 */
@property(nonatomic, weak) IBOutlet UITextField *textField;

/**
 * @brief the delegate that manages orientation changes
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;

@end


IB_DESIGNABLE

@interface MFUIInternalTextField : MFUITextField <MFInternalComponent>

@end



IB_DESIGNABLE

@interface MFUIExternalTextField : MFUITextField <MFExternalComponent>
@property(nonatomic, weak) IBOutlet UITextField *textField;


@property (nonatomic, strong) IBInspectable NSString *customXIBName;

@property (nonatomic, strong) IBInspectable NSString *customErrorXIBName;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////

// on met le header à la fin car la classe doit être déclarée avant la categorie.
// ne pas déplacer
#import "MFTextField+UITextFieldForwarding.h"

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
//  MFBarCodeScanTextField.m
//  MFUI
//
//

// Header import
#import "MFBarCodeScanTextField.h"

// Custom imports
#import "MFUIApplication.h"
#import "MFBarCodeScanViewController.h"


@interface MFBarCodeScanTextField ()

/**
 * @brief the private data set or to return from this component
 */
@property (nonatomic, strong) NSString *privateData;

/**
 * @brief the private data set or to return from this component
 */
@property (nonatomic, strong) UITextField *innerValueTextField;

/**
 * @brief the private data set or to return from this component
 */
@property (nonatomic, strong) UIButton *innerScanButton;

@end

static NSString const *NIL_DEBUG_VALUE = @"GET_NIL_VALUE";

@implementation MFBarCodeScanTextField


#pragma mark - MFUIBaseCompoennt - Initializing

-(void) initialize {
    [super initialize];
    [self initializeInnerComponents];
}

/**
 * @brief Initializing inner components of this component
 */
-(void) initializeInnerComponents {
    //Initializing inner label
    self.innerValueTextField = [[UITextField alloc] init];
    
    //Initializing inner button
    self.innerScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.innerScanButton setImage:[UIImage imageNamed:@"qr_code"] forState:UIControlStateNormal];
    
    [self addSubview:self.innerScanButton];
    [self addSubview:self.innerValueTextField];
    
    [self.innerScanButton addTarget:self action:@selector(onScanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self setInnerComponentsConstraints];
}

#pragma mark - Geometry

-(void) setInnerComponentsConstraints {
    self.innerValueTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.innerScanButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *innerTextFieldMarginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft  multiplier:1  constant:0];
    
    NSLayoutConstraint *innerTextFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField  attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0];
    
    NSLayoutConstraint *innerButtonMarginRightConstraint = [NSLayoutConstraint constraintWithItem:self.innerScanButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *verticalSpacingBetweenLabelAndButtonConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.innerScanButton attribute:NSLayoutAttributeLeft multiplier:1 constant:(self.frame.size.width)/20];
    
    NSLayoutConstraint *innerTextFieldTopMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *innerButtonTopMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerScanButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *innerTextFieldBottomMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *labelAndButtonHeightsEqualityConstraint = [NSLayoutConstraint constraintWithItem:self.innerValueTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.innerScanButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    
    [self addConstraints:@[
                           innerTextFieldMarginLeftConstraint,
                           innerTextFieldWidthConstraint,
                           innerButtonMarginRightConstraint,
                           verticalSpacingBetweenLabelAndButtonConstraint,
                           innerTextFieldTopMarginConstraint,
                           innerButtonTopMarginConstraint,
                           innerTextFieldBottomMarginConstraint,
                           labelAndButtonHeightsEqualityConstraint
                           ]];
}

#pragma mark - MFUIBaseCompoennt - Managing data

-(void)setData:(id)data {
    self.privateData = data;
}

-(id)getData {
    return self.privateData;
}


+ (NSString *)getDataType {
    return @"NSString";
}


-(void) updateValue {
    [self.sender performSelectorOnMainThread: @selector(updateValue:) withObject:_privateData waitUntilDone:YES];
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    if([self.mandatory isEqualToNumber:@1] && !_privateData) {
        
        NSError *error = [[MFMandatoryFieldUIValidationError alloc]
                          initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
#if DEBUG
    if([self.mandatory isEqualToNumber:@1] && _privateData && [NIL_DEBUG_VALUE isEqualToString:_privateData]) {
        
        NSError *error = [[MFMandatoryFieldUIValidationError alloc]
                          initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
#endif
    return nbOfErrors;
}

#pragma mark - MFUIBaseComponent customizing methods

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.innerValueTextField setEnabled:[editable isEqualToNumber:@1]];
    [self.innerScanButton setEnabled:[editable isEqualToNumber:@1]];
    
}

-(void)modifyComponentAfterHideErrorButtons {
    [super modifyComponentAfterHideErrorButtons];
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;
    self.innerValueTextField.frame = CGRectMake(0,
                                                0,
                                                self.innerValueTextField.frame.size.width+errorButtonSize,
                                                self.bounds.size.height);
    
}

-(void)modifyComponentAfterShowErrorButtons {
    
    [super modifyComponentAfterShowErrorButtons];
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;
    self.innerValueTextField.frame = CGRectMake(errorButtonSize,
                                      0,
                                      self.innerValueTextField.frame.size.width-errorButtonSize,
                                      self.innerValueTextField.frame.size.height);
}



#pragma mark - Custom MFBarCodeScanTextField methods

/**
 * @brief Method called when the user press the barCodeScann button of this component. 
 * This method pushes in the lastAppearViewController from MFUIapplication instance, a VideoCapture ViewController
 * that allows the user to scan a QRCode/BarCode.
 */
-(void) onScanButtonClicked {
    MFBarCodeScanViewController *scanViewController = [[MFBarCodeScanViewController alloc] initWithSourceComponent:self];
    [[[MFUIApplication getInstance] lastAppearViewController] presentViewController:scanViewController animated:YES completion:nil];
}

-(void) updateValueFromExternalSource:(NSString *)value {
    _privateData = value;
    [self.innerValueTextField setText:value];
    [self updateValue:_privateData];
}


#pragma mark - CSS customization

-(NSArray *)customizableComponents {
    return @[
             self.innerValueTextField,
             self.innerScanButton,
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             @"TextField",
             @"Button",
             ];
}

@end

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
//  MFNumberPicker.m
//  MFUI
//
//
#import <MFCore/MFCoreI18n.h>

#import "MFNumberPicker.h"
#import "MFIntegerTextField.h"

#pragma mark - Define some constants



@interface MFNumberPicker()

/**
 * @brief The inner texfield of this component that displays the number
 */
@property (nonatomic, strong) MFIntegerTextField *innerTextField;

/**
 * @brief The inner stepper used to choose the value of the stepper.
 */
@property (nonatomic, strong) UIStepper *innerStepper;


/**
 * @brief The minus button item of the button bar above the number keyboard
 */
@property (nonatomic, strong) UIBarButtonItem *minusButton;

/**
 * @brief The ok button item of the button bar above the number keyboard
 */
@property (nonatomic, strong) UIBarButtonItem *okButton;

@end


//Parameters keys
NSString *const NUMBER_PICKER_PARAMETER_MAX_VALUE_KEY = @"maxValue";
NSString *const NUMBER_PICKER_PARAMETER_MIN_VALUE_KEY = @"minValue";
NSString *const NUMBER_PICKER_PARAMETER_STEP_KEY = @"step";

@implementation MFNumberPicker
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize defaultConstraints = _defaultConstraints;
@synthesize savedConstraints= _savedConstraints;



#pragma mark - Initializing

-(void)initialize {
    
    //Create inner components
    self.innerTextField = [[MFIntegerTextField alloc] initWithFrame:self.frame];
    self.innerStepper = [[UIStepper alloc] init];
    
    //Add inner components
    [self addSubview:self.innerStepper];
    [self addSubview:self.innerTextField];
    
    //super initialize
    [super initialize];
    
    self.step = 1;
    self.minimalValue = INT32_MIN;
    self.maximalValue = INT32_MAX;
    
    [self.innerTextField addTarget:self action:@selector(updateValue) forControlEvents:UIControlEventEditingChanged];
    [self.innerStepper addTarget:self action:@selector(stepperValueChanged) forControlEvents:UIControlEventValueChanged];
}



/**
 * @brief Méthode appelée lors du clic sur le bouton pour effacer tout le texte associé au clavier
 *
 */

-(IBAction)barButtonClearText:(UIBarButtonItem*)sender
{
    if ([self.innerTextField isFirstResponder]) {
        //Le texte est supprimé
        self.innerTextField.text = @"";
        //Mise à jour du view modèle car la méthode de delegate textViewDidChange n'est pas appelée lorsque la valeur du texte
        //est modifiée programmaticallement
        [self updateValue];
    }
}


/**
 * @brief Méthode appelée lors du clic sur le bouton "OK" associé au clavier
 *
 */

-(IBAction)barButtonDismissKeyboard:(UIBarButtonItem*)sender
{
    if ([self.innerTextField isFirstResponder]) {
        //Le clavier est masqué
        [self.innerTextField endEditing:YES];
    }
}



#pragma mark - MFDefaultConstraintsProtocol method

-(void)applyDefaultConstraints {
    
    NSInteger componentsMargin = 10;
    
    self.innerTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.innerStepper.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Inner TextField Constraints
    NSLayoutConstraint *textFieldTopMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *textFieldLeftMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *textFieldBottomMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *textFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:self.innerTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:(-self.innerStepper.frame.size.width -componentsMargin)];
    
    
    //Inner TextField Constraints
    NSLayoutConstraint *stepperCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.innerStepper attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.innerTextField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *stepperLeftMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerStepper attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.innerTextField attribute:NSLayoutAttributeRight multiplier:1 constant:10];
    NSLayoutConstraint *stepperRightMarginConstraint = [NSLayoutConstraint constraintWithItem:self.innerStepper attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self addConstraints:@[textFieldTopMarginConstraint, textFieldLeftMarginConstraint, textFieldBottomMarginConstraint, textFieldWidthConstraint,
                           stepperCenterYConstraint, stepperLeftMarginConstraint, stepperRightMarginConstraint]];
    
    if(!self.savedConstraints) {
        self.savedConstraints = [NSMutableDictionary dictionaryWithObject:textFieldLeftMarginConstraint forKey:@"textFieldLeftMarginConstraint"];
        [self.savedConstraints setObject:textFieldWidthConstraint forKey:@"textFieldWidthConstraint"];
    }
}



#pragma mark - MFUIComponentProtocol inherited methods

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    NSNumber *minValueNumber = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:NUMBER_PICKER_PARAMETER_MIN_VALUE_KEY];
    NSNumber *maxValueNumber = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:NUMBER_PICKER_PARAMETER_MAX_VALUE_KEY];
    NSNumber *stepNumber = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:NUMBER_PICKER_PARAMETER_STEP_KEY];
    
    if(minValueNumber) {
        self.minimalValue = minValueNumber.integerValue;
    }
    
    if(maxValueNumber) {
        self.maximalValue = maxValueNumber.integerValue;
    }
    
    if(stepNumber) {
        self.step = stepNumber.integerValue;
    }
}

-(void)setData:(id)data {
    self.currentValue = [data integerValue];
    [self.innerTextField setData:[NSString stringWithFormat:@"%d", self.currentValue]];
}

-(id)getData {
    return @(self.currentValue);
}

+ (NSString *) getDataType {
    return @"NSNumber";
}


#pragma mark - InnerTextField events

-(void) updateValue {
    self.currentValue = [[self.innerTextField getData] integerValue];
    [self validateWithParameters:nil];
    [self updateValue:[self getData]];
}




-(void)setCurrentValue:(NSInteger)currentValue {
    _currentValue = currentValue;
    self.innerStepper.value = currentValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.innerTextField setData:@(currentValue).description];
    });
}

-(void)setMinimalValue:(NSInteger)minimalValue {
    _minimalValue = minimalValue;
    self.innerStepper.minimumValue = minimalValue;
}

-(void)setMaximalValue:(NSInteger)maximalValue {
    _maximalValue = maximalValue;
    self.innerStepper.maximumValue = maximalValue;
}

-(void)setStep:(NSInteger)step {
    _step = step;
    self.innerStepper.stepValue = step;
}

#pragma mark - Inner Stepper events

-(void) stepperValueChanged {
    [self.innerTextField setData:[NSString stringWithFormat:@"%@", @(self.innerStepper.value)]];
    [self becomeFirstResponder];
    [self.innerTextField resignFirstResponder];
    [self updateValue];
}


#pragma mark - UITextField Delegate


-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if ([self number:@(self.currentValue) isEqualToString:[self.innerTextField getData]]) {
        NSError *error = [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}

-(BOOL)number:(NSNumber *)number isEqualToString:(NSString *)string {
    BOOL result = NO;
    if(string.length > 0) {
        BOOL isMinus = ([string characterAtIndex:0] == '-');
        int numberOfZerosToRemove = 0;
        for(int index = isMinus ? 1 : 0; index < string.length ; index++) {
            if([string characterAtIndex:index] == '0') {
                numberOfZerosToRemove++;
            }
            else {
                break;
            }
        }
        string = [string substringFromIndex:((isMinus ? 1 : 0) + numberOfZerosToRemove)];
        if(string.length == 0) {
            string = @"0";
        }
        if(isMinus && ![string isEqualToString:@"0"]) {
            string = [NSString stringWithFormat:@"-%@", string];
            
        }
        
        result = ![string isEqualToString:[NSString stringWithFormat:@"%@", number]];
        
    }
    else {
        result = [self.mandatory boolValue];
    }
    return result;
}

@end


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
@property (nonatomic, strong) MFUITextField *innerTextField;

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
@synthesize context = _context;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize applicationContext = _applicationContext;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize defaultConstraints = _defaultConstraints;
@synthesize savedConstraints= _savedConstraints;



#pragma mark - Initializing

-(void)initialize {
    
    //Create inner components
    self.innerTextField = [[MFUITextField alloc] initWithFrame:self.frame withSender:self];
    self.innerStepper = [[UIStepper alloc] init];
    
    //Add inner components
    [self addSubview:self.innerStepper];
    [self addSubview:self.innerTextField];
    
    //Customize inner components
    [self.innerTextField.textField setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self customizeKeyboard];
    
    //super initialize
    [super initialize];
    
    self.step = 1;
    self.minimalValue = INT32_MIN;
    self.maximalValue = INT32_MAX;
    
    [self.innerTextField.textField addTarget:self action:@selector(updateValue) forControlEvents:UIControlEventEditingChanged];
    [self.innerStepper addTarget:self action:@selector(stepperValueChanged) forControlEvents:UIControlEventValueChanged];
}


-(void) customizeKeyboard {
    //Si on est pas sur iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        
        //Sur le téléphone, le clavier "décimal" ne propose pas le signe "-" : on l'ajoute via
        //une barre de boutons personnalisée.
        
        //On créé la barre de boutons personnalisée pour l'ajouter au clavier
        //Cette barre contient les caractères supplémentaires nécessaires (ici le caractère -)
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         self.frame.size.width,
                                                                         44.0f)];
        
        
        toolBar.tintColor = [UIColor colorWithRed:0.56f
                                            green:0.59f
                                             blue:0.63f
                                            alpha:1.0f];
        
        toolBar.translucent = NO;
        
        self.minusButton = [[UIBarButtonItem alloc] initWithTitle:@"-"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(barButtonAddText:)];
        
        self.okButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"okButton")
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(barButtonDismissKeyboard:)];
        toolBar.items =   @[self.minusButton,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil],
                            self.okButton
                            ];
        
        
        
        
        //La barre de boutons personnalisée est ajoutée au clavier.
        self.innerTextField.textField.inputAccessoryView = toolBar;
    }
    
    [self.innerTextField.textField setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.innerTextField.textField setDelegate:self];
}

/**
 * @brief Méthode appelée lors du clic sur le bouton pour effacer tout le texte associé au clavier
 *
 */

-(IBAction)barButtonClearText:(UIBarButtonItem*)sender
{
    if ([self.innerTextField.textField isFirstResponder]) {
        //Le texte est supprimé
        self.innerTextField.textField.text = @"";
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
    if ([self.innerTextField.textField isFirstResponder]) {
        //Le clavier est masqué
        [self.innerTextField.textField endEditing:YES];
    }
}


/**
 * @brief Méthode appelée lors du clic sur un bouton de la barre de boutons personnalisées associée au clavier
 *
 */

-(IBAction)barButtonAddText:(UIBarButtonItem*)sender
{
    if (self.innerTextField.textField.isFirstResponder && [self.innerTextField.textField.text rangeOfString:sender.title].location == NSNotFound)
    {
        //On insère le caractère cliqué
        [self.innerTextField.textField insertText:sender.title];
    }
}

-(void) toogleMinusButton {
    self.minusButton.enabled = (self.innerTextField.text.length == 0);
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



#pragma mark - MFUIBaseComponents inherited methods

-(void)didFinishLoadDescriptor {
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
    [self validate];
    [self updateValue:[self getData]];
    [self toogleMinusButton];
}




-(void)setCurrentValue:(NSInteger)currentValue {
    _currentValue = currentValue;
    self.innerStepper.value = currentValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.innerTextField setData:@(currentValue)];
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
    [self.innerTextField.textField resignFirstResponder];
    [self updateValue];
}


#pragma mark - UITextField Delegate


-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if ([self number:@(self.currentValue) isEqualToString:[self.innerTextField getData]]) {
        NSError *error = [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
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


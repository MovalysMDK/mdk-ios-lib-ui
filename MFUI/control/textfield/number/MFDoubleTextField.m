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
//  MFDoubleTextField.m
//  MFUI
//
//

#import "MFDoubleTextField.h"
#import <MFCore/MFCoreI18n.h>

@implementation MFDoubleTextField

@synthesize integerPartMinDigits;
@synthesize integerPartMaxDigits;
@synthesize decimalPartMinDigits;
@synthesize decimalPartMaxDigits;

NSString *const MF_LIVERENDERING_DEFAULT_DOUBLE_VALUE = @"18,5";

-(void) initialize
{
    
    
    [super initialize];
#if !TARGET_INTERFACE_BUILDER
    [self setAllTags];
    
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError *(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFInvalidDoubleValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    self.applicationContext = [MFApplication getInstance];
    
    //Le UIKeyboardTypeDecimalPad n'est pas disponible sur l'iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self setKeyboardType:UIKeyboardTypeNumberPad];
    }
    else
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
        toolBar.items =   @[ [[UIBarButtonItem alloc] initWithTitle:@"-"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(barButtonAddText:)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"okButton")
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(barButtonDismissKeyboard:)]
                             ];
        
        
        [self setKeyboardType:UIKeyboardTypeDecimalPad];
        
        //La barre de boutons personnalisée est ajoutée au clavier.
        self.regularExpressionTextField.textField.inputAccessoryView = toolBar;
        
    }
    
    //Initialisation par défaut : pas de nombres minimum et maximum de chiffres spécifié
    self.integerPartMinDigits = nil;
    self.integerPartMaxDigits = nil;
    self.decimalPartMinDigits = nil;
    self.decimalPartMaxDigits = nil;
    
    //La regex de vérification est initialisée par défaut.
    //Cela permet une utilisation du composant indépendante d'un PLIST
    [self createPattern];
    
    self.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"enterNumber");
    
#else
#endif
}


/**
 * @brief Méthode appelée lors du clic sur un bouton "OK" de la barre de boutons personnalisées associée au clavier
 *
 */

-(IBAction)barButtonDismissKeyboard:(UIBarButtonItem*)sender
{
    if (self.regularExpressionTextField.textField.isFirstResponder)
    {
        //On ferme le clavier
        [self.regularExpressionTextField.textField endEditing:YES];
    }
}


/**
 * @brief Méthode appelée lors du clic sur le bouton "-" de la barre de boutons personnalisées associée au clavier
 *
 */

-(IBAction)barButtonAddText:(UIBarButtonItem*)sender
{
    if (self.regularExpressionTextField.textField.isFirstResponder)
    {
        //On insère le caractère cliqué
        [self.regularExpressionTextField.textField insertText:sender.title];
    }
}

-(MFNoMatchingValueUIValidationError *) buildError
{
    return [[MFInvalidDoubleValueUIValidationError alloc] initWithLocalizedFieldName:[self localizedFieldDisplayName] technicalFieldName:self.selfDescriptor.name];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.regularExpressionTextField.textField.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFTEXTFIELD_TEXTFIELD
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD) {
        [self.regularExpressionTextField.textField setTag:TAG_MFDOUBLETEXTFIELD_TEXTFIELD];
    }
    if (self.actionButton.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON) {
        [self.actionButton setTag:TAG_MFDOUBLETEXTFIELD_ACTIONBUTTON];
    }
}


#pragma mark - specific UITextField functions

-(id<UITextFieldDelegate>) delegate
{
    return self.regularExpressionTextField.delegate;
}

-(void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.regularExpressionTextField.delegate = delegate;
}

-(void)setMandatory:(NSNumber *)mandatory {
    [self.regularExpressionTextField setMandatory:mandatory];
}

-(void)hideErrorButtons {
    [super hideErrorButtons];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.regularExpressionTextField setEditable:editable];
}

-(BOOL)useActionButton {
    return NO;
}


-(void)didFinishLoadDescriptor {
    
    [super didFinishLoadDescriptor];
    
    //Biding des propriétés
    self.integerPartMinDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"integerPartMinDigits"];
    self.integerPartMaxDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"integerPartMaxDigits"];
    self.decimalPartMinDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"decimalPartMinDigits"];
    self.decimalPartMaxDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"decimalPartMaxDigits"];
    
    //La regex de vérification est créée en prenant compte les valeurs spécifiées dans le PLIST
    [self createPattern];
    
}

- (void)createPattern {
    
    
    //Construction de la regex de vérification en fonction des propriétés du PLIST
    NSString *quantificateurPartieEntiere;
    NSString *quantificateurPartieDecimale;
    
    //Génération des quantificateurs
    
    //Si un nombre minimum de chiffres pour la partie entière est spécifié (et différent de zéro)
    if (self.integerPartMinDigits != nil && ![self.integerPartMinDigits isEqualToString:@""]
        && [self.integerPartMinDigits intValue] != 0) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@,", self.integerPartMinDigits];
        //Autrement, il faudra saisir au moins un chiffre
    } else {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"1,"];
    }
    
    //Si un nombre maximum de chiffres pour la partie entière est spécifié (et différent de zéro) et qu'il est
    //supérieur au nombre minimum
    if (self.integerPartMaxDigits != nil && ![self.integerPartMaxDigits isEqualToString:@""]
        && [self.integerPartMaxDigits intValue] != 0 && [self.integerPartMaxDigits intValue] >= [self.integerPartMinDigits intValue]) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@%@", quantificateurPartieEntiere, self.integerPartMaxDigits];
    }
    
    //Si un nombre minimum de chiffres pour la partie décimale est spécifié
    if (self.decimalPartMinDigits != nil && ![self.decimalPartMinDigits isEqualToString:@""]) {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"%@,", self.decimalPartMinDigits];
        //Autrement, il faudra saisir au moins un chiffre
    } else {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"1,"];
    }
    
    //Si un nombre maximum de chiffres pour la partie décimale est spécifié et qu'il est supérieur au nombre minimum
    if (self.decimalPartMaxDigits != nil && ![self.decimalPartMaxDigits isEqualToString:@""]
        && [self.decimalPartMaxDigits intValue] >= [self.decimalPartMinDigits intValue]) {
        quantificateurPartieDecimale = [NSString stringWithFormat:@"%@%@", quantificateurPartieDecimale, self.decimalPartMaxDigits];
    }
    
    //Génération de la regex de vérification
    self.pattern = [NSString stringWithFormat:@"^-?[0-9]{%@}([,][0-9]{%@})?$", quantificateurPartieEntiere, quantificateurPartieDecimale];
    
}

#pragma mark - Validation API

-(NSInteger) validateWithParameters:(NSDictionary *)parameters
{
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if ([self.getValue doubleValue] > DBL_MAX) {
        NSError *error = [[MFInvalidDoubleValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    return nbOfErrors;
}

#pragma mark - Live Rendering methods

-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    if(!self.IB_enableIBStyle) {
        self.regularExpressionTextField.text = MF_LIVERENDERING_DEFAULT_DOUBLE_VALUE;
    }
}

@end

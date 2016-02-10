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
//  MFIntegerTextField.m
//  MFUI
//
//

#import "MFIntegerTextField.h"
#import <MFCore/MFCoreI18n.h>

@implementation MFIntegerTextField

@synthesize minDigits;
@synthesize maxDigits;


#pragma mark - Initializing

-(void) initialize
{
    [super initialize];
    [self setAllTags];
    
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError *(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    self.applicationContext = [MFApplication getInstance];
    
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
        
        
        
        
        //La barre de boutons personnalisée est ajoutée au clavier.
        self.regularExpressionTextField.textField.inputAccessoryView = toolBar;
    }
    
    [self setKeyboardType:UIKeyboardTypeNumberPad];
    
    //Initialisation par défaut : pas de nombres minimum et maximum de chiffres spécifié
    self.minDigits = nil;
    self.maxDigits = nil;
    
    //La regex de vérification est crée par défaut.
    //Cela permet une utilisation du composant indépendante d'un PLIST
    [self createPattern];
    
    self.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"enterNumber");
    
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
 * @brief Méthode appelée lors du clic sur un bouton de la barre de boutons personnalisées associée au clavier
 *
 */

-(IBAction)barButtonAddText:(UIBarButtonItem*)sender
{
    if (self.regularExpressionTextField.textField.isFirstResponder  && [self.regularExpressionTextField.textField.text rangeOfString:sender.title].location == NSNotFound)
    {
        //On insère le caractère cliqué
        [self.regularExpressionTextField.textField insertText:sender.title];
    }
}

-(MFNoMatchingValueUIValidationError *) buildError
{
    return [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:[self localizedFieldDisplayName] technicalFieldName:self.selfDescriptor.name];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.regularExpressionTextField.textField.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFTEXTFIELD_TEXTFIELD
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD) {
        [self.regularExpressionTextField.textField setTag:TAG_MFINTEGERTEXTFIELD_TEXTFIELD];
    }
    if (self.actionButton.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON) {
        [self.actionButton setTag:TAG_MFINTEGERTEXTFIELD_ACTIONBUTTON];
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
    self.minDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"minDigits"];
    self.maxDigits = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"maxDigits"];
    
    //La regex de vérification est créée en prenant compte les valeurs spécifiées dans le PLIST
    [self createPattern];
    
}

- (void)createPattern {
    
    //Construction de la regex de vérification en fonction des propriétés du PLIST
    NSString *quantificateurPartieEntiere;
    
    //Génération des quantificateurs
    
    //Si un nombre minimum de chiffres pour la partie entière est spécifié (et différent de zéro)
    if (self.minDigits != nil && ![self.minDigits isEqualToString:@""]
        && [self.minDigits intValue] != 0) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@,", self.minDigits];
        //Autrement, il faudra saisir au moins un chiffre
    } else {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"1,"];
    }
    
    //Si un nombre maximum de chiffres pour la partie entière est spécifié (et différent de zéro) et qu'il est
    //supérieur au nombre minimum
    if (self.maxDigits != nil && ![self.maxDigits isEqualToString:@""]
        && [self.maxDigits intValue] != 0 && [self.maxDigits intValue] >= [self.minDigits intValue]) {
        quantificateurPartieEntiere = [NSString stringWithFormat:@"%@%@", quantificateurPartieEntiere, self.maxDigits];
    }
    
    //Génération de la regex de vérification
    self.pattern = [NSString stringWithFormat:@"^-?[0-9]{%@}$", quantificateurPartieEntiere];
}

#pragma mark - Validation API

-(NSInteger) validateWithParameters:(NSDictionary *)parameters
{
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if ([self.getValue longLongValue] > INT32_MAX) {
        NSError *error = [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}

@end

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

#import "MFIntegerTextField.h"
#import "MFInvalidIntegerValueUIValidationError.h"
@import MFCore.MFLocalizedString;

@interface MFIntegerTextField ()

@property (nonatomic, strong) NSString *minDigits;
@property (nonatomic, strong) NSString *maxDigits;

@property (nonatomic, strong) NSString *pattern;

@end

@implementation MFIntegerTextField

-(NSString *)regex {
    return self.pattern;
}


-(void)initializeComponent {
    [super initializeComponent];
    [self customizeKeyboard];
}


-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
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
        
        UIBarButtonItem *minusButton = [[UIBarButtonItem alloc] initWithTitle:@"—"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(signButtonClick:)];
        minusButton.tintColor = [UIColor blackColor];
        
        
        UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"okButton")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(okButtonClick:)];
        okButton.tintColor = [UIColor blackColor];
        
        toolBar.items =   @[minusButton,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil],
                            okButton
                            ];
        
        //La barre de boutons personnalisée est ajoutée au clavier.
        self.inputAccessoryView = toolBar;
    }
}

-(void) signButtonClick:(UIBarButtonItem *)sender {
    if([sender.title isEqualToString:@"—"]) {
        [self setData:[NSString stringWithFormat:@"-%@", [self getData]]];
        sender.title = @"+";
    }
    else {
        if([[self getData] containsString:@"-"]) {
            [self setData:[[self getData] substringFromIndex:1]];
        }
        sender.title = @"—";
    }
    [self performSelector:@selector(updateValue)];
}


-(void) okButtonClick:(id)sender {
    [self resignFirstResponder];
}

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    
    [super didLoadFieldDescriptor:fieldDescriptor];
    
    //Biding des propriétés
    self.minDigits = [fieldDescriptor.parameters objectForKey:@"minDigits"];
    self.maxDigits = [fieldDescriptor.parameters objectForKey:@"maxDigits"];
    
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


#pragma mark - Validation
-(NSInteger) validateWithParameters:(NSDictionary *)parameters
{
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    
    if ([[self getData] longLongValue] > INT32_MAX || [[self getData] longLongValue] < INT32_MIN) {
        NSError *error = [[MFInvalidIntegerValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}

@end

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


#import "MFDoubleTextField.h"
#import "MFInvalidDoubleValueUIValidationError.h"
#import "MFMandatoryFieldUIValidationError.h"

@import MFCore.MFLocalizedString;

@interface MFDoubleTextField ()

@property (nonatomic, strong) UIBarButtonItem *minusButton;

@property (nonatomic, strong) NSString *pattern;

@end


@implementation MFDoubleTextField


-(NSString *)regex {
    return self.pattern;
}

-(void)initializeComponent {
    [super initializeComponent];
    [self customizeKeyboard];
}


-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeDecimalPad;
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
        
        self.minusButton = [[UIBarButtonItem alloc] initWithTitle:([self.text rangeOfString:@"-"].location != NSNotFound) ? @"+" :@"—"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(signButtonClick:)];
        self.minusButton.tintColor = [UIColor blackColor];
        
        
        UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"okButton")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(okButtonClick:)];
        okButton.tintColor = [UIColor blackColor];
        
        toolBar.items =   @[self.minusButton,
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
        if([[self getData] rangeOfString:@"-"].location != NSNotFound) {
            [self setData:[[self getData] substringFromIndex:1]];
        }
        sender.title = @"—";
    }
}


-(void) okButtonClick:(id)sender {
    [self resignFirstResponder];
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

-(void)setData:(id)data {
    [super setData:data];
    if([data rangeOfString:@"-"].location != NSNotFound) {
        [self.minusButton setTitle:@"+"];
    }
    else {
        [self.minusButton setTitle:@"—"];
    }
}

//PROTODO :
//integerPartMinDigits
//integerPartMaxDigits
//decimalPartMinDigits
//decimalPartMaxDigits




@end

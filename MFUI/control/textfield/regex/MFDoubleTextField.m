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
#import "MFDoubleFieldValidator.h"

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
    [self valueChanged:self];
}


-(void) okButtonClick:(id)sender {
    [self resignFirstResponder];
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

-(NSArray *)controlValidators {
    return @[[MFDoubleFieldValidator sharedInstance]];
}


-(void)prepareForInterfaceBuilder {
    self.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    UILabel *innerDescriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    innerDescriptionLabel.text = [[self class] description];
    innerDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    innerDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self addSubview:innerDescriptionLabel];
}

@end

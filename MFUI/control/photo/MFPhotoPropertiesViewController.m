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
//  AdditionalDataViewController.m
//  navigation
//
//

#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>

#import "MFPhotoPropertiesViewController.h"
#import "UIViewController+MFViewControllerUtils.h"
#import "MFVersionManager.h"
#import "MFUILog.h"
#import "MFPhotoViewModel.h"

#define kOFFSET_FOR_KEYBOARD 90.0

@interface MFPhotoPropertiesViewController()


/**
 * @brief Le ViewModel décrivant les propriétés de la photo
 */
@property (nonatomic, strong) MFPhotoViewModel *photoViewModel;

@end

@implementation MFPhotoPropertiesViewController

#pragma mark - Controller initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void) initialize
{
    //Nothing to do here. Won't call super.
}

#pragma mark - Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Initialisation des boutons de la barre de navigation
    [self.backButton setTitle:MFLocalizedStringFromKey(@"form_cancel")];
    [self.doneButton setTitle:MFLocalizedStringFromKey(@"error_nosettingsparameterized_quitbutton")];
    [self setTitle:MFLocalizedStringFromKey(@"photoControllerDetailsTitle")];

    //Chargement des données à partir du view model
    self.descriptionField.text = self.photoViewModel.descr;
    self.titreField.text = self.photoViewModel.titre;
    self.dateField.text = [self.photoViewModel getDateStringFormat:@"dd/MM/yyyy HH:mm"];

    if (self.photoViewModel.position.latitude && self.photoViewModel.position.longitude) {

        self.positionField.enabled = YES;
        MFPositionViewModel *positionViewModel = [[MFPositionViewModel alloc] init];
        positionViewModel.latitude = self.photoViewModel.position.latitude;
        positionViewModel.longitude = self.photoViewModel.position.longitude;

        [self.positionField setData:positionViewModel];
        //Si les coordonnées ne sont pas renseignées, on ne peut pas afficher la carte
    } else if (self.photoViewModel.position.latitude == nil && self.photoViewModel.position.longitude == nil) {
        self.positionField.enabled = NO;
    }

    //Les champs de position ne sont pas modifiables dans tous les cas
    [self.positionField setEditable:@0];

    //Données non modifiables si le composant n'est pas éditable
    if (!self.donneesEditables) {
//        [self.titreField setEditable:@0];
//        [self.descriptionField setEditable:@0];
    }

    self.dateLabel.text = MFLocalizedStringFromKey(@"photoThumbnail_date_label");
    self.descriptionLabel.text = MFLocalizedStringFromKey(@"photoThumbnail_description_label");
    self.titleLabel.text = MFLocalizedStringFromKey(@"photoThumbnail_title_label");
    self.localisationLabel.text = MFLocalizedStringFromKey(@"photoThumbnail_localisation_label");
}



- (void)viewWillAppear:(BOOL)animated
{
    //Si on est sur iPhone, on va gérer le décalage des champs de texte lors de l'utilisation
    //du clavier (pour éviter qu'ils soient masqués)
    //Cela signifie l'enregistrement du contrôleur courant comme observateur des évènements d'apparition
    //et de disparition du clavier.
    if ([MFVersionManager isCurrentDeviceOfTypePhone]) {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    //Si on est sur iPhone, lorsqu'on quitte la vue, il faut supprimer le contrôleur
    //courant comme observateur des évènements d'apparition et de disparition du clavier.
    if ([MFVersionManager isCurrentDeviceOfTypePhone]) {
        
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Keyboard management


/**
 * @brief Méthode appelée quand le clavier a été demandé
 */

- (void)keyboardWillShow
{
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0)  {
        [self setViewMovedUp:NO];
    }
}


/**
 * @brief Méthode appelée quand on a terminé d'utiliser le clavier
 */

- (IBAction)keyboardWillHide
{
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0)  {
        [self setViewMovedUp:NO];
    }
}



#pragma mark - Hiding DetailController

-(IBAction) saveAndCloseController:(id)sender {
    //Mise à jour du view model avec les données du formulaire
    self.photoViewModel.titre = self.titreField.text;
    self.photoViewModel.descr = self.descriptionField.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *dateFromString = [dateFormatter dateFromString:self.dateField.text];
    
    self.photoViewModel.date = dateFromString;
    
    //On quitte le formulaire
    [self closeController:self.doneButton];
}

-(void) closeController:(id)sender {
    //On fait disparaître le formulaire.
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - View management


/**
 * @brief Cette méthode gère le décalage de la vue lors de l'utilisation du clavier
 */

- (void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }else {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}






#pragma mark - MFViewControllerProtocol implementation

- (IBAction)genericButtonPressed:(id)sender
{
    [[self extendsMFViewController].viewControllerDelegate genericButtonPressed:sender];
}


- (void) showWaitingView
{
    [[self extendsMFViewController ].viewControllerDelegate showWaitingView];
}


- (void) showWaitingViewWithMessageKey:(NSString *)key
{
    [[self extendsMFViewController ].viewControllerDelegate showWaitingViewWithMessageKey:key];
}


- (void) dismissWaitingView
{
    [[self extendsMFViewController].viewControllerDelegate dismissWaitingView];
}


- (void) showWaitingViewDuring:(int)seconds
{
    [[self extendsMFViewController].viewControllerDelegate showWaitingViewDuring:seconds];
}

- (void) didPressMapButton:(CLLocation *)location
{
    MFCoreLogVerbose(@"MFPhotoPropertiesViewController didPressMapButton does nothing (lat:%f,long:%f)",
                     location.coordinate.latitude , location.coordinate.longitude );
}

-(void) setPhotoViewModel:(MFPhotoViewModel *)photoViewModel {
    _photoViewModel = photoViewModel;
}


@end

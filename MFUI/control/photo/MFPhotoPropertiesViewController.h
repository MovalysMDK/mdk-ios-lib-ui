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
//  MFPhotoPropertiesViewController.h
//  navigation
//
//


#import "MFPosition.h"
#import "MFMapViewController.h"
#import "MFViewControllerProtocol.h"
#import "MFUIBaseViewModel.h"

@interface MFPhotoPropertiesViewController : UIViewController<MFViewControllerProtocol>

#pragma mark - Properties

/**
 * @brief Le label au dessus du composant dateField
 */
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

/**
 * @brief Le label au dessus du composant positionField
 */
@property (strong, nonatomic) IBOutlet UILabel *localisationLabel;

/**
 * @brief Le label au dessus du composant titreField
 */
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

/**
 * @brief Le label au dessus du composant descriptionField
 */
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;


/**
 * @brief Le composant affichant la date de la photo
 */
@property (weak, nonatomic) IBOutlet UILabel *dateField;

/**
 * @brief Le composant affichant le titre de la photo
 */
@property (weak, nonatomic) IBOutlet MFUITextField *titreField;

/**
 * @brief Le composant affichant la description de la photo
 */
@property (weak, nonatomic) IBOutlet MFUITextField *descriptionField;

/**
 * @brief Le composant affichant la localisation de la photo
 */
@property (weak, nonatomic) IBOutlet MFPosition *positionField;


/**
 * @brief Le bouton d'annulation
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

/**
 * @brief Le bouton de validation du formulaire
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

/**
 * @brief Un booléen qui indique si les données du formulaire sont éditables
 */
@property (nonatomic, assign) BOOL donneesEditables;



#pragma mark - IBActions

/**
 * @brief IBAction de sauvegarde des données et fermeture du formulaire
 */
-(IBAction) saveAndCloseController:(id)sender;

/**
 * @brief IBAction de fermeture du formulaire
 */
-(IBAction) closeController:(id)sender;



#pragma mark - Methods

/**
 * @brief Méthode appelée lors du clic sur le bouton de la carte
 * @param location La location à utiliser pour centrer la map
 */
-(void)didPressMapButton:(CLLocation*)location;

/**
 * @brief Met à jour le PhotoViewModel
 * @param photoViewModel le PHotoViewModel à mettre à jour
 */
-(void) setPhotoViewModel:(MFUIBaseViewModel *)photoViewModel;


@end

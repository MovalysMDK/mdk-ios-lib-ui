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
//  ManagePictureViewController.h
//  navigation
//
//


#import "MFPhotoPropertiesViewController.h"
#import "MFPhotoViewModel.h"
#import "MFPhotoThumbnail.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MFPhotoFixedListDataDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "MFViewController.h"
#import "MFDetailViewControllerProtocol.h"
#import "MFNumberConverter.h"
#import <AVFoundation/AVFoundation.h>


@interface MFPhotoDetailViewController : MFViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate, MFDetailViewControllerProtocol>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MFPhotoViewModel *photoViewModel;
@property (nonatomic, strong) MFPhotoThumbnail *photoThumbnail;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionnerPhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prendrePhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *supprimerPhotoButton;

@property (nonatomic, strong) MFFixedList *fixedList;
@property (nonatomic, strong) MFPhotoFixedListDataDelegate *cellPhotoFixedList;

/*!
 * @brief Méthode appelée lorsqu'on quitte la vue sans sauvegarder
 */


- (IBAction)back:(id)sender;

/*!
 * @brief Méthode appelée lorsqu'on quitte la vue en sauvegardant
 */

- (IBAction)save:(id)sender;

/*!
 * @brief Clic sur le bouton d'affichage des infos
 */

- (IBAction)afficherInfos:(id)sender;

/*!
 * @brief Clic sur le bouton pour prendre une photo
 */

- (IBAction)takePhoto:(id)sender;

/*!
* @brief Clic sur le bouton pour choisir une photo dans la galerie
*/

- (IBAction)selectPhoto:(id)sender;

/*!
 * @brief Clic sur le bouton de suppression de la photo courante
 */

- (IBAction)deletePhoto:(id)sender;


@end

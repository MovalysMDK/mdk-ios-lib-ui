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
//  MFPhotoThumbnail.h
//  MFUI
//
//
//

//iOS imports
#import <AssetsLibrary/AssetsLibrary.h>
#import "MFUIOldBaseComponent.h"

@interface MFPhotoThumbnail : MFUIOldBaseComponent

#pragma mark - Constants

/**
 * @brief Le nom par défaut du story board utilisé pour la gestion de la photo
 */
FOUNDATION_EXPORT NSString *const  DEFAUT_PHOTO_STORYBOARD_NAME;

/**
 * @brief Le nom du contrôleur par défaut utilisé pour la gestion de la photo
 */
FOUNDATION_EXPORT NSString *const  DEFAUT_PHOTO_MANAGER_CONTROLLER_NAME;

#pragma mark - Properties

/**
 * @brief The image view  that displays the photo
 */
@property (nonatomic, strong) UIImageView *photoImageView;

/**
 * @brief The label that displays the date of the photo
 */
@property (nonatomic, strong) UILabel *dateLabel;

/**
 * @brief The label that displays the titre of the photo
 */
@property (nonatomic, strong) UILabel *titreLabel;

/**
 * @brief The label that displays the description of the photo
 */
@property (nonatomic, strong) UILabel *descriptionLabel;




#pragma mark - Methods
/**
 * @brief Affiche la vue de modification de la photo
 * @param sender
 */
- (void) displayManagePhotoView: (id)sender;

/**
 * @brief Set data in a the list after a cell has been edited
 * @param data the new data to set in the list
 */
-(void) setDataAfterEdition:(id)data;

@end

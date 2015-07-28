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
//  MFPhotoThumbnail.m
//  Pods
//
//
//


#import "MFUIApplication.h"
#import "MFPhotoThumbnail.h"
#import "MFCellAbstract.h"
#import "MFPhotoDetailViewController.h"
#import "MFPhotoViewModel.h"

@interface MFPhotoThumbnail()

/**
 * @brief Permet la sauvegarde du dernier contrôleur récupéré pour éviter un bug
 * lors du clic sur la photo après l'ouverture du menu de gauche.
 */
@property (nonatomic, strong) UIViewController *lastAppearVC;

/**
 * @brief Indique sur l'écran est initialisé
 */
@property (nonatomic) BOOL isInitialized;

/**
 * @brief Variable privée désignant l'alignement global du composant
 */
@property (nonatomic, strong) NSNumber *privateComponentAlignment;

/**
 * @brief The photo view model
 */

@property (nonatomic, strong) MFPhotoViewModel *photoViewModel;

@end


@implementation MFPhotoThumbnail

@synthesize photoViewModel;
@synthesize targetDescriptors = _targetDescriptors;

/**
 * @brief Nom du storyboard à appeler pour afficher le composant Photo
 */
NSString *const DEFAUT_PHOTO_STORYBOARD_NAME = @"Photo";

/**
 * @brief Nom du ViewController de detail du composant photo
 */
NSString *const DEFAUT_PHOTO_MANAGER_CONTROLLER_NAME = @"photoDetailViewController";

/**
 * @brief Nom de l'image par défaut indiquant qu'il n'y a pas de photo
 */
NSString *const DEFAUT_NO_PHOTO_IMAGE = @"no_photo";


typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);


#pragma mark - Initializing

-(void)initialize {
    [super initialize];
    
    
    
    
    //Ajout des éléments du composant
    self.isInitialized = NO;
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage* image = [UIImage imageNamed:[self defaultImage]];
    self.photoImageView.image = image;
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.titreLabel = [[UILabel alloc] init];
    self.titreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titreLabel.numberOfLines = 2;
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //Nombre de lignes infini
    self.descriptionLabel.numberOfLines = 0;
    
    [self addSubview:self.photoImageView];
    [self addSubview:self.dateLabel];
    [self addSubview:self.titreLabel];
    [self addSubview:self.descriptionLabel];
    
    
    //Ajout de l'action de clic sur le composant
    [self addTarget:self action:@selector(displayManagePhotoView:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    //Empêche l'affichage de l'image "composant invalide" dans la liste
    self.isValid = YES;
    
    //        //Define constraints
    [self definePhotoConstraints];
    [self defineDateLabelConstraints];
    [self defineDescriptionLabelConstraints];
    [self defineTitreLabelConstraints];
}

#pragma mark - Define constraints

-(void) definePhotoConstraints {
    //Positionnement de la photo
    NSLayoutConstraint *insidePhotoConstraintLeftMargin =
    [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *insidePhotoConstraintTopMargin =
    [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *insidePhotoConstraintHeight =
    [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSLayoutConstraint *insidePhotoConstraintWidth =
    [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0];
    
    [self addConstraints:@[insidePhotoConstraintLeftMargin, insidePhotoConstraintTopMargin,
                           insidePhotoConstraintHeight, insidePhotoConstraintWidth]];
    
}

-(void) defineTitreLabelConstraints {
    //Positionnement du label titre
    NSLayoutConstraint *insideTitreConstraintLeftMargin =
    [NSLayoutConstraint constraintWithItem:self.titreLabel attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual toItem:self.photoImageView
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:5];
    
    NSLayoutConstraint *insideTitreConstraintTopMargin =
    [NSLayoutConstraint constraintWithItem:self.titreLabel attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual toItem:self.photoImageView
                                 attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *insideTitreConstraintRightMargin =
    [NSLayoutConstraint constraintWithItem:self.titreLabel attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    
    [self addConstraints:@[insideTitreConstraintLeftMargin, insideTitreConstraintTopMargin,
                           insideTitreConstraintRightMargin]];
}

-(void) defineDescriptionLabelConstraints {
    //Positionnement du label description
    NSLayoutConstraint *insideDescriptionConstraintLeftMargin =
    [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual toItem:self.photoImageView
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:5];
    
    NSLayoutConstraint *insideDescriptionConstraintTopMargin =
    [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual toItem:self.titreLabel
                                 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *insideDescriptionConstraintRightMargin =
    [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    
    [self addConstraints:@[insideDescriptionConstraintLeftMargin, insideDescriptionConstraintTopMargin,
                           insideDescriptionConstraintRightMargin]];
}

-(void) defineDateLabelConstraints {
    //Positionnement du label date
    NSLayoutConstraint *insideDateConstraintLeftMargin =
    [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual toItem:self.photoImageView
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:5];
    
    NSLayoutConstraint *insideDateConstraintTopMargin =
    [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual toItem:self.descriptionLabel
                                 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *insideDateConstraintRightMargin =
    [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *insideDateConstraintBottom =
    [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationLessThanOrEqual toItem:self
                                 attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraints:@[insideDateConstraintLeftMargin, insideDateConstraintTopMargin,
                           insideDateConstraintRightMargin, insideDateConstraintBottom]];
}

#pragma mark - View lifecycle
-(void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.photoImageView.tag == 0) {
        [self.photoImageView setTag:TAG_MFPHOTOTHUMBNAIL_PHOTOVIEW];
    }
    if (self.dateLabel.tag == 0) {
        [self.dateLabel setTag:TAG_MFPHOTOTHUMBNAIL_DATE];
    }
    if (self.titreLabel.tag == 0) {
        [self.titreLabel setTag:TAG_MFPHOTOTHUMBNAIL_TITRE];
    }
    if (self.descriptionLabel.tag == 0) {
        [self.descriptionLabel setTag:TAG_MFPHOTOTHUMBNAIL_DESCRIPTION];
    }
}


#pragma mark - Specific methods

/**
 * @brief Affiche la vue de modification de la photo
 */
- (void) displayManagePhotoView: (id)sender
{
    
    NSString *storyboardName = nil;
    NSString *managePhotoControllerName = nil;
    
    
    //If the storyboard isn't specified
    if (storyboardName == nil || storyboardName.length == 0)
    {
        storyboardName = DEFAUT_PHOTO_STORYBOARD_NAME;
    }
    
    //If the view controller name isn't specified
    if (managePhotoControllerName == nil || managePhotoControllerName.length == 0)
    {
        managePhotoControllerName = DEFAUT_PHOTO_MANAGER_CONTROLLER_NAME;
    }
    
    //Getting the view controller to push
    MFPhotoDetailViewController *managePhotoViewController = [[UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle bundleForClass:[self class]]]
                                                              instantiateViewControllerWithIdentifier:managePhotoControllerName];
    
    // Récupération d'un photoViewModel initialisé
    MFPhotoViewModel *newPhotoViewModel = [self createAnUpdatePhotoViewModel];
    
    //On passe au contrôleur la copie du view model (pour mise à jour des données) et le composant (pour l'actualiser lorsqu'on
    //revient dans la vue qui le contient)
    //La copie du view model permet de gérer facilement l'annulation des modifications
    managePhotoViewController.photoThumbnail = self;
    managePhotoViewController.photoViewModel = newPhotoViewModel;
    
    //Displaying the controller
    [[[MFUIApplication getInstance] lastAppearViewController].navigationController pushViewController:managePhotoViewController animated:YES];
    
}

-(MFPhotoViewModel *) createAnUpdatePhotoViewModel {
    //Création d'une copie du view model
    MFPhotoViewModel *newPhotoViewModel = [[MFPhotoViewModel alloc] init];
    newPhotoViewModel.identifier = self.photoViewModel.identifier;
    newPhotoViewModel.titre = self.photoViewModel.titre;
    newPhotoViewModel.descr = self.photoViewModel.descr;
    newPhotoViewModel.uri = self.photoViewModel.uri;
    newPhotoViewModel.date = self.photoViewModel.date;
    newPhotoViewModel.photoState = self.photoViewModel.photoState;
    newPhotoViewModel.position = self.photoViewModel.position;
    return newPhotoViewModel;
}



#pragma mark - Inherited methods from MFUIComponentProtocol

/**
 * @brief Met à jour le composant avec les données du view model
 */

-(void)setData:(id)data
{
    //TODO: A revoir, méthode à complexité trop importante
    if(data && ![data isKindOfClass:[MFKeyNotFound class]])
    {
        if ( [data isKindOfClass: [MFPhotoViewModel class]] ) {
            
            MFPhotoViewModel *viewModel = (MFPhotoViewModel *)data;
            self.dateLabel.text = [viewModel getDateStringFormat:@"dd/MM/yyyy HH:mm"];
            self.titreLabel.text = viewModel.titre;
            self.descriptionLabel.text = viewModel.descr;
            
            //Si une URI de photo est spécifiée
            if (viewModel.uri != nil && ![viewModel.uri isEqualToString:@""])
            {
                
                //Affichage de la photo à partir de son URI
                ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                {
                    
                    CGImageRef iref = [myasset aspectRatioThumbnail];
                    if (iref) {
                        self.photoImageView.image = [UIImage imageWithCGImage:iref];
                    } else {
                        UIImage* image = [UIImage imageNamed:[self defaultImage]];
                        self.photoImageView.image = image;
                    }
                    
                    //Récupération de la localisation de la photo (si elle est spécifiée dans les métadonnées)
                    CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
                    
                    if (location)
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setMaximumFractionDigits:6];
                        
                        self.photoViewModel.position.latitude =
                        [MFNumberConverter toString:[NSNumber numberWithFloat:location.coordinate.latitude] withFormatter:numberFormatter];
                        
                        self.photoViewModel.position.longitude =
                        [MFNumberConverter toString:[NSNumber numberWithFloat:location.coordinate.longitude] withFormatter:numberFormatter];
                    }
                    
                };
                
                //Echec de chargement de la photo
                ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
                {
                    UIImage* image = [UIImage imageNamed:[self defaultImage]];
                    self.photoImageView.image = image;
                };
                
                if(viewModel.uri && [viewModel.uri length])
                {
                    
                    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                    NSURL *asseturl = [NSURL URLWithString:viewModel.uri];
                    [assetslibrary assetForURL:asseturl
                                   resultBlock:resultblock
                                  failureBlock:failureblock];
                }
            }
            //Si aucune URI n'est spécifiée, il n'y a pas de photo à afficher
            else
            {
                UIImage* image = [UIImage imageNamed:[self defaultImage]];
                self.photoImageView.image = image;
            }
            
            //Le view model est récupéré
            self.photoViewModel = viewModel;
            
        }
        else {
            [NSException raise:@"Invalid argument" format:@"MFPhotoThumbnail.setData : parameter is not of type MFPhotoViewModel %@",
             NSStringFromClass([data class])];
        }
    }
    else {
        MFPhotoViewModel *viewModel = [[MFPhotoViewModel alloc] init];
        viewModel.identifier = @-1;
        self.photoViewModel = viewModel;
        self.dateLabel.text = nil;
        self.titreLabel.text = nil;
        self.descriptionLabel.text = nil;
        UIImage* image = [UIImage imageNamed:[self defaultImage]];
        self.photoImageView.image = image;
    }
}


-(void)setDataAfterEdition:(id)data {
    [self setData:data];
    [self valueChanged:self.photoImageView];
}


+(NSString *) getDataType {
    return @"MFPhotoViewModel";
}

-(id) getData {
    return self.photoViewModel;
}

- (void) setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.dateLabel.userInteractionEnabled = editable;
    self.titreLabel.userInteractionEnabled = editable;
    self.descriptionLabel.userInteractionEnabled = editable;
}



-(NSString *) defaultImage {
    return nil;
}


-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if(![target isEqual:self]) {
        MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
        commonCCTD.target = target;
        commonCCTD.action = action;
        self.targetDescriptors = @{@(self.photoImageView.hash) : commonCCTD};
    }
    else {
        [super addTarget:target action:action forControlEvents:controlEvents];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) valueChanged:(UIView *)sender {
    MFControlChangedTargetDescriptor *cctd = self.targetDescriptors[@(sender.hash)];
    [cctd.target performSelector:cctd.action withObject:self];
}
#pragma clang diagnostic pop




@end

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
//  ManagePictureViewController.m
//  navigation
//
//

#import <ImageIO/CGImageProperties.h>

#import <MFCore/MFCoreI18n.h>

#import "MFUIApplication.h"
#import "MFPhotoDetailViewController.h"
#import "MFPhotoFixedListItemCell.h"
#import "MFUIBaseListViewModel.h"


#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MFPhotoDetailViewController ()

/**
 * @brief The popover window to display the PickerList on iPad
 */
@property (nonatomic, strong) UIPopoverController *popover;

/**
* @brief The location manager to get location information
*/

@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 * @brief The location data
 */

@property (nonatomic, strong) CLLocation *location;

@end

@implementation MFPhotoDetailViewController

@synthesize photoViewModel;
@synthesize photoThumbnail;

@synthesize toolbar;
@synthesize prendrePhotoButton;
@synthesize selectionnerPhotoButton;
@synthesize supprimerPhotoButton;
@synthesize fixedList;
@synthesize cellPhotoFixedList;
@synthesize parentFormController;
@synthesize indexPath;
@synthesize editable;
@synthesize originalViewModel;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialisation des boutons de la barre de navigation
    [self.backButton setTitle:MFLocalizedStringFromKey(@"form_back")];
    [self.saveButton setTitle:MFLocalizedStringFromKey(@"form_save")];
    [self setTitle:MFLocalizedStringFromKey(@"photoControllerTitle")];
    
    
    //Si une URI de photo est spécifiée, on affiche la photo à partir de cette URI
    if (self.photoViewModel.uri)
    {
    
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullScreenImage];
            if (iref) {
                
                self.imageView.image = [UIImage imageWithCGImage:iref];
            }
               
        };
        
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            MFUILogError(@"Can't get image - %@",[myerror localizedDescription]);
        };
        
        if(self.photoViewModel.uri && [self.photoViewModel.uri length])
        {
            NSURL *asseturl = [NSURL URLWithString:self.photoViewModel.uri];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }

    }

    //Si le composant n'est pas éditable, on désactive les boutons permettant de le modifier

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight ];
    [infoButton addTarget:self action:@selector(afficherInfos:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
    [toolbarItems addObject:infoItem];
    [toolbarItems addObjectsFromArray:[self.toolbar items]];
    
    [self.toolbar setItems:toolbarItems];
    
    if (self.photoThumbnail && [self.photoThumbnail.editable  isEqual:@0])
    {
        self.prendrePhotoButton.enabled = NO;
        self.selectionnerPhotoButton.enabled = NO;
        self.supprimerPhotoButton.enabled = NO;
        self.saveButton.enabled = NO;
        
    //S'il est éditable, on regarde si l'application est autorisée à accéder aux photos
    } else {
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
        //Si le statut d'accès est indéterminé, on demande à l'utilisateur d'autoriser ou de refuser l'accès aux photos.
        //En effet, si on travaille sur une liste de photos et qu'on ajoute la première photo de la liste, alors
        //l'accès aux photos n'a pas encore été demandé au chargement de la liste (il n'y avait pas de photo à afficher).
        //A l'ouverture de cette vue, aucune photo n'a encore été récupérée, il n'y a donc aucune URI spécifiée et la demande d'accès aux photos (provoquée par la lecture d'une photo via son URI) n'a pas été réalisée.
        if(status == ALAuthorizationStatusNotDetermined) {
            
            //Fin d'exécution avec succès (l'utilisateur a accepté l'accès aux photos)
            ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupEnumerator = ^(ALAssetsGroup *assetGroup, BOOL *stop) {
            };
            
            //Fin d'exécution en erreur (l'utilisateur a refusé l'accès aux photos)
            ALAssetsLibraryAccessFailureBlock assetFailureBlock = ^(NSError *error) {
                //Le nouveau statut est récupéré suite à la réponse de l'utilisateur
                ALAuthorizationStatus newStatus = [ALAssetsLibrary authorizationStatus];
                //On a pas pu accéder aux photos : les boutons prendre une photo et sélectionner une photo sont grisés
                //exécuté au sein du bloc pour une bonne gestion de l'asynchronisme : cela évite de griser les boutons trop tôt
                //alors que l'utilisateur a autorisé l'accès aux photos.
                [self griserBoutonsPhotosWithStatus:newStatus];
            };
            
            NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary enumerateGroupsWithTypes:groupTypes usingBlock:assetGroupEnumerator failureBlock:assetFailureBlock];
         
        //Le statut est déterminé
        } else {
            
            [self griserBoutonsPhotosWithStatus:status];
        }
    
    
    }
    
}


/**
 * @brief Grise les boutons "prendre une photo" et "sélectionner une photo" si l'accès aux photos n'est pas autorisé
 */
- (void) griserBoutonsPhotosWithStatus:(ALAuthorizationStatus) status
{
    if (status != ALAuthorizationStatusAuthorized) {
        
        self.prendrePhotoButton.enabled = NO;
        self.selectionnerPhotoButton.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //On enregistre le contrôleur comme dernier contrôleur apparu avant de fermer.
    //Cela permet de conserver le bon contrôleur dans le cas où l'on revient de la modale
    //des informations de la photo. En effet, le retour de modale ne déclenche pas la méthode
    //viewDidAppear de ce contrôleur.
    [MFUIApplication getInstance].lastAppearViewController = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods from UIImagePickerControllerDelegate

/**
 * @brief Méthode appelée lorsqu'on termine l'action du picker (choix ou prise d'une photo)

 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //Récupération de la photo prise/choisie
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    //Formatter pour l'affichage des coordonnées GPS
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:6];
    
    //Remise à vide des éventuelles coordonnées GPS existantes (dans le cas où la nouvelle photo ne contient pas de coordonnées
    //GPS ou si la sauvegarde échoue, on ne doit pas garder les anciennes coordonnées)
    self.photoViewModel.position.latitude = nil;
    self.photoViewModel.position.longitude = nil;
    //Remise à vide de la date (dans le cas où la sauvegarde de la nouvelle photo échoue, on ne doit pas garder l'ancienne date)
    self.photoViewModel.date = nil;
    
    //Si la photo vient d'être prise
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera)
    {
        self.photoViewModel.photoState.state = taken;
       
        //Sauvegarde de la photo dans l'album
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =^(NSURL *assetURL, NSError *error) {
            

            
            if (error)
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: MFLocalizedStringFromKey(@"photoErrorAlertTitle")
                                      message: MFLocalizedStringFromKey(@"savingPhotoErrorAlertMessage")
                                      delegate: nil
                                      cancelButtonTitle:MFLocalizedStringFromKey(@"photoAlertOKValue")
                                      otherButtonTitles:nil];
                
                [self dismissWaitingView];
                [alert show];
            }
            else
            {
                self.photoViewModel.uri = [assetURL absoluteString];
                [self.saveButton setEnabled:YES];
                [self dismissWaitingView];
            }
        };
        
        
        //Récupération des données EXIF de la photo
        NSMutableDictionary *imageMetadata = [info[UIImagePickerControllerMediaMetadata] mutableCopy];
        
        //Ajout des données de localisation (si elles existent)
        if (self.location)
        {
            

            //Il faut compléter le dictionnaire des metadonnées avec les bonnes clés qui renseignent la localisation
            //Les données latitude/longitude doivent être renseignés en sexagésimal (valeurs positives
            // avec orientation Nord, Sud, Est, Ouest)
            NSDictionary *location  = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:fabs(self.location.coordinate.latitude)], kCGImagePropertyGPSLatitude
                                                 , self.location.coordinate.latitude > 0 ? @"N" : @"S" , kCGImagePropertyGPSLatitudeRef
                                                 , [NSNumber numberWithFloat:fabs(self.location.coordinate.longitude)], kCGImagePropertyGPSLongitude
                                                 , self.location.coordinate.longitude > 0 ? @"E" : @"W" , kCGImagePropertyGPSLongitudeRef
                                                 , nil];
            
            NSDictionary *gps = [NSDictionary dictionaryWithObjectsAndKeys:
                                 location, kCGImagePropertyGPSDictionary, nil];
            
            [imageMetadata addEntriesFromDictionary:gps];
            
            self.photoViewModel.position.latitude = [MFNumberConverter toString:[NSNumber numberWithFloat:self.location.coordinate.latitude]  withFormatter:numberFormatter];
            self.photoViewModel.position.longitude = [MFNumberConverter toString:[NSNumber numberWithFloat:self.location.coordinate.longitude]  withFormatter:numberFormatter];
        

        }
        
        //On stoppe la localisation
        [self.locationManager stopUpdatingLocation];
        
        [self.saveButton setEnabled:NO];
        [self showWaitingViewWithMessageKey:@"waiting.view.saving.photo"];
        
        //Sauvegarde de la photo avec ses données EXIF + ses éventuelles données de localisation
        [library writeImageToSavedPhotosAlbum:[chosenImage CGImage] metadata:imageMetadata completionBlock:imageWriteCompletionBlock];

        //La date de prise de vue est une chaine, il faut la convertir en NSDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        
        //Sauvegarde de la date de prise de vue
        self.photoViewModel.date = [dateFormatter dateFromString:[[imageMetadata valueForKey:[NSString stringWithFormat:@"%@", kCGImagePropertyExifDictionary]] valueForKey:@"DateTimeOriginal"]];

    } //Si la photo a été sélectionnée dans la galerie
    else if ([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        self.photoViewModel.photoState.state = selected;
        //Récupération de l'URI de la photo
        self.photoViewModel.uri = [info[UIImagePickerControllerReferenceURL] absoluteString];

        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            
            //Récupération de la date de prise de vue à partir des metadonnées (la propriété
            //ALAssetPropertyDate ne renvoie pas la bonne date)
            NSDictionary *metadata = myasset.defaultRepresentation.metadata;
            
            NSString *datePhoto = [[metadata objectForKey:[NSString stringWithFormat:@"%@", kCGImagePropertyExifDictionary]] objectForKey:[NSString stringWithFormat:@"%@", kCGImagePropertyExifDateTimeOriginal]];
            
            //La date de prise de vue est une chaine, il faut la convertir en NSDate
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            
            self.photoViewModel.date = [dateFormatter dateFromString:datePhoto];
            
            //Récupération de la localisation de la photo (si elle est spécifiée dans les métadonnées)
            CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
            
            if (location)
            {
                
                self.photoViewModel.position.latitude = [MFNumberConverter toString:[NSNumber numberWithFloat:location.coordinate.latitude]  withFormatter:numberFormatter];
                self.photoViewModel.position.longitude = [MFNumberConverter toString:[NSNumber numberWithFloat:location.coordinate.longitude]  withFormatter:numberFormatter];
                self.location = location;
                
            }
        };
        
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            MFUILogError(@"Can't get metadata from image - %@",[myerror localizedDescription]);
        };
        
        if(self.photoViewModel.uri && [self.photoViewModel.uri length])
        {
            NSURL *asseturl = [NSURL URLWithString:self.photoViewModel.uri];
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }

    }
    
    //Fermeture du picker
    if([MFVersionManager isCurrentDeviceOfTypePhone]) //iPhone
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else //iPad
    {
        if ([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            [self.popover dismissPopoverAnimated:YES];
        }
        else
        {
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    }

    //La photo est affichée
    self.imageView.image = chosenImage;
    
}



/**
 * @brief Méthode appelée lorsqu'on annule la prise/le choix d'une photo
 */


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    //Fermeture du picker
    if([MFVersionManager isCurrentDeviceOfTypePhone]) //iPhone
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else //iPad
    {
        if ([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            [self.popover dismissPopoverAnimated:YES];
        }
        else
        {
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
}

#pragma mark - Methods from CLLocationManagerDelegate

/**
 * @brief Méthode appelée lors de la mise à jour de la localisation
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.location = newLocation;
}

/**
 * @brief Méthode appelée lorsque la localisation est impossible
 */

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.location = nil;
}


#pragma mark - Actions methods

- (IBAction)afficherInfos:(id)sender {
    
    
    //Récupération de la vue à afficher
    MFPhotoPropertiesViewController *photoPropertiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoPropertiesViewController"];
    
    photoPropertiesViewController.photoViewModel = self.photoViewModel;
    if (self.photoThumbnail)
    {
        photoPropertiesViewController.donneesEditables = [self.photoThumbnail.editable boolValue];
    }
    else
    {
        photoPropertiesViewController.donneesEditables = YES;
    }
    
    //On embarque cette vue dans un contrôleur de navigation (pour gérer la barre de navigation)
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoPropertiesViewController];

    //On affiche la vue (transition de type modale) 
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}



- (IBAction)back:(id)sender {
    
    NSInteger nbElementsListe = [self fixedListViewModel].viewModels.count;
    
    //Si la fixed list est spécifiée, c'est qu'on vient d'ajouter un élément à la liste, mais qu'on annule sa création.
    //Si la liste contient au moins un élément, alors il faut supprimer la cellule qui a été créée lorsqu'on a affiché la vue du contrôleur courant. Cette cellule est située en fin de liste.
    if (fixedList)
    {
        
        //Mise à jour du view model de la liste (suppression du view model correspondant)
        MFUIBaseListViewModel *viewModel = ((MFUIBaseListViewModel *)[self.fixedList getData]);
        NSMutableArray *tempData = [viewModel.viewModels mutableCopy];
        [tempData removeObjectAtIndex:nbElementsListe-1];
        viewModel.viewModels = tempData;
        viewModel.hasChanged = YES;
        [self.fixedList.tableView beginUpdates];

        //Suppression de la cellule
        [self.fixedList.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:nbElementsListe-1 inSection:0 ]] withRowAnimation:UITableViewRowAnimationNone];
        [self.fixedList.tableView endUpdates];

        
        //Rafraichissement de la liste (pour éviter un espace blanc à l'emplacement de la cellule supprimée)
        self.cellPhotoFixedList.hasBeenReload = NO;
//        [self.fixedList.tableView reloadData];

    }
    
    //Retour à la vue précédente
    [self.navigationController popViewControllerAnimated:YES];
    [self.fixedList.tableView reloadData];
    
}



- (IBAction)save:(id)sender {
    
    //Si la fixed list est spécifiée, c'est qu'on vient d'ajouter un élément à la liste
    //Il faut récupérer le composant correspondant à la cellule que l'on veut mettre à jour.
    if (fixedList)
    {
        
        MFPhotoFixedListItemCell *photoFixedListItemCell = (MFPhotoFixedListItemCell *)[self.fixedList.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:[self fixedListViewModel].viewModels.count-1 inSection:0 ]];

        self.photoThumbnail = photoFixedListItemCell.photoValue;
    }
    
    //Rafraichissement des données du composant avec le view model
    [photoThumbnail setDataAfterEdition:self.photoViewModel];
    
    //Retour à la vue précédente
    [self.navigationController popViewControllerAnimated:YES];
    [self.fixedList.tableView reloadData];
    
}




- (IBAction)takePhoto:(id)sender {
    
    //Test réservé à iOS 7 pour garantir l'accès à l'appareil photo
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    
        NSString *mediaType = AVMediaTypeVideo;
        //Récupération de l'autorisation d'accès à l'appareil photo
        AVAuthorizationStatus cameraAccessStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        //Si le statut d'accès est indéterminé, on demande à l'utilisateur d'autoriser ou de refuser.
        //Cela permet de garantir une demande d'accès dans le cas où l'accès indéterminée et que la demande à l'utilisateur
        //ne se fait pas.
        if (cameraAccessStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            }];
        }
        
    }
    
    //Si l'appareil photo n'est pas disponible, on affiche une erreur
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:MFLocalizedStringFromKey(@"photoErrorAlertTitle")
                                                              message:MFLocalizedStringFromKey(@"photoNoCameraErrorMessage")
                                                             delegate:nil
                                                    cancelButtonTitle:MFLocalizedStringFromKey(@"photoAlertOKValue")
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    //Sinon, on lance l'appareil photo
    else
    {
        
        //Création du picker permettant de prendre une photo
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //Lancement de la localisation
        self.locationManager = [[CLLocationManager alloc] init];
        
        if ([CLLocationManager locationServicesEnabled])
        {
            self.locationManager.delegate = self;
            //Recherche de la meilleure précision
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            //Rafraichissement de la localisation tous les 100 mètres
            self.locationManager.distanceFilter = 100.0f;
            [self.locationManager startUpdatingLocation];
        }
        
        //Affichage de l'appareil photo
        [self presentViewController:picker animated:YES completion:NULL];

    }
}


- (IBAction)selectPhoto:(id)sender {
    
    //Création du picker permettant de choisir des photos dans la galerie
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //Affichage de la vue de sélection d'une photo

    if([MFVersionManager isCurrentDeviceOfTypePhone]) //iPhone
    {
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else //iPad
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.popover presentPopoverFromRect:CGRectMake(450.0f, 825.0f, 10.0f, 10.0f) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}



- (IBAction)deletePhoto:(id)sender {
    
    //On met l'image "pas de photo" lorsque la photo est supprimée
    UIImage* image = [UIImage imageNamed:@"no_photo"];
    self.imageView.image = image;
    
    //Les informations directement liées à la photo sont supprimées
    self.photoViewModel.uri = nil;
    self.photoViewModel.photoState.state = none;
    self.photoViewModel.date = nil;
    self.photoViewModel.position.latitude = nil;
    self.photoViewModel.position.longitude = nil;
}

/**
 * @brief Action de retour dans cette vue
 */
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{

}

-(MFUIBaseListViewModel *) fixedListViewModel {
    return ((MFUIBaseListViewModel *)[self.fixedList getData]);
}




@end

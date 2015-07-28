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
//  MFPosition.m
//  MFUI
//
//

#import <CoreLocation/CoreLocation.h>

#import <MFCore/MFCoreLog.h>
#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreI18n.h>

#import "MFUIApplication.h"
#import "MFUIConversion.h"

#import "MFMapViewController.h"
#import "MFPosition.h"
#import "MFPositionViewModel.h"
#import "MFNumberConverter.h"
#import "MFButton.h"

#define MFPOSITION_HEIGHT 30
#define MFPOSITION_BUTTON_SIZE 44
#define MFPOSITION_HPADDING 5
#define MFPOSITION_WPADDING 5
#define MFPOSITION_ANIMATION_DURATION .2f

@interface MFPosition () <UITextFieldDelegate>

@property(nonatomic, strong) MFButton *gpsButton;
@property(nonatomic, strong) MFButton *mapButton;

@end

@implementation MFPosition {
    CLLocationManager *locationManager;
    int positionUpdates;
}
@synthesize targetDescriptors = _targetDescriptors;
-(void)initialize {
    
    [super initialize];
    
    // Latitude Field
    self.latitude = [[MFDoubleTextField alloc] initWithFrame:CGRectZero];
    
    [self.latitude addControlAttribute:@6 forKey:@"decimalPartMaxDigits"];
    self.latitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRW");
    [self.latitude setSender:self];
    
    // Longitude Field
    self.longitude = [[MFDoubleTextField alloc] initWithFrame:CGRectZero];
    [self.longitude addControlAttribute:@6 forKey:@"decimalPartMaxDigits"];
    self.longitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRW");
    [self.longitude setSender:self];
    self.backgroundColor = [UIColor clearColor];
    
    // GPS Button
    self.gpsButton = [[MFButton alloc] init];
    [self.gpsButton addTarget:self action:@selector(gpsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Map Button
    self.mapButton = [[MFButton alloc] init];
    [self.mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.latitude];
    [self addSubview:self.longitude];
    [self addSubview:self.gpsButton];
    [self addSubview:self.mapButton];
    
    [self addCustomConstraints];
    
    [self setNeedsDisplay];
    
    [self selfCustomization];
    

    
}


-(void) addCustomConstraints {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.gpsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mapButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.latitude setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.longitude setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //Buttons height and width
    NSLayoutConstraint *centerYMapButton = [NSLayoutConstraint constraintWithItem:self.mapButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *mapButtonWidth = [NSLayoutConstraint constraintWithItem:self.mapButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_BUTTON_SIZE];
    NSLayoutConstraint *mapButtonHeight = [NSLayoutConstraint constraintWithItem:self.mapButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_BUTTON_SIZE];
    NSLayoutConstraint *centerYGpsButton = [NSLayoutConstraint constraintWithItem:self.gpsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *gpsButtonWidth = [NSLayoutConstraint constraintWithItem:self.gpsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_BUTTON_SIZE];
    NSLayoutConstraint *gpsButtonHeight = [NSLayoutConstraint constraintWithItem:self.gpsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_BUTTON_SIZE];
    
    //Buttons parent/relative margins
    NSLayoutConstraint *positionXMapButton = [NSLayoutConstraint constraintWithItem:self.mapButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    NSLayoutConstraint *positionXGpsButton = [NSLayoutConstraint constraintWithItem:self.gpsButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.mapButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-10];
    
    //TextFields positions
    NSLayoutConstraint *latitudeTopMargin = [NSLayoutConstraint constraintWithItem:self.latitude attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    NSLayoutConstraint *longitudeBottomMargin = [NSLayoutConstraint constraintWithItem:self.longitude attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    NSLayoutConstraint *latitudeLeftMargin = [NSLayoutConstraint constraintWithItem:self.latitude attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:30];
    NSLayoutConstraint *longitudeLeftMargin = [NSLayoutConstraint constraintWithItem:self.longitude attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:30];
    
    
    NSLayoutConstraint *latitudeRightMargin = [NSLayoutConstraint constraintWithItem:self.latitude attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.gpsButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-10];
    NSLayoutConstraint *longitudeRightMargin = [NSLayoutConstraint constraintWithItem:self.longitude attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.gpsButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-10];
    NSLayoutConstraint *longitudeHeight = [NSLayoutConstraint constraintWithItem:self.longitude attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_HEIGHT];
    NSLayoutConstraint *latitudeHeight = [NSLayoutConstraint constraintWithItem:self.latitude attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:MFPOSITION_HEIGHT];
    
    [self addConstraints:@[centerYMapButton, mapButtonWidth, mapButtonHeight, centerYGpsButton, gpsButtonWidth, gpsButtonHeight, positionXMapButton, positionXGpsButton, latitudeTopMargin, longitudeBottomMargin, latitudeLeftMargin, longitudeLeftMargin, latitudeRightMargin, longitudeRightMargin, longitudeHeight, latitudeHeight]];
}

-(void)selfCustomization {
    [self.gpsButton setImage:[UIImage imageNamed:@"gps.png"] forState:UIControlStateNormal];
    [self.mapButton setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.latitude.tag == 0) {
        [self.latitude setTag:TAG_MFPOSITION_LATITUDE];
    }
    if (self.longitude.tag == 0) {
        [self.longitude setTag:TAG_MFPOSITION_LONGITUDE];
    }
    if (self.gpsButton.tag == 0) {
        [self.gpsButton setTag:TAG_MFPOSITION_GPSBUTTON];
    }
    if (self.mapButton.tag == 0) {
        [self.mapButton setTag:TAG_MFPOSITION_MAPBUTTON];
    }
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}



#pragma mark - Custom Accessors

-(void)setLocation:(CLLocation *)location {
    _location = location;
    
    // Update UI
    /*  self.latitude.regularExpressionTextField.text = [NSString stringWithFormat:@"%.6f", location.coordinate.latitude];
     self.longitude.regularExpressionTextField.text = [NSString stringWithFormat:@"%.6f", location.coordinate.longitude];*/
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:6];
    
    [self.latitude setData:[MFNumberConverter  toString:[NSNumber numberWithFloat:location.coordinate.latitude] withFormatter:numberFormatter]];
    [self.longitude setData:[MFNumberConverter  toString:[NSNumber numberWithFloat:location.coordinate.longitude] withFormatter:numberFormatter]];
    [self valueChanged:self.latitude];
    [self valueChanged:self.longitude];
    
}


#pragma mark - Synchonization method

-(void)updateLocationProperty {
    self.location = [[CLLocation alloc] initWithLatitude:[[MFStringConverter toNumber:self.latitude.text] doubleValue] longitude:[[MFStringConverter toNumber:self.longitude.text] doubleValue]];
}

#pragma mark - geolocalisation
-(void)gpsButtonPressed:(id)sender {
    locationManager = [[CLLocationManager alloc] init];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    positionUpdates = 0;
    
    [locationManager startUpdatingLocation];
    [self.gpsButton setUserInteractionEnabled:NO];
    [self.gpsButton setTintColor:[UIColor lightGrayColor]];
    
    int64_t delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if (positionUpdates != -1) { // On vérifie que la localisation n'a pas déjà été stopée
            if (positionUpdates > 0) { // Si la position a été mise à jour on l'arrête sinon on affiche une erreur
                [locationManager stopUpdatingLocation];
                [self.gpsButton setUserInteractionEnabled:YES];
                [self.gpsButton setTintColor:nil];
            } else {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:MFLocalizedStringFromKey(@"MFPositionError") message:MFLocalizedStringFromKey(@"MFPositionErrorMessage") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    });
}

#pragma mark - buttons actions
-(void)mapButtonPressed:(id)sender {
    
    [self updateLocationProperty];
    
    MFMapViewController *mapViewController = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_MAP_VIEW_CONTROLLER];
    mapViewController.location = self.location;
    
    [[MFUIApplication getInstance].lastAppearViewController.navigationController pushViewController:mapViewController animated:YES];
}

-(void)setData:(id)data {
    MFPositionViewModel *location = (MFPositionViewModel *)data;
    [self.latitude setData:location.latitude];
    [self.longitude setData:location.longitude];
}

+ (NSString *) getDataType {
    return @"MFPositionViewModel";
}

-(id)getData {
    MFPositionViewModel *location = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_POSITION_VIEW_MODEL];
    location.longitude = self.longitude.text;
    location.latitude = self.latitude.text;
    return location;
}

/**
 * Custom behavior for editable mode
 */
-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    if([editable isEqualToNumber:@0]) {
        self.latitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRO");
        self.longitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRO");
        self.gpsButton.hidden = YES;
    }
    else {
        self.gpsButton.hidden = NO;
        self.latitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRW");
        self.longitude.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRW");
    }
    self.latitude.enabled = self.editable;
    self.longitude.enabled = self.editable;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:MFLocalizedStringFromKey(@"MFPositionError") message:MFLocalizedStringFromKey(@"MFPositionErrorMessage") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        ++positionUpdates;
        [self setLocation:currentLocation];
        if (positionUpdates >= 7) {
            positionUpdates = -1;
            [manager stopUpdatingLocation];
            [self.gpsButton setUserInteractionEnabled:YES];
            [self.gpsButton setTintColor:nil];
        }
    }
}

//
//-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
//    int nbOfErrors = 0;
//    NSError *error = nil;
//    
//    if(self.mandatory)
//    {
//        if(self.latitude.text.length == 0 || self.longitude.text.length == 0) {
//            error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)];
//            [self addErrors:@[error]];
//            nbOfErrors++;
//            
//        }
//    }
//    if([[self.latitude getData] doubleValue] > 90 ||
//       [[self.latitude getData] doubleValue] < -90 ||
//       [[self.longitude getData] doubleValue] > 180 ||
//       [[self.longitude getData] doubleValue] < -180) {
//        error = [[MFInvalidLocationValueUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)];
//        [self addErrors:@[error]];
//        nbOfErrors++;
//    }
//    return nbOfErrors;
//}


-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.latitude addTarget:self action:@selector(valueChanged:) forControlEvents:controlEvents];
    [self.longitude addTarget:self action:@selector(valueChanged:) forControlEvents:controlEvents];
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.latitude.hash) : commonCCTD, @(self.longitude.hash) : commonCCTD};
}

-(void) valueChanged:(UIView *)sender {
    MFControlChangedTargetDescriptor *cctd = self.targetDescriptors[@(sender.hash)];
    [cctd.target performSelector:cctd.action withObject:self];
}

@end

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
#define MFPOSITION_ANIMATION_DUR ATION .2f

@interface MFPosition () <UITextFieldDelegate>

@property(nonatomic, strong) MFButton *gpsButton;
@property(nonatomic, strong) MFButton *mapButton;

@end

@implementation MFPosition {
    CLLocationManager *locationManager;
    int positionUpdates;
}

@synthesize applySelfStyle = _applySelfStyle;

-(void)initialize {
    
    // Latitude Field
    self.latitude = [[MFDoubleTextField alloc] initWithFrame:CGRectZero withSender:self];
    self.latitude.decimalPartMaxDigits = @"6";
    self.latitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRW");
    [self.latitude createPattern];
    self.latitude.mfParent = self;
    self.latitude.applySelfStyle = NO;
    
    // Longitude Field
    self.longitude = [[MFDoubleTextField alloc] initWithFrame:CGRectZero withSender:self];
    self.longitude.decimalPartMaxDigits = @"6";
    self.longitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRW");
    [self.longitude createPattern];
    self.longitude.mfParent = self;
    self.longitude.applySelfStyle = NO;
    
    
    // GPS Button
    self.gpsButton = [[MFButton alloc] init];
    [self.gpsButton addTarget:self action:@selector(gpsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.gpsButton.applySelfStyle = NO;
    
    // Map Button
    self.mapButton = [[MFButton alloc] init];
    [self.mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.mapButton.applySelfStyle = NO;
    
    [self addSubview:self.latitude];
    [self addSubview:self.longitude];
    [self addSubview:self.gpsButton];
    [self addSubview:self.mapButton];
    
    [self addCustomConstraints];
    
    [self setNeedsDisplay];
    
    locationManager = [[CLLocationManager alloc] init];
    
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
    NSLayoutConstraint *latitudeLeftMargin = [NSLayoutConstraint constraintWithItem:self.latitude attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    NSLayoutConstraint *longitudeLeftMargin = [NSLayoutConstraint constraintWithItem:self.longitude attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    
    
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


-(NSInteger) validateWithParameters:(NSDictionary *)parameters{
    
    [super validateWithParameters:parameters];
    [self addErrors:[self.latitude getErrors]];
    [self addErrors:[self.longitude getErrors]];
    return [self.baseErrors count];
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
    
    
    //    [self.latitude updateValue:self.latitude.text];
    //    [self.longitude updateValue:self.longitude.text];
    [self updateValue:[self getData]];
    // [self.latitude setValue:[NSString stringWithFormat:@"%.6f", location.coordinate.latitude]];
    
}


#pragma mark - Synchonization method

-(void)updateLocationProperty {
    self.location = [[CLLocation alloc] initWithLatitude:[[MFStringConverter toNumber:self.latitude.regularExpressionTextField.text] doubleValue] longitude:[[MFStringConverter toNumber:self.longitude.regularExpressionTextField.text] doubleValue]];
}

#pragma mark - geolocalisation
-(void)gpsButtonPressed:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    positionUpdates = 0;
    
    [locationManager startUpdatingLocation];
    
    int64_t delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if (positionUpdates != -1) { // On vérifie que la localisation n'a pas déjà été stopée
            if (positionUpdates > 0) { // Si la position a été mise à jour on l'arrête sinon on affiche une erreur
                [locationManager stopUpdatingLocation];
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
    
    MFMapViewController *mapViewController = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_MAP_VIEW_CONTROLLER];
    mapViewController.location = self.location;
    
    [[MFUIApplication getInstance].lastAppearViewController.navigationController pushViewController:mapViewController animated:YES];
}

-(void)setData:(id)data {
    MFPositionViewModel *location = (MFPositionViewModel *)data;
    self.latitude.regularExpressionTextField.text = location.latitude;
    self.longitude.regularExpressionTextField.text = location.longitude;
}

+ (NSString *) getDataType {
    return @"MFPositionViewModel";
}

-(id)getData {
    MFPositionViewModel *location = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_POSITION_VIEW_MODEL];
    location.longitude = self.longitude.regularExpressionTextField.text;
    location.latitude = self.latitude.regularExpressionTextField.text;
    return location;
}

-(void)setMandatory:(NSNumber *)mandatory {
    // Non implémenté
}

/**
 * give the index path to the components too
 */
-(void) setComponentInCellAtIndexPath:(NSIndexPath *)componentInCellAtIndexPath {
    [super setComponentInCellAtIndexPath:componentInCellAtIndexPath];
    [self.latitude setComponentInCellAtIndexPath:componentInCellAtIndexPath];
    [self.longitude setComponentInCellAtIndexPath:componentInCellAtIndexPath];
}
/**
 * give the form controller to the components too
 */
-(void)setForm:(id<MFComponentChangedListenerProtocol> )formController {
    [super setForm:formController];
    [self.latitude  setForm:formController];
    [self.longitude  setForm:formController];
}

/**
 * Custom behavior for editable mode
 */
-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    if([editable isEqualToNumber:@0]) {
        self.latitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRO");
        self.longitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRO");
        self.gpsButton.hidden = YES;
    }
    else {
        self.gpsButton.hidden = NO;
        self.latitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLatitudePlaceholderRW");
        self.longitude.regularExpressionTextField.placeholder = MFLocalizedStringFromKey(@"MFPositionLongitudePlaceholderRW");
    }
    self.latitude.editable = self.editable;
    self.longitude.editable = self.editable;
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
        }
    }
}



-(void)setApplySelfStyle:(BOOL)applySelfStyle {
    _applySelfStyle = applySelfStyle;
}


-(void)setComponentAlignment:(NSNumber *)alignValue {
    [self.latitude setComponentAlignment:alignValue];
    [self.longitude setComponentAlignment:alignValue];
}
@end

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


#import "MFUIApplication.h"
#import "MFMapViewController.h"

#define REGION_RADIUS 5000

@interface MFMapViewController ()

@property(nonatomic, strong) IBOutlet MKMapView *mapView;

@end

@implementation MFMapViewController

@synthesize parentFormController;
@synthesize indexPath;
@synthesize editable;
@synthesize originalViewModel;

-(void)setup {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
}

-(id) init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)loadView {
    [super loadView];

    self.mapView.frame = self.view.bounds;
    
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.mapView];
    
    NSLayoutConstraint *insideMapConstraintMarginLeading = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    
    NSLayoutConstraint *insideMapConstraintMarginTrailing = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    NSLayoutConstraint *insideMapConstraintMarginTop = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *insideMapConstraintMarginBottom = [NSLayoutConstraint constraintWithItem:self.mapView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    //Ajout des contraintes de positionnement pour placer les éléments
    [self.view addConstraints:@[insideMapConstraintMarginLeading, insideMapConstraintMarginTrailing, insideMapConstraintMarginTop, insideMapConstraintMarginBottom]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Map";
}

- (void)viewWillAppear:(BOOL)animated {
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.location.coordinate, REGION_RADIUS, REGION_RADIUS);
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.userInteractionEnabled = YES;
    self.mapView.showsUserLocation = YES;
    [super viewWillAppear:animated];
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

@end

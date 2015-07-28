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
//  MFBarCodeScanViewController.m
//  scanner
//
//

// Header import
#import "MFBarCodeScanViewController.h"

@interface MFBarCodeScanViewController ()

/**
 * @brief A close button displayed on the left top edge of the view controller
 */
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation MFBarCodeScanViewController

@synthesize currentOrientation = _currentOrientation;
@synthesize session = _session;
@synthesize device = _device;
@synthesize input = _input;
@synthesize output = _output;
@synthesize prevLayer = _prevLayer;
@synthesize highlightView = _highlightView;
@synthesize barCodeScannerDelegate = _barCodeScannerDelegate;
@synthesize mainView = _mainView;
@synthesize orientationChangedDelegate = _orientationChangedDelegate;

#pragma mark - Constructors

-(id) initWithSourceComponent:(MFBarCodeScanTextField *)sourceComponent {
    self = [super init];
    if(self ) {
        self.sourceComponent = sourceComponent;
        self.barCodeScannerDelegate = [[MFBarCodeScannerDelegate alloc] initWithSource:self];
    }
    return self;
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Indicated what is the main view for MFBarCodeScannerDelegate
    self.mainView = self.view;
    
    //Initializing Scanner Camera Output
    [self.barCodeScannerDelegate initializeScanner];
    
    //Customizing ViewController appearence
    [self addCloseButton];
    
    //Post initializing
    [self.barCodeScannerDelegate postInitialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @brief Dealloc this class. remove observers
 */
- (void)dealloc
{
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MFBarCodeScanViewController custom methods

-(void) addCloseButton {
    
    //Close button initialization
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setTitle:@"Fermer" forState:UIControlStateNormal];
    [self.closeButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    
    //Adding close button to the main view
    [self.view addSubview:self.closeButton];
    
    //Defining constraints for the close button
    NSLayoutConstraint *closeButtonBottomMargin = [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *closeButtonLeftMargin = [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
   
    NSLayoutConstraint *closeButtonWidth = [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
   
    NSLayoutConstraint *closeButtonHeight = [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.15 constant:0];
    
    // Adding constraints for the close button to the main view
    [self.view addConstraints:@[
                                closeButtonBottomMargin,
                                closeButtonLeftMargin,
                                closeButtonWidth,
                                closeButtonHeight
                                ]];
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //bring close button to front
    [self.view bringSubviewToFront:self.closeButton];
}



/**
 * @brief Method called by the closebutton to dismiss this ViewController
 */
-(void) closeViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFBarCodeScannerProtocol methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) doActionOnDetectionOfString:(NSString *)detectionString {
    [self.sourceComponent performSelector:@selector(updateValueFromExternalSource:) withObject:detectionString];
    [self closeViewController];
}
#pragma clang diagnostic pop


#pragma mark - Orientation changed protocol
-(void)orientationDidChanged:(NSNotification *)notification {
    [self.barCodeScannerDelegate orientationDidChanged:notification];
}


-(void)registerOrientationChange {
    [self.barCodeScannerDelegate registerOrientationChange];
}

#pragma mark - AVCaptureOutput inherited methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.barCodeScannerDelegate captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
}



@end

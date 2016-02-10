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
//  MFBarCodeScannerDelegate.h
//  scanner
//
//

// iOS imports
#import <AVFoundation/AVFoundation.h>

// Custom imports
#import "MFUIMotion.h"
@class MFBarCodeScannerDelegate;


/**
 * @brief This protocol id used to add methods and properties used by a MFBarCodeScannerDelegate instance
 * to do some scanner treatments on the target object
 */
@protocol MFBarCodeScannerProtocol <AVCaptureMetadataOutputObjectsDelegate, MFOrientationChangedProtocol>

#pragma mark - Properties
/**
 * @brief The AVCaptureSession object of AVCaptureMetadataOutputObjectsDelegate
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 * @brief The AVCaptureDevice object of AVCaptureMetadataOutputObjectsDelegate
 */
@property (nonatomic, strong) AVCaptureDevice *device;

/**
 * @brief The AVCaptureDeviceInput object of AVCaptureMetadataOutputObjectsDelegate
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;

/**
 * @brief The AVCaptureMetadataOutput object of AVCaptureMetadataOutputObjectsDelegate
 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

/**
 * @brief The AVCaptureVideoPreviewLayer object of AVCaptureMetadataOutputObjectsDelegate
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;

/**
 * @brief The hightList view used with AVCaptureMetadataOutputObjectsDelegate to highlight
 * recognized QRCode/BarCode elements
 */
@property (nonatomic, strong) UIView *highlightView;

/**
* @brief The main view used by this delegate to apply scanner treatments
 */
@property (nonatomic, strong) UIView *mainView;

/**
 * @brief Le delegate associés aux changement d'orientation
 */
@property (nonatomic, strong) MFOrientationChangedDelegate *orientationChangedDelegate;

/**
 * @brief The MFBarCodeScannerDelegate used to apply scanner treatments
 */
@property (nonatomic, strong) MFBarCodeScannerDelegate *barCodeScannerDelegate;



#pragma mark - Methods

/**
 * @brief A callback method used to apply some treatments when a QRCode/BarCode has been recognized
 * @param detectionString The recognized value sent from the bar code scanner delegate
 */
-(void) doActionOnDetectionOfString:(NSString *)detectionString;

@end


/**
 * @brief This delegate do some scanner treatments as initializing capture video output or
 * BarCode/QRCode recognizing
 */
@interface MFBarCodeScannerDelegate : NSObject

#pragma mark - Methods
/**
 * @brief Custom constructor that should be used by an object implementing MFBarCodeScannerProtocol.
 * @param The source object that implements MFBarCodeScannerProtocol
 * @return The created instance of MFBarCodeScannerDelegate
 */
-(id) initWithSource:(id<MFBarCodeScannerProtocol>)source;

/**
 * @brief A method that should be called to initialize the scanner
 */
-(void) initializeScanner;

/**
 * @brief A method that should be called once the sourceObject has been initialized
 */
-(void) postInitialize;

/**
 * @brief A forward declaration of orientationDidChanged: method from MFOrientationChangedProtocol, on this delegate
 * @see MFOrientationChangedProtocol
 */
-(void)orientationDidChanged:(NSNotification *)notification;

/**
 * @brief A forward declaration of registerOrientationChange method from MFOrientationChangedProtocol, on this delegate
 * @see MFOrientationChangedProtocol
 */
-(void)registerOrientationChange;

/**
 * @brief A forward declaration of captureOutput:didOutputMetadataObjects:fromConnection: method 
 * from AVCaptureMetadataOutputObjectsDelegate, on this delegate
 * @see AVCaptureMetadataOutputObjectsDelegate
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection;

@end




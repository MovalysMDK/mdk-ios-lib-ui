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
//  MFBarCodeScannerDelegate.m
//  scanner
//
//

#import "MFBarCodeScannerDelegate.h"

@interface MFBarCodeScannerDelegate ()

/**
 * @brief The source object that uses this delegate
 */
@property (nonatomic, weak) id<MFBarCodeScannerProtocol> sourceScanner;

@end

@implementation MFBarCodeScannerDelegate

#pragma mark - Initializing

-(id) initWithSource:(id<MFBarCodeScannerProtocol>)source {
    self = [super init];
    if(self) {
        self.sourceScanner = source;
    }
    return self;
}

-(void)postInitialize {
    //register orientation changes
    [self registerOrientationChange];
}

/**
 * @brief This method initializes the scanner component to display a frame in which the user will see
 * the render view of camera
 */
-(void) initializeScanner {
    self.sourceScanner.highlightView = [[UIView alloc] init];
    self.sourceScanner.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.sourceScanner.highlightView.layer.borderColor = [UIColor redColor].CGColor;
    self.sourceScanner.highlightView.layer.borderWidth = 3;
    [self.sourceScanner.mainView addSubview:self.sourceScanner.highlightView];
    
    
    self.sourceScanner.session = [[AVCaptureSession alloc] init];
    self.sourceScanner.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    self.sourceScanner.input = [AVCaptureDeviceInput deviceInputWithDevice:self.sourceScanner.device error:&error];
    if (self.sourceScanner.input) {
        [self.sourceScanner.session addInput:self.sourceScanner.input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    self.sourceScanner.output = [[AVCaptureMetadataOutput alloc] init];
    [self.sourceScanner.output setMetadataObjectsDelegate:self.sourceScanner queue:dispatch_get_main_queue()];
    
    [self.sourceScanner.session addOutput:self.sourceScanner.output];
    
    self.sourceScanner.output.metadataObjectTypes = [self.sourceScanner.output availableMetadataObjectTypes];
    
    self.sourceScanner.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.sourceScanner.session];
    
    self.sourceScanner.prevLayer.frame =  self.sourceScanner.mainView.bounds;
    self.sourceScanner.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    [self.sourceScanner.mainView.layer addSublayer:self.sourceScanner.prevLayer];
    
    [self.sourceScanner.mainView bringSubviewToFront:self.sourceScanner.highlightView];
    [self.sourceScanner.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate forwarded methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.sourceScanner.prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString)
        {
            [self.sourceScanner doActionOnDetectionOfString:detectionString];
        }
    }
    
    self.sourceScanner.highlightView.frame = highlightViewRect;
}

#pragma mark - MFOrientationChangedProtocol forwarded methods
-(void)orientationDidChanged:(NSNotification *)notification {
    [self fixCaptureOrientation];
}


-(void)registerOrientationChange {
    self.sourceScanner.currentOrientation = [[UIDevice currentDevice] orientation];
    self.sourceScanner.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self.sourceScanner];
    [self.sourceScanner.orientationChangedDelegate registerOrientationChanges];
}


#pragma mark - Custom methods
/**
 * @brief Method called after an orientation change. It adapts captureOutput to the new orientation
 */
-(void) fixCaptureOrientation {
    AVCaptureConnection *videoConnection = self.sourceScanner.prevLayer.connection;
    if ([videoConnection isVideoOrientationSupported]) {
        if(UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
            [videoConnection setVideoOrientation:[self videoOrientation]];
        }
        if(self.sourceScanner.prevLayer) {
            self.sourceScanner.prevLayer.frame = self.sourceScanner.mainView.bounds;
        }
    }
}

-(AVCaptureVideoOrientation) videoOrientation {
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    switch([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

@end





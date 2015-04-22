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
//  MFScanner.m
//  scanner
//
//

// iOS imports
#import <AVFoundation/AVFoundation.h>

// Custom imports
#import "MFScanner.h"
#import "MFOrientationChangedDelegate.h"
#import "MFUILogging.h"

@interface MFScanner ()

/**
 * @brief the private data set or to return from this component
 */
@property (nonatomic, strong) NSString *privateData;

@end

static NSString const *NIL_DEBUG_VALUE = @"GET_NIL_VALUE";
NSUInteger ERROR_BUTTON_RIGHT_MARGIN = 5;

@implementation MFScanner

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
@synthesize privateData = _privateData;

#pragma mark - MFUIBaseCompoennt - Initializing

-(void) initialize {
    [super initialize];
    // Initializing MFBarCodeScannerDelegate
    self.barCodeScannerDelegate = [[MFBarCodeScannerDelegate alloc] initWithSource:self];
    
    //Indicated what is the main view for MFBarCodeScannerDelegate
    self.mainView = self;
    
    //Initializing Scanner Camera Output
    [self.barCodeScannerDelegate initializeScanner];
    
    //Post initializing
    [self.barCodeScannerDelegate postInitialize];
}


#pragma mark - MFUIBaseCompoennt - Managing data

-(void)setData:(id)data {
    self.privateData = data;
}

-(id)getData {
    return self.privateData;
}


+ (NSString *)getDataType {
    return @"NSString";
}


-(void) updateValue {
    [self.sender performSelectorOnMainThread: @selector(updateValue:) withObject:_privateData waitUntilDone:YES];
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    if([self.mandatory isEqualToNumber:@1] && !_privateData) {
        
        NSError *error = [[MFMandatoryFieldUIValidationError alloc]
                          initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        
        [self addErrors:@[error]];
        nbOfErrors++;
    }
#if DEBUG
    if([self.mandatory isEqualToNumber:@1] && _privateData && [NIL_DEBUG_VALUE isEqualToString:_privateData]) {
        
        NSError *error = [[MFMandatoryFieldUIValidationError alloc]
                          initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        
        [self addErrors:@[error]];
        nbOfErrors++;
    }
#endif
    return nbOfErrors;
}


#pragma mark - Scanner custom methods

/**
 * @brief Set constraints for the inner scanner view
 */
-(void) setScannerConstraints {
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_highlightView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_highlightView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_highlightView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_highlightView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
}




/**
 * @brief Dealloc this class. remove observers
 */
- (void)dealloc
{
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Geometry

-(void)layoutSubviews {
    [super layoutSubviews];
    if(_prevLayer) {
        _prevLayer.frame =  self.bounds;
    }
}

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

-(void)doActionOnDetectionOfString:(NSString *)detectionString {
    if(![detectionString isEqualToString:_privateData]) {
        MFUILogInfo(@"Scan ok device with detection string = %@", detectionString);
        _privateData = detectionString;
        [self updateValue];
    }
}




@end

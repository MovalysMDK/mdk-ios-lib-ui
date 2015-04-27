//
//  MFBarCodeTextField.m
//  MFUI
//
//  Created by Quentin Lagarde on 27/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import "MFBarCodeScanTextField.h"
#import "MFBarCodeScanViewController.h"
#import "MFUIApplication.h"

@implementation MFBarCodeScanTextField

-(void)initializeComponent {
    [self.styleClass performSelector:@selector(addButtonOnTextField:) withObject:self];
    [super initializeComponent];
}

#pragma mark - Custom MFBarCodeScanTextField methods

/**
 * @brief Method called when the user press the barCodeScann button of this component.
 * This method pushes in the lastAppearViewController from MFUIapplication instance, a VideoCapture ViewController
 * that allows the user to scan a QRCode/BarCode.
 */
-(void) doAction {
    MFBarCodeScanViewController *scanViewController = [[MFBarCodeScanViewController alloc] initWithSourceComponent:self];
    [[[MFUIApplication getInstance] lastAppearViewController] presentViewController:scanViewController animated:YES completion:nil];
}

-(void) updateValueFromExternalSource:(NSString *)value {
    [self setText:value];
    [self performSelector:@selector(updateValue)];
}



@end

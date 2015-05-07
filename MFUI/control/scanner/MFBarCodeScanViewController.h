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


// Custom imports
#import "MFBarCodeScanTextField.h"
#import "MFBarCodeScannerDelegate.h"


/**
 * @brief This ViewController allows the user to capture a QRCode/BarCode from camera
 */
@interface MFBarCodeScanViewController : UIViewController <MFBarCodeScannerProtocol>

#pragma mark - Properties

/**
 * @brief The MFBarCodeScanTextField source component that pushed this ViewController.
 */
@property (nonatomic, strong) MFBarCodeScanTextField *sourceComponent;



#pragma mark - Custom Methods
/**
 * @brief Custom constructor. This constructor take as unique parameter the source component that pushed
 * this ViewController
 * @param sourceComponent The source component that pushed this ViewController.
 * @return A MFBarCodeScanViewController new instance
 */
-(id) initWithSourceComponent:(MFBarCodeScanTextField *)sourceComponent;

@end

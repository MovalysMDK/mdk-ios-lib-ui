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


// ViewControllers imports
#import "MFForm2DListViewController.h"
#import "MFForm3DHeaderViewControls.h"


@interface MFForm3DListViewController : MFForm2DListViewController <MFForm3DControlsDelegate>

@property (weak, nonatomic) IBOutlet MFForm3DHeaderViewControls *headerView;

/**
 * @brief Define the title of the screen
 */
-(void)setScreenTitle;


@end

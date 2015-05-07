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
//  UIViewController+MFViewControllerUtils.h
//  MFCore
//
//

#import "MFViewControllerDelegate.h"

/*!
 * @brief permet de définir l'attribut privé du delegate
 */
@interface MFViewControllerUtils_Private : NSObject

@property(strong, nonatomic) MFViewControllerDelegate *viewControllerDelegate;

@end


@interface MFViewControllerUtils

@property(strong, nonatomic) MFViewControllerUtils_Private *extendsMFViewController;

@end



/*!
 * @brief ajoute des méthodes utilitaire sur le UIViewController, entre autre une méthode permettant de savoir quel est le view controller courant
 */
@interface UIViewController (MFViewControllerUtils)

-(MFViewControllerUtils_Private *) extendsMFViewController ;

-(void) setExtendsMFViewController:(MFViewControllerUtils_Private *) newMFViewControllerUtils ;

@end

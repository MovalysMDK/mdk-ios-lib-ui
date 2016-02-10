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
//  TransitionController.h
//  MMCore
//
//



@interface MFTransitionController : UIViewController

#pragma mark - Properties
/**
 * @brief La vue principale container
 */
@property (nonatomic, strong) UIView *containerView;

/**
 * @brief viecontroller
 */
@property (nonatomic, strong) UIViewController *viewController;


#pragma mark - Methods
/**
 * @brief Constructeur prenant en paramètre un objet UIViewController
 * @param viewController L'objet UIViewController à ajouter au transitionController
 * @return L'instance de l'objet construite
 */
- (id)initWithViewController:(UIViewController *)viewController;

/**
 * @brief Permet de faire une transition du ViewController courant au ViewController
 * passé en paramètre
 * @param newViewController Le ViewController vers lequel la transitions era faite
 * @param options Des options d'animation de la transition
 */
- (void)transitionToViewController:(UIViewController *)newViewController
                       withOptions:(UIViewAnimationOptions)options;

@end

/**
 * @brief Catégorie de MFTransitionController qui rajoute des méthodes utilitaires sur 
 * le UIViewController iOS.
 */
@interface UIViewController (MFTransitionController)

/**
 * @brief Le transition controller qui permet l'affichage de l'écran principal (central)
 */
@property(nonatomic, strong, readonly) MFTransitionController *transitionController;

/**
 * @brief Cette méthode permet de pousser un nouveau controller dans le navigationController de 
 * l'écran central. 
 * @param viewController L'objet UIViewController à pousser sur l'écran central
 * @param animated Booléen qui indique si l'object UIViewController doit être affiché avec ou
 * sans animation
 */
-(void) pushCenterViewController:(UIViewController *)viewController animated:(BOOL)animated;


@end

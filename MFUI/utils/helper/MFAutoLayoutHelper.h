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
//  MFAutoLayoutHelper.h
//  MFCore
//
//

/*!
 * @brief l'espace par défaut entre 2 composants
 */
#define MFALH_STD_SPACE 8

/*!
 * @brief ce composant permet d'ajouter des contraintes entre un composant donné et un composant principale
 */
@interface MFAutoLayoutHelper : NSObject

/*!
 * @brief la vue de référence de l'autolayouting
 */
@property (strong, nonatomic) UIView *referenceView;

/*!
 * @brief permet d'initialiser le composant en spécifiant la vue de référence
 */
-(id) initWithReferenceView:(UIView*) view;

/*!
 * @brief donne le ratio d'une image
 * @param component le composant à partir duquel on calcul le ratio
 * @return le ratio de l'image
 */
-(float) computeRatio:(UIView*)component;

/*!
 * @brief fixe la hauteur d'un composant en fonction de la hauteur de la référence
 * @param heightInPercent la hauteur du composant exprimé en % du composant de référence
 * @param component le composant dont on veut déterminer la largeur
 */
-(void) setFixedHeightInPercentFromParent:(float)heightInPercent toComponent:(UIView*)component;

/*!
 * @brief fixe la largeur d'un composant en fonction de la largeur de la référence
 * @param widthInPercent la hauteur du composant exprimé en % du composant de référence
 * @param component le composant dont on veut déterminer la longueur
 */
-(void) setFixedWidthInPercentFromParent:(float)widthInPercent toComponent:(UIView*)component;

/*!
 * @brief fixe la hauteur d'un composant en fonction de la hauteur de la référence en conservant un ratio donné
 * @param heightInPercent la hauteur du composant exprimé en % du composant de référence
 * @param component le composant dont on veut déterminer la largeur et la longueur
 * @param le ratio à utiliser pour déterminer la largeur du composant
 */
-(void) setFixedHeightInPercentFromParent:(float)heightInPercent toComponent:(UIView*)component withRatio:(float) ratio;

/*!
 * @brief fixe la largeur d'un composant en fonction de la largeur de la référence et fixe une hauteur en point
 * @param widthInPercent la largeur du composant exprimé en % du composant de référence
 * @param height la hauteur fixe du composant
 * @param component le composant dont on veut déterminer la largeur et la longueur

 */
-(void) setFixedWidthInPercentFromParent:(float)widthInPercent andFixedHeight:(float) height toComponent:(UIView*)component;

/*!
 * @brief fixe la hauteur d'un composant en fonction de la hauteur de la référence et fixe une largeur en point
 * @param heightInPercent la hauteur du composant exprimé en % du composant de référence
 * @param width la largeur fixde du composant
 * @param component le composant dont on veut déterminer la largeur et la longueur
 */
-(void) setFixedHeightInPercentFromParent:(float)heightInPercent andFixedWidth:(float) width toComponent:(UIView*)component;

/*!
 * @brief centre horizontalement un composant
 * @param component le composant à centrer
 */
-(void) setCenterXToComponent:(UIView*)component;

/*!
 * @brief centre verticalement un composant
 * @param component le composant à centrer
 */
-(void) setCenterYToComponent:(UIView*)component;

/*!
 * @brief place un espace fixe entre deux composants
 * @param space la taille de l'espace
 * @param component1 le composant 1 (on utilise le top)
 * @param component 2 le second composant (on utilise le top)
 */
-(void) setYFlexSpace:(float)space betweenTop:(UIView*) component1 andTop:(UIView*) component2;

/*!
 * @brief place un espace flexible entre deux composants
 * @param space la taille de l'espace
 * @param component1 le composant 1 (on utilise le top)
 * @param component 2 le second composant (on utilise le top)
 */
-(void) setYFixedSpace:(float)space betweenTop:(UIView*) component1 andTop:(UIView*) component2;

/*!
 * @brief place un espace fixe entre deux composants
 * @param space la taille de l'espace
 * @param component1 le composant 1 (on utilise le top)
 * @param component 2 le second composant (on utilise le bottom)
 */
-(void) setYFixedSpace:(float)space betweenTop:(UIView*) component1 andBottom:(UIView*) component2;

/*!
 * @brief place un espace fixe entre deux composants
 * @param space la taille de l'espace
 * @param component1 le composant 1 (on utilise le bottom)
 * @param component 2 le second composant (on utilise le bottom)
 */
-(void) setYFixedSpace:(float)space betweenBottom:(UIView*) component1 andBottom:(UIView*) component2;

/*!
 * @brief place un espace flexible entre deux composants
 * @param space la taille de l'espace
 * @param component1 le composant 1 (on utilise le top)
 * @param component 2 le second composant (on utilise le bottom)
 */
-(void) setYFlexSpace:(float)space betweenTop:(UIView*) component1 andBottom:(UIView*) component2;

/*!
 * @brief Ajoute un composant à la vue de référence
 * @param le composant à ajouter
 */
-(void) addSubview:(UIView*)view;

/*!
 * @brief Ajoute un composant à la vue de référence en lui donnant la taille du conteneur
 * @param le composant à ajouter
 */
-(void) addSubviewWithFullSize:(UIView *)view;

/*!
 * @brief permet de créer un composant fantôme (ie transparent), à utiliser pour certain calage
 */
-(UIView*) createGhost;
@end

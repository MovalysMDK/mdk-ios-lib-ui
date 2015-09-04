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



#import "MFUIComponentProtocol.h"
#import "MFUIBaseViewModelProtocol.h"

/*!
 * @brief Ce protocole permet de traiter des actions spéciales pour un type donnée
 */
@protocol MFTypeValueProcessingProtocol <NSObject>


@required
/*!
 * @brief Cette méthode permet de récupérer la valeur d'une propriété d'un composant graphique, à partir de sa description
 * dans le fichier PLIST ou de sa valeur dans le ViewModel. La méthode est liée au bindableProperties, des propriétés qui peuvent
 * être bindées à un ViewModel ou contenir des valeurs par défaut.
 * @param component Le composant graphique dont on souhaite récupérer la valeur d'une propriété
 * @param viewModel Le ViewModel à partir duquel on va pouvoir récupérer une valeur d'une propriété bindée.
 * @param bindableProperties Un dictionnaire contenant une liste de propriétés pouvant être bindée à un ViewModel, avec pour
 * chacune son type et ses valeurs par défaut autorisées.
 * @param property Le nom de la propriété bindée pour laquelle on va retourner une valeur
 * @return Un objet du bon type retourné en fonction de la valeur de la propriété bindée. Renvoie une valeur par défaut (si définie dans le PLIST),
 * une valeur bindée à un viewModel ou nil si la propriété n'est pas définie pour ce composant graphique
 */
-(id)processTreatmentOnComponent:(id<MFUIComponentProtocol>)component withViewModel:(id<MFUIBaseViewModelProtocol>)viewModel forProperty:(NSString *)property fromBindableProperties:(NSDictionary *)bindableProperties;

@end

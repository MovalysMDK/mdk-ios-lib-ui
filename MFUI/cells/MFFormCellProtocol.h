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
//  FormCell.h
//  MFUI
//
//

#import <MFCore/MFCoreFormDescriptor.h>

#import "MFUIBinding.h"
#import "MFUITransitionDelegate.h"

@class MFUIBaseComponent;

/**
 * @brief A protocol defining some basic methods and attributes for framework cells.
 * @discussion This protocol should be used by any cell that should be binded or used by the framework
 */
@protocol MFFormCellProtocol <MFUIGroupedElementCommonProtocol>


#pragma mark - Properties
@required

/*
 UI Transition Delegate Manager.
 */
@property(nonatomic, weak) id<MFUITransitionDelegate> transitionDelegate;

/**
 * @brief L'indexPath de cette cellule
 */
@property (nonatomic, strong) NSIndexPath *cellIndexPath;

/**
 Configure cell according to group descriptor's information and form descriptor's information.
 @param groupDescriptor : group descriptor used to display cell.
 @param formDescriptor: form which contains the group which contains cell.
 */
-(void)configureByGroupDescriptor:(MFGroupDescriptor*) groupDescriptor
                andFormDescriptor:(MFFormDescriptor *) formDescriptor;


#pragma mark - Methods

@required
/**
 * @brief Permet d'enregistrer la liste des composants graphiques concernés par la synchronisation des données
 * @param dictionnary La liste des composants actuellement enregistrés dans le formulaire 
 * @return La liste des nouveaux composants ajoutés à la liste passée en paramètre
 */
-(NSMutableDictionary *)registerComponent:(id<MFBindingFormDelegate>)formController;

/**
 * @brief Unregisters components from binding of a specific formController
 * @param The form controller in which this cell should unregister its components from the binding
*/
-(void)unregisterComponents:(id<MFBindingFormDelegate>)formController;



@end

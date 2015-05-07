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


#import "MFUIForm.h"

#import "MFUIOldBaseComponent.h"
#import "MFFixedListDataDelegate.h"

/**
 * @class MFFixedList
 * @brief A default component framework that represents an editable list of an element.
 * @discussion This components presents a list of an element of the same type (same ViewModel). 
 * @discussion The list is editable : it's possible to add, delete or edit elements.
 * @warning This component is necessarily associated to a MFCellComponentFixedList because of its special size behavior.
 */
@interface MFFixedList : MFUIOldBaseComponent

#pragma mark - Custom enumeration (edit mode options)
/**
 * @typedef MFFixedListEditMode
 * @brief Cette structure définit le mode d'édition de la liste
 * @constant MFFixedListEditModePopup La liste est éditable via une popup
 * @constant MFFixedListEditModeDirect La liste est directement éditable.
 */
typedef enum {
    MFFixedListEditModePopup=0,
    MFFixedListEditModeDirect=1
} MFFixedListEditMode;


/**
 * @typedef MFFixedListAlignment
 * @brief Cette structure définit le mode d'édition de la liste
 * @constant MFFixedListEditModeNone : La liste n'est pas éditable
 * @constant MFFixedListEditModePopup : la liste est éditable via une popup
 * @constant MFFixedListEditModeDirect : la liste est directement éditable.
 */
typedef enum {
    MFFixedListAlignmentLeft=0,
    MFFixedListAlignmentCenter=1,
    MFFixedListAlignmentRight=2
} MFFixedListAlignment;


#pragma mark - Propriétés

/** 
 * @brief l'extension du controlleur, l'extension contient des paramètres qui peuvent être définis dans le storyboard 
 */
@property(nonatomic, strong) MFFormExtend *mf;

/**
 * @brief Le tableau contenant les données de la Liste éditable
 */
@property (nonatomic, strong) MFFixedListDataDelegate* dataDelegate;

/**
 * @brief La liste éditable
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 * @brief La liste éditable
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 * @brief bouton d'ajout d'item
 */
@property (nonatomic, strong) UIButton *addButton;

/**
 * @brief Le mode d'édition de cette liste (@see MFFixedListEditMode)
 */
@property (nonatomic) MFFixedListEditMode editMode;

/**
 * @brief La hauteur d'une cellule de la liste éditable (définie dans le storyboard).
 */
@property (nonatomic) int rowHeight;

/**
 * @brief Le nom de la classe à utiliser pour construire un nouvel item de liste
 */
@property (nonatomic, strong) NSString *itemClassName;

/**
 * @brief The topBarView of the component
 */
@property (nonatomic, strong) UIView *topBarView;


#pragma mark - Méthodes

/**
 * @brief Constructeur d'une tableView avec Style
 * @param frame La Frame de la TableView
 * @param tableViewStyle Le style de la TableView
 * @return L'objet construit
 */
//non implemented
//-(id)initWithFrame:(CGRect)frame  style:(UITableViewStyle)tableViewStyle;
    
/**
 * @brief Set value of the field
 * @param value the value of the string
 */
//-(void) setValue:(NSString *) value;

/**
 * @brief Returns the value of the field
 * @return the value of the field
 */
//-(NSString *) getValue;

/**
 * @brief Set data in a the list after a cell has been edited
 * @param data the new data to set in the list
 */
-(void) setDataAfterEdition:(id)data;


/**
 * @brief Allows to add a custom button on the top of the list
 * @param button The button to add
 */
-(void) addCustomButton:(UIButton *)button;

/**
 * @brief Allows to remove a custom button from the top of the list
 * @param index The index of the button to remove
 */
-(void) removeCustomButtonAtIndex:(int) index;


/**
 * @brief Allows to remove a custom button from the top of the list
 * @param button The button to remove
 */
-(void) removeCustomButton:(UIButton *) button;

/**
 * @brief This metohd allows the user to actualize custom methods display
 */
-(void) refreshCustomButtons;

/**
 * @brief This metohd allows the user to reset the buttons
 */
-(void) resetCustomButtons;

/** 
 * @brief This shows the waiting view when the list is not loaded and the main form controller is scrolling
 * @param contentSize The size of the content of the list, to fill it
 */
//non implemented
//-(void) showLoadingView;

/**
 * @brief This dissmisses the waiting view (this must be called when the main controller of this list
 * stops to scroll
 */
//non implemented
//-(void) dismissLoadingView;

/**
 * @brief Specifies the heigh of the top bar view
 * @return The height of the top bar view
 */
-(NSInteger) topBarViewHeight;

/**
 * @brief Indicates if the buttons should be shown
 * @return YES to display buttons, NO otherwhise
 */
-(BOOL) showButtons;

/**
 * @brief Indicates if the title should be shown
 * @return YES to display title, NO otherwhise
 */
-(BOOL) showTitle;

/**
 * @brief Indicates the buttons alignement
 * @return A MFFixedListAlignment value
 */
-(MFFixedListAlignment) buttonsAlignment;

/**
 * @brief Change dynamically the height of the fixed list
 * @param newHeight The new height to set
 */
-(void) changeDynamicHeight:(int)newHeight;

/**
 * @brief Indicates if the component is a simple FixedList or a PhotoFixedList
 * @return YES if the component is a PhotoFixedList, NO otherwise
 */
-(BOOL) isPhotoFixedList;

@end

/// !!! Doit être déclaré à la fin, ne pas bouger.
#import "MFFixedList+UITableViewForwarding.h"


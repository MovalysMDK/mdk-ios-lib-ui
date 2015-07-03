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

#import <Foundation/Foundation.h>
#import "MFFixedListDataDelegate.h"

/*!
 * @typedef MFFixedListEditMode
 * @brief Cette structure définit le mode d'édition de la liste
 * @constant MFFixedListEditModePopup La liste est éditable via une popup
 * @constant MFFixedListEditModeDirect La liste est directement éditable.
 */
typedef enum {
    MFFixedListEditModePopup=0,
    MFFixedListEditModeDirect=1
} MFFixedListEditMode;


/*!
 * @class MFFixedListExtension
 * @brief This class is an extension of the FixedList
 */
@interface MFFixedListExtension : NSObject

/*!
 * @brief Indicates if the user can add item
 */
@property (nonatomic) BOOL canAddItem;

/*!
 * @brief Indicates if the user can edit the fixedList
 */
@property (nonatomic) BOOL canEditItem;

/*!
 * @brief Indicates if the user can delete item
 */
@property (nonatomic) BOOL canDeleteItem;

/*!
 * @brief Indicates it it is a PhotofixedList
 */
@property (nonatomic) BOOL isPhotoFixedList;

/*!
 * @brief The edition mode of the fixedList
 */
@property (nonatomic) MFFixedListEditMode editMode;

/*!
 * @brief Le tableau contenant les données de la Liste éditable
 */
@property (nonatomic, strong) MFFixedListDataDelegate* dataDelegate;

@end
